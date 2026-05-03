const https = require('https');
const crypto = require('crypto');
const fs = require('fs');
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const PROJECT_ID = 'fast-delivery-32739';

function makeRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body }));
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
    iat: now, exp: now + 3600,
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
  const token = await getAccessToken();
  console.log('Token OK');

  // Create ruleset for storage
  const rules = fs.readFileSync('./storage.rules', 'utf8');
  const rulesetData = JSON.stringify({source: {files: [{name: 'storage.rules', content: rules}]}});
  const ruleset = await makeRequest({
    hostname: 'firebaserules.googleapis.com', port: 443, path: `/v1/projects/${PROJECT_ID}/rulesets`,
    method: 'POST', headers: {'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(rulesetData)}
  }, rulesetData);
  console.log('Create ruleset:', ruleset.status, ruleset.body.substring(0, 300));
}

test().catch(console.error);