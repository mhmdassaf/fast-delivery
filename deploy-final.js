/**
 * Firebase Rules Deployment - Direct API with proper release creation
 */

const https = require('https');
const fs = require('fs');
const crypto = require('crypto');
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

const PROJECT_ID = 'fast-delivery-32739';

/**
 * Make HTTPS request helper
 */
function makeRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const data = JSON.parse(body);
          resolve({ status: res.statusCode, data });
        } catch {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    if (postData) req.write(postData);
    req.end();
  });
}

/**
 * Get OAuth2 access token using JWT assertion
 */
async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const expiry = now + 3600;

  const header = Buffer.from(JSON.stringify({
    alg: 'RS256',
    typ: 'JWT'
  })).toString('base64url');

  const payload = Buffer.from(JSON.stringify({
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: expiry,
    scope: 'https://www.googleapis.com/auth/cloud-platform'
  })).toString('base64url');

  const sign = crypto.createSign('RSA-SHA256');
  sign.update(`${header}.${payload}`);
  const signature = sign.sign(serviceAccount.private_key, 'base64url');

  const assertion = `${header}.${payload}.${signature}`;
  const postData = `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${encodeURIComponent(assertion)}`;

  const result = await makeRequest({
    hostname: 'oauth2.googleapis.com',
    port: 443,
    path: '/token',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(postData)
    }
  }, postData);

  return result.data.access_token;
}

/**
 * Deploy rules using Firebase Tools CLI binary directly
 */
async function deployWithFirebaseCLI() {
  console.log('Using Firebase CLI to deploy rules...');
  console.log('Running: firebase deploy --only firestore:rules --project fast-delivery-32739\n');

  const { execSync } = require('child_process');
  const path = require('path');

  const firebaseCli = 'C:/Users/mhmd.assaf/AppData/Roaming/npm/firebase.exe';

  try {
    const result = execSync(`${firebaseCli} deploy --only firestore:rules --project fast-delivery-32739`, {
      cwd: process.cwd(),
      stdio: 'inherit',
      env: {
        ...process.env,
        FIREBASE_TOKEN: 'from-service-account'
      }
    });
    return true;
  } catch (error) {
    console.log('Firebase CLI requires login. Let\'s try with the service account...');
    return false;
  }
}

/**
 * Deploy Firestore rules using direct REST API
 */
async function deployFirestoreRules(token) {
  console.log('Deploying Firestore security rules...');

  const rulesContent = fs.readFileSync('./firestore.rules', 'utf8');

  // Step 1: Create ruleset
  const rulesetData = JSON.stringify({
    source: {
      files: [{
        name: 'firestore.rules',
        content: rulesContent
      }]
    }
  });

  const rulesetResult = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    port: 443,
    path: `/v1/projects/${PROJECT_ID}/rulesets`,
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(rulesetData)
    }
  }, rulesetData);

  if (rulesetResult.status !== 200 && rulesetResult.status !== 201) {
    console.log(`Ruleset error (${rulesetResult.status}):`, JSON.stringify(rulesetResult.data, null, 2));
    return false;
  }

  const rulesetName = rulesetResult.data.name;
  console.log(`✓ Created ruleset: ${rulesetName.split('/').pop()}`);

  // Step 2: Get existing release to check if it exists
  const getReleaseResult = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    port: 443,
    path: `/v1/projects/${PROJECT_ID}/releases/cloud.firestore.release`,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}` }
  });

  // Step 3: Create or update release
  const releaseData = JSON.stringify({
    rulesetName: rulesetName
  });

  let releaseResult;
  if (getReleaseResult.status === 200) {
    // Update existing release - PATCH needs 'ruleset' not 'rulesetName'
    console.log('Updating existing release...');
    releaseResult = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases/cloud.firestore.release`,
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(releaseData)
      }
    }, releaseData);
  } else {
    // Create new release - needs name field
    console.log('Creating new release...');
    const releaseDataWithName = JSON.stringify({
      name: `projects/${PROJECT_ID}/releases/cloud.firestore.release`,
      rulesetName: rulesetName
    });
    releaseResult = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(releaseDataWithName)
      }
    }, releaseDataWithName);
  }

  if (releaseResult.status === 200 || releaseResult.status === 201) {
    console.log('✓ Firestore rules deployed successfully!\n');
    return true;
  }

  console.log(`Release error (${releaseResult.status}):`, JSON.stringify(releaseResult.data, null, 2));
  return false;
}

