const { GoogleAuth } = require('google-auth-library');
const key = require('C:/Users/mhmd.assaf/source/repos/fast-delivery/assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const https = require('https');
const PROJECT = 'fast-delivery-32739';

const devRules = `rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}`;

async function call(method, host, pathStr, body) {
  const auth = new GoogleAuth({ credentials: key, scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'] });
  const token = await auth.getAccessToken();
  return new Promise((resolve, reject) => {
    const opts = { hostname: host, path: pathStr, method, headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' } };
    const req = https.request(opts, res => { let d = ''; res.on('data', c => d += c); res.on('end', () => resolve({ status: res.statusCode, body: d })); });
    req.on('error', reject); if (body) req.write(JSON.stringify(body)); req.end();
  });
}

async function run() {
  console.log('Creating permissive dev ruleset...');
  let r = await call('POST', 'firebaserules.googleapis.com', '/v1/projects/' + PROJECT + '/rulesets', {
    source: { files: [{ content: devRules, name: 'firestore.rules' }] }
  });
  const ruleset = JSON.parse(r.body);
  console.log('Status:', r.status, 'Name:', ruleset.name);

  console.log('Releasing dev rules...');
  const releaseName = 'projects/' + PROJECT + '/releases/cloud.firestore';
  r = await call('DELETE', 'firebaserules.googleapis.com', '/v1/' + releaseName);
  console.log('Delete old release:', r.status);

  r = await call('POST', 'firebaserules.googleapis.com', '/v1/projects/' + PROJECT + '/releases', {
    name: releaseName,
    rulesetName: ruleset.name
  });
  console.log('Create release:', r.status, r.body.substring(0, 200));
}

run().catch(e => { console.error('Error:', e.message); process.exit(1); });
