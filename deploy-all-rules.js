/**
 * Firebase Rules Deployment Script
 * Uses Firebase Admin SDK for authentication
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Initialize Firebase Admin SDK with service account
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'fast-delivery-32739'
});

const projectId = 'fast-delivery-32739';

/**
 * Get access token using JWT assertion from service account
 */
async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const expiry = now + 3600;

  const header = Buffer.from(JSON.stringify({
    alg: 'RS256',
    typ: 'JWT'
  })).toString('base64url');

  const scopes = [
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/firebase',
    'https://www.googleapis.com/auth/firebaserules',
  ];

  const payload = Buffer.from(JSON.stringify({
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: expiry,
    scope: scopes.join(' ')
  })).toString('base64url');

  const sign = crypto.createSign('RSA-SHA256');
  sign.update(`${header}.${payload}`);
  const signature = sign.sign(serviceAccount.private_key, 'base64url');

  const assertion = `${header}.${payload}.${signature}`;

  const postData = `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${encodeURIComponent(assertion)}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(postData)
    },
    body: postData
  });

  const result = await response.json();
  return result.access_token;
}

/**
 * Deploy Firestore security rules
 */
async function deployFirestoreRules(accessToken) {
  console.log('Deploying Firestore security rules...');

  const rulesContent = fs.readFileSync('./firestore.rules', 'utf8');

  // Step 1: Create ruleset
  const rulesetData = {
    source: {
      files: [
        {
          name: 'firestore.rules',
          content: rulesContent
        }
      ]
    }
  };

  const rulesetResponse = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${projectId}/rulesets`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(rulesetData)
    }
  );

  if (!rulesetResponse.ok) {
    const error = await rulesetResponse.text();
    console.error('Failed to create ruleset:', error);
    return false;
  }

  const ruleset = await rulesetResponse.json();
  console.log(`✓ Created ruleset: ${ruleset.name}`);

  // Step 2: Create release (attach rules to project)
  const releaseData = {
    name: `projects/${projectId}/releases/cloud.firestore.release`,
    rulesetName: ruleset.name
  };

  const releaseResponse = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${projectId}/releases/cloud.firestore.release`,
    {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(releaseData)
    }
  );

  if (!releaseResponse.ok) {
    const error = await releaseResponse.text();
    console.error('Failed to create release:', error);
    return false;
  }

  console.log('✓ Deployed Firestore security rules successfully!');
  return true;
}

/**
 * Deploy Firestore indexes
 */
async function deployFirestoreIndexes(accessToken) {
  console.log('\nDeploying Firestore indexes...');

  const rawConfig = fs.readFileSync('./firestore.indexes.json', 'utf8');
  const jsonConfig = rawConfig.replace(/\/\/.*$/gm, '');
  const config = JSON.parse(jsonConfig);

  const deployedIndexes = [];
  const errors = [];

  for (const index of config.indexes || []) {
    const collectionGroup = index.collectionGroup;

    const indexPayload = {
      fields: index.fields.map(f => {
        if (f.arrayConfig) {
          return { fieldPath: f.fieldPath, arrayConfig: f.arrayConfig };
        }
        return { fieldPath: f.fieldPath, order: f.order };
      })
    };

    try {
      const response = await fetch(
        `https://firestore.googleapis.com/v1/projects/${projectId}/databaseIds/(default)/collectionGroups/${collectionGroup}/indexes`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(indexPayload)
        }
      );

      if (response.ok) {
        const result = await response.json();
        deployedIndexes.push({ collectionGroup, name: result.name });
        console.log(`  ✓ ${collectionGroup}: ${result.name.split('/').pop()}`);
      } else {
        const error = await response.text();
        errors.push({ collectionGroup, error });
        console.log(`  ⚠ ${collectionGroup}: ${error}`);
      }
    } catch (err) {
      errors.push({ collectionGroup, error: err.message });
      console.log(`  ✗ ${collectionGroup}: ${err.message}`);
    }
  }

  console.log(`\n✓ Deployed ${deployedIndexes.length} indexes`);
  if (errors.length > 0) {
    console.log(`⚠ ${errors.length} indexes failed (may already exist)`);
  }

  return true;
}

/**
 * Deploy Storage security rules
 */
async function deployStorageRules(accessToken) {
  console.log('\nDeploying Storage security rules...');

  const rulesContent = fs.readFileSync('./storage.rules', 'utf8');

  // Step 1: Create ruleset
  const rulesetData = {
    source: {
      files: [
        {
          name: 'storage.rules',
          content: rulesContent
        }
      ]
    }
  };

  const rulesetResponse = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${projectId}/rulesets`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(rulesetData)
    }
  );

  if (!rulesetResponse.ok) {
    const error = await rulesetResponse.text();
    console.error('Failed to create storage ruleset:', error);
    return false;
  }

  const ruleset = await rulesetResponse.json();
  console.log(`✓ Created storage ruleset: ${ruleset.name}`);

  // Step 2: Create release
  const releaseData = {
    name: `projects/${projectId}/releases/cloud.storage.release`,
    rulesetName: ruleset.name
  };

  const releaseResponse = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${projectId}/releases/cloud.storage.release`,
    {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(releaseData)
    }
  );

  if (!releaseResponse.ok) {
    const error = await releaseResponse.text();
    console.error('Failed to create storage release:', error);
    return false;
  }

  console.log('✓ Deployed Storage security rules successfully!');
  return true;
}

/**
 * Verify deployment
 */
async function verifyDeployment(accessToken) {
  console.log('\nVerifying deployment...');

  // Check Firestore rules
  try {
    const response = await fetch(
      `https://firebaserules.googleapis.com/v1/projects/${projectId}/releases/cloud.firestore.release`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      }
    );

    if (response.ok) {
      const release = await response.json();
      console.log('✓ Firestore rules active');
      console.log(`  Ruleset: ${release.rulesetName}`);
    }
  } catch (err) {
    console.log('✗ Could not verify Firestore rules');
  }

  // Check Storage rules
  try {
    const response = await fetch(
      `https://firebaserules.googleapis.com/v1/projects/${projectId}/releases/cloud.storage.release`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      }
    );

    if (response.ok) {
      const release = await response.json();
      console.log('✓ Storage rules active');
      console.log(`  Ruleset: ${release.rulesetName}`);
    }
  } catch (err) {
    console.log('⚠ Storage rules not yet deployed');
  }
}

// Main execution
async function main() {
  console.log('='.repeat(50));
  console.log('Firebase Rules Deployment Script');
  console.log('='.repeat(50));
  console.log('');

  try {
    console.log('Getting access token...');
    const accessToken = await getAccessToken();
    console.log('✓ Access token obtained\n');

    // Deploy all rules
    const firestoreRulesOk = await deployFirestoreRules(accessToken);
    const indexesOk = await deployFirestoreIndexes(accessToken);
    const storageRulesOk = await deployStorageRules(accessToken);

    // Verify
    await verifyDeployment(accessToken);

    console.log('\n' + '='.repeat(50));
    if (firestoreRulesOk && indexesOk && storageRulesOk) {
      console.log('🎉 All Firebase rules deployed successfully!');
    } else {
      console.log('⚠ Some deployments had issues. Check output above.');
    }
    console.log('='.repeat(50));

  } catch (error) {
    console.error('\n❌ Deployment failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

main();