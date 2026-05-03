/**
 * Firebase Rules Deployment Script (Fixed v3)
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
  const header = Buffer.from(JSON.stringify({ alg: 'RS256', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify({
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
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
 * Create ruleset
 */
async function createRuleset(token, name, content) {
  const rulesetData = JSON.stringify({
    source: {
      files: [{
        name: name,
        content: content
      }]
    }
  });

  const result = await makeRequest({
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

  if (result.status === 200 || result.status === 201) {
    return result.data.name;
  }
  console.log(`Ruleset error (${result.status}):`, JSON.stringify(result.data, null, 2));
  return null;
}

/**
 * Deploy rules (create or update release)
 */
async function deployRules(token, serviceName, rulesetName) {
  const releaseName = `projects/${PROJECT_ID}/releases/${serviceName}.release`;

  // Check if release exists
  const getResult = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    port: 443,
    path: `/v1/projects/${PROJECT_ID}/releases/${serviceName}.release`,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}` }
  });

  if (getResult.status === 200) {
    // Update existing - use PATCH with ruleset.name format
    console.log(`Updating ${serviceName} release...`);
    const patchData = JSON.stringify({
      ruleset: { name: rulesetName }
    });

    const result = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases/${serviceName}.release`,
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(patchData)
      }
    }, patchData);

    if (result.status === 200) {
      console.log(`✓ ${serviceName} rules updated!`);
      return true;
    }
    console.log(`Update error (${result.status}):`, JSON.stringify(result.data, null, 2));
    return false;
  } else {
    // Create new - use POST with name and rulesetName
    console.log(`Creating ${serviceName} release...`);
    const createData = JSON.stringify({
      name: releaseName,
      rulesetName: rulesetName
    });

    const result = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(createData)
      }
    }, createData);

    if (result.status === 200 || result.status === 201) {
      console.log(`✓ ${serviceName} rules deployed!`);
      return true;
    }
    console.log(`Create error (${result.status}):`, JSON.stringify(result.data, null, 2));
    return false;
  }
}

/**
 * Deploy Firestore rules
 */
async function deployFirestoreRules(token) {
  console.log('\n📦 Deploying Firestore security rules...');

  const rules = fs.readFileSync('./firestore.rules', 'utf8');
  const rulesetName = await createRuleset(token, 'firestore.rules', rules);

  if (!rulesetName) {
    console.log('❌ Failed to create Firestore ruleset');
    return false;
  }
  console.log(`✓ Created ruleset: ${rulesetName.split('/').pop()}`);

  return await deployRules(token, 'cloud.firestore', rulesetName);
}

/**
 * Deploy Storage rules
 */
async function deployStorageRules(token) {
  console.log('\n📦 Deploying Storage security rules...');

  const rules = fs.readFileSync('./storage.rules', 'utf8');
  const rulesetName = await createRuleset(token, 'storage.rules', rules);

  if (!rulesetName) {
    console.log('❌ Failed to create Storage ruleset');
    return false;
  }
  console.log(`✓ Created ruleset: ${rulesetName.split('/').pop()}`);

  return await deployRules(token, 'cloud.storage', rulesetName);
}

/**
 * List defined indexes
 */
async function deployFirestoreIndexes(token) {
  console.log('\n📦 Firestore indexes (manage via Firebase Console or CLI):');

  const rawConfig = fs.readFileSync('./firestore.indexes.json', 'utf8');
  const jsonConfig = rawConfig.replace(/\/\/.*$/gm, '');
  const config = JSON.parse(jsonConfig);

  for (const index of config.indexes || []) {
    const fields = index.fields.map(f => f.fieldPath).join(', ');
    console.log(`  - ${index.collectionGroup}: ${fields}`);
  }
  console.log('✓ Defined indexes in configuration');

  return true;
}

/**
 * Verify deployment
 */
async function verifyDeployment(token) {
  console.log('\n🔍 Verifying deployment...');

  const services = ['cloud.firestore', 'cloud.storage'];
  for (const service of services) {
    const result = await makeRequest({
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases/${service}.release`,
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });

    if (result.status === 200) {
      const release = result.data;
      console.log(`✓ ${service}: ${release.rulesetName?.split('/').pop()}`);
    } else {
      console.log(`⚠ ${service}: not deployed`);
    }
  }
}

// Main execution
async function main() {
  console.log('═'.repeat(50));
  console.log('  Firebase Rules Deployment');
  console.log('═'.repeat(50));

  try {
    console.log('\n🔑 Getting access token...');
    const token = await getAccessToken();
    console.log('✓ Access token obtained');

    // Deploy rules
    const firestoreOk = await deployFirestoreRules(token);
    const storageOk = await deployStorageRules(token);
    const indexesOk = await deployFirestoreIndexes(token);

    // Verify
    await verifyDeployment(token);

    console.log('\n' + '═'.repeat(50));
    if (firestoreOk && storageOk) {
      console.log('🎉 All Firebase rules deployed successfully!');
    } else {
      console.log('⚠ Some deployments had issues. Check output above.');
    }
    console.log('═'.repeat(50));

  } catch (error) {
    console.error('\n❌ Deployment failed:', error.message);
  }
}

main();