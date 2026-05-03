const https = require('https');
const fs = require('fs');
const crypto = require('crypto');
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const PROJECT_ID = 'fast-delivery-32739';

function makeRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body }));
    });
    req.on('error', reject);
    if (postData) req.write(postData);
    req.end();
  });
}

async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const header = Buffer.from(JSON.stringify({alg: 'RS256', typ: 'JWT'})).toString('base64url');
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
    hostname: 'oauth2.googleapis.com', port: 443, path: '/token', method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(postData)}
  }, postData);
  return JSON.parse(result.body).access_token;
}

async function test() {
  console.log('='.repeat(50));
  console.log('Firebase Rules API Debug');
  console.log('='.repeat(50));
  console.log('');

  const token = await getAccessToken();
  console.log('✓ Got access token\n');

  // Test 1: Create ruleset
  console.log('Test 1: Create ruleset');
  const rules = fs.readFileSync('./firestore.rules', 'utf8');
  const rulesetData = JSON.stringify({source: {files: [{name: 'firestore.rules', content: rules}]}});
  const ruleset = await makeRequest({
    hostname: 'firebaserules.googleapis.com', port: 443, path: `/v1/projects/${PROJECT_ID}/rulesets`,
    method: 'POST', headers: {'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(rulesetData)}
  }, rulesetData);
  console.log(`Status: ${ruleset.status}`);
  console.log(`Response: ${ruleset.body}\n`);

  if (ruleset.status !== 200 && ruleset.status !== 201) {
    console.log('FAILED: Cannot create ruleset');
    return;
  }

  const rulesetName = JSON.parse(ruleset.body).name;
  console.log(`Created ruleset: ${rulesetName}\n`);

  // Test 2: Create release with different payload format
  console.log('Test 2: Create release (POST /releases)');
  const releaseData1 = JSON.stringify({rulesetName: rulesetName});
  const release1 = await makeRequest({
    hostname: 'firebaserules.googleapis.com', port: 443, path: `/v1/projects/${PROJECT_ID}/releases`,
    method: 'POST', headers: {'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(releaseData1)}
  }, releaseData1);
  console.log(`Status: ${release1.status}`);
  console.log(`Response: ${release1.body}\n`);

  // Test 3: Try PATCH on existing
  console.log('Test 3: Patch release (PATCH /releases/cloud.firestore.release)');
  const releaseData2 = JSON.stringify({rulesetName: rulesetName});
  const release2 = await makeRequest({
    hostname: 'firebaserules.googleapis.com', port: 443, path: `/v1/projects/${PROJECT_ID}/releases/cloud.firestore.release`,
    method: 'PATCH', headers: {'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(releaseData2)}
  }, releaseData2);
  console.log(`Status: ${release2.status}`);
  console.log(`Response: ${release2.body}\n`);

  // Test 4: Try with name field
  console.log('Test 4: Create release with name field');
  const releaseData3 = JSON.stringify({
    name: `projects/${PROJECT_ID}/releases/cloud.firestore.release`,
    rulesetName: rulesetName
  });
  const release3 = await makeRequest({
    hostname: 'firebaserules.googleapis.com', port: 443, path: `/v1/projects/${PROJECT_ID}/releases`,
    method: 'POST', headers: {'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(releaseData3)}
  }, releaseData3);
  console.log(`Status: ${release3.status}`);
  console.log(`Response: ${release3.body}\n`);
}

test().catch(console.error);