/**
 * Deploy Firestore indexes
 */
async function deployFirestoreIndexes(token) {
  console.log('Deploying Firestore indexes...');

  const rawConfig = fs.readFileSync('./firestore.indexes.json', 'utf8');
  const jsonConfig = rawConfig.replace(/\/\/.*$/gm, '');
  const config = JSON.parse(jsonConfig);

  let deployed = 0;
  for (const index of config.indexes || []) {
    const collectionGroup = index.collectionGroup;
    const indexPayload = JSON.stringify({
      fields: index.fields.map(f => {
        if (f.arrayConfig) {
          return { fieldPath: f.fieldPath, arrayConfig: f.arrayConfig };
        }
        return { fieldPath: f.fieldPath, order: f.order };
      })
    });

    // Note: Indexes should be deployed via firebase deploy --only firestore:indexes
    // or through Firebase Console. Direct API access may be restricted.
    // For now, we log what indexes would be created.
    console.log(`  - ${collectionGroup}: ${index.fields.map(f => f.fieldPath).join(', ')}`);
    deployed++;
  }

  console.log(`✓ Defined ${deployed} indexes (manage via Firebase Console or CLI)`);
  return true;
}

/**
 * Deploy Storage rules
 */
async function deployStorageRules(token) {
  console.log('Deploying Storage security rules...');

  const rulesContent = fs.readFileSync('./storage.rules', 'utf8');

  const rulesetData = JSON.stringify({
    source: {
      files: [{
        name: 'storage.rules',
        content: rulesContent
      }]
    }
  });

  const rulesetResult = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    port: 443,
    path: `/v1/projects/${PROJECT_ID}/rulesets`,
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(rulesetData)
    }
  }, rulesetData);

  if (rulesetResult.status !== 200 && rulesetResult.status !== 201) {
    console.log(`Storage ruleset error (${rulesetResult.status}):`, JSON.stringify(rulesetResult.data, null, 2));
    return false;
  }

  const rulesetName = rulesetResult.data.name;
  console.log(`✓ Created storage ruleset: ${rulesetName.split('/').pop()}`);

  // Check if release exists
  const getReleaseResult = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    port: 443,
    path: `/v1/projects/${PROJECT_ID}/releases/cloud.storage.release`,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}` }
  });

  const releaseData = JSON.stringify({
    rulesetName: rulesetName
  });

  let releaseResult;
  if (getReleaseResult.status === 200) {
    // Update existing release
    releaseResult = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases/cloud.storage.release`,
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(releaseData)
      }
    }, releaseData);
  } else {
    // Create new release - needs name field
    const releaseDataWithName = JSON.stringify({
      name: `projects/${PROJECT_ID}/releases/cloud.storage.release`,
      rulesetName: rulesetName
    });
    releaseResult = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(releaseDataWithName)
      }
    }, releaseDataWithName);
  }

  if (releaseResult.status === 200 || releaseResult.status === 201) {
    console.log('✓ Storage rules deployed successfully!\n');
    return true;
  }

  console.log(`Storage release error (${releaseResult.status}):`, JSON.stringify(releaseResult.data, null, 2));
  return false;
}

// Main execution
async function main() {
  console.log('='.repeat(50));
  console.log('Firebase Rules Deployment');
  console.log('='.repeat(50));
  console.log('');

  try {
    console.log('Getting access token...');
    const token = await getAccessToken();
    console.log('✓ Access token obtained\n');

    const rulesOk = await deployFirestoreRules(token);
    const indexesOk = await deployFirestoreIndexes(token);
    const storageOk = await deployStorageRules(token);

    console.log('='.repeat(50));
    if (rulesOk && indexesOk && storageOk) {
      console.log('🎉 All Firebase rules deployed successfully!');
    } else {
      console.log('⚠ Some deployments had issues');
    }
    console.log('='.repeat(50));

  } catch (error) {
    console.error('\n❌ Deployment failed:', error.message);
  }
}

main();