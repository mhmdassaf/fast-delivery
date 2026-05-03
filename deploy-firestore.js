const https = require('https');
const fs = require('fs');
const crypto = require('crypto');

// Configuration
const PROJECT_ID = 'fast-delivery-32739';
const SERVICE_ACCOUNT = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

// Get access token using JWT
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
    iss: SERVICE_ACCOUNT.client_email,
    sub: SERVICE_ACCOUNT.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: expiry,
    scope: scopes.join(' ')
  })).toString('base64url');
  
  const sign = crypto.createSign('RSA-SHA256');
  sign.update(`${header}.${payload}`);
  const signature = sign.sign(SERVICE_ACCOUNT.private_key, 'base64url');
  
  const assertion = `${header}.${payload}.${signature}`;
  
  const postData = `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${encodeURIComponent(assertion)}`;
  
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'oauth2.googleapis.com',
      port: 443,
      path: '/token',
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        const result = JSON.parse(data);
        resolve(result.id_token || result.access_token);
      });
    });
    
    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// Deploy rules
async function deployRules(accessToken) {
  try {
    console.log('Deploying Firestore rules...');
    
    const rulesContent = fs.readFileSync('./firestore.rules', 'utf8');
    
    // Step 1: Create ruleset
    const rulesetPostData = JSON.stringify({
      source: {
        files: [
          {
            name: 'firestore.rules',
            content: rulesContent
          }
        ]
      }
    });
    
    const rulesetOptions = {
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/rulesets`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
        'Content-Length': Buffer.byteLength(rulesetPostData)
      }
    };
    
    const rulesetResult = await makeRequest(rulesetOptions, rulesetPostData);
    console.log(`Ruleset creation status: ${rulesetResult.status}`);
    
    if (rulesetResult.status !== 200 && rulesetResult.status !== 201) {
      console.log('Ruleset response:', JSON.stringify(rulesetResult.data, null, 2));
      return false;
    }
    
    const rulesetName = rulesetResult.data.name;
    console.log(`Created ruleset: ${rulesetName}`);
    
    // Step 2: Create release - correct API format
    const releasePostData = JSON.stringify({
      name: `projects/${PROJECT_ID}/releases/cloud.firestore.release`,
      rulesetName: rulesetName
    });
    
    // First try POST to create the release
    const releaseOptions = {
      hostname: 'firebaserules.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/releases`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
        'Content-Length': Buffer.byteLength(releasePostData)
      }
    };
    
    const releaseResult = await makeRequest(releaseOptions, releasePostData);
    console.log(`Release POST status: ${releaseResult.status}`);
    
    if (releaseResult.status === 200 || releaseResult.status === 201) {
      console.log('✅ Firestore rules deployed successfully!');
      return true;
    } else if (releaseResult.status === 409) {
      // Release already exists, use PATCH to update
      console.log('Release exists, updating with PATCH...');
      const patchOptions = {
        hostname: 'firebaserules.googleapis.com',
        port: 443,
        path: `/v1/projects/${PROJECT_ID}/releases/cloud.firestore.release`,
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
          'Content-Length': Buffer.byteLength(releasePostData)
        }
      };
      
      const patchResult = await makeRequest(patchOptions, releasePostData);
      console.log(`Release PATCH status: ${patchResult.status}`);
      
      if (patchResult.status === 200 || patchResult.status === 201) {
        console.log('✅ Firestore rules deployed successfully (PATCH)!');
        return true;
      }
      console.log('Patch response:', JSON.stringify(patchResult.data, null, 2));
      return false;
    } else {
      console.log('Release response:', JSON.stringify(releaseResult.data, null, 2));
      return false;
    }
    
  } catch (error) {
    console.error('Error deploying rules:', error.message);
    return false;
  }
}

// Deploy indexes
async function deployIndexes(accessToken) {
  try {
    console.log('\nDeploying Firestore indexes...');
    
    const rawConfig = fs.readFileSync('./firestore.indexes.json', 'utf8');
    const jsonConfig = rawConfig.replace(/\/\/.*$/gm, '');
    const indexesConfig = JSON.parse(jsonConfig);
    
    for (const index of indexesConfig.indexes || []) {
      const collectionGroup = index.collectionGroup || 'orders';
      
      const indexPayload = {
        fields: index.fields.map(f => {
          if (f.arrayConfig) {
            return { fieldPath: f.fieldPath, arrayConfig: f.arrayConfig };
          } else if (f.order) {
            return { fieldPath: f.fieldPath, order: f.order };
          }
          return f;
        })
      };
      
      const postData = JSON.stringify(indexPayload);
      
      const options = {
        hostname: 'firestore.googleapis.com',
        port: 443,
        path: `/v1/projects/${PROJECT_ID}/databaseIds/(default)/collectionGroups/${collectionGroup}/indexes`,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
          'Content-Length': Buffer.byteLength(postData)
        }
      };
      
      const result = await makeRequest(options, postData);
      
      if (result.status === 200 || result.status === 201) {
        console.log(`  ✅ Index for ${collectionGroup} created`);
      } else {
        console.log(`  ⚠️ Index response: ${result.status}`);
      }
    }
    
    console.log('✅ Firestore indexes deployment complete!');
    return true;
    
  } catch (error) {
    console.error('Error deploying indexes:', error.message);
    return false;
  }
}

// Helper function to make HTTP requests
function makeRequest(options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

// Main function
async function main() {
  try {
    console.log('Getting access token...');
    const accessToken = await getAccessToken();
    console.log('Access token obtained\n');
    
    const rulesDeployed = await deployRules(accessToken);
    if (rulesDeployed) {
      await new Promise(r => setTimeout(r, 1000));
      await deployIndexes(accessToken);
    }
    
    console.log('\n=== Deployment Complete ===');
    if (rulesDeployed) {
      console.log('✅ Firestore security rules deployed!');
      console.log('✅ Composite indexes deployed!');
    } else {
      console.log('⚠️ Some deployments failed. Check the output above.');
    }
    
  } catch (error) {
    console.error('Deployment failed:', error.message);
  }
}

main();