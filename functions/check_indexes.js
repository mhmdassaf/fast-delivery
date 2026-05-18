/**
 * Check Firestore composite index creation states.
 * 
 * Usage: node functions/check_indexes.js
 */
const { GoogleAuth } = require('google-auth-library');
const key = require('C:/Users/mhmd.assaf/source/repos/fast-delivery/assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const https = require('https');
const PROJECT = 'fast-delivery-32739';

function call(method, host, pathStr) {
  return new Promise((resolve, reject) => {
    const auth = new GoogleAuth({ credentials: key, scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'] });
    auth.getAccessToken().then(token => {
      const opts = { hostname: host, path: pathStr, method, headers: { 'Authorization': 'Bearer ' + token } };
      const req = https.request(opts, res => { let d = ''; res.on('data', c => d += c); res.on('end', () => resolve({ status: res.statusCode, body: d })); });
      req.on('error', reject); req.end();
    });
  });
}

async function run() {
  const r = await call('GET', 'firestore.googleapis.com', '/v1/projects/' + PROJECT + '/databases/(default)/collectionGroups/-/indexes');
  
  if (r.status !== 200) {
    console.error('Failed to list indexes:', r.status, r.body.substring(0, 200));
    process.exit(1);
  }
  
  const data = JSON.parse(r.body);
  const indexes = data.indexes || [];
  
  console.log(`Total indexes: ${indexes.length}\n`);
  
  /** Extract collectionGroup from the index name field */
  function extractCollectionGroup(name) {
    const match = name.match(/collectionGroups\/([^/]+)/);
    return match ? match[1] : '?';
  }

  const byState = {};
  for (const idx of indexes) {
    const state = idx.state || 'UNKNOWN';
    if (!byState[state]) byState[state] = [];
    byState[state].push(idx);
  }
  
  for (const [state, idxs] of Object.entries(byState)) {
    console.log(`--- ${state} (${idxs.length}) ---`);
    for (const idx of idxs) {
      const cg = extractCollectionGroup(idx.name);
      const fields = idx.fields
        .filter(f => f.fieldPath !== '__name__')
        .map(f => `${f.fieldPath}:${f.order || f.arrayConfig || '?'}`)
        .join(', ');
      console.log(`  ${cg} | ${fields}`);
    }
    console.log('');
  }
  
  // Count ready vs creating
  const ready = (byState['READY'] || []).length;
  const creating = (byState['CREATING'] || []).length;
  console.log(`Ready: ${ready} | Creating: ${creating} | Total: ${indexes.length}`);
}

run().catch(e => { console.error('Error:', e.message); process.exit(1); });
