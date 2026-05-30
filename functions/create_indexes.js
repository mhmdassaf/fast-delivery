/**
 * Create missing Firestore composite indexes from firestore.indexes.json.
 * 
 * Usage: node functions/create_indexes.js
 */
const { GoogleAuth } = require('google-auth-library');
const fs = require('fs');
const path = require('path');
const key = require('C:/Users/mhmd.assaf/source/repos/fast-delivery/assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const https = require('https');
const PROJECT = 'fast-delivery-32739';

const auth = new GoogleAuth({ credentials: key, scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'] });

function call(method, host, pathStr, body) {
  return new Promise((resolve, reject) => {
    auth.getAccessToken().then(token => {
      const opts = { hostname: host, path: pathStr, method, headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' } };
      const req = https.request(opts, res => { let d = ''; res.on('data', c => d += c); res.on('end', () => resolve({ status: res.statusCode, body: d })); });
      req.on('error', reject); if (body) req.write(JSON.stringify(body)); req.end();
    });
  });
}

/** Convert firestore.indexes.json field config to API format */
function toApiField(f) {
  if (f.arrayConfig) {
    return { fieldPath: f.fieldPath, arrayConfig: f.arrayConfig };
  }
  return { fieldPath: f.fieldPath, order: f.order.toUpperCase() };
}

/** Create a unique key for comparing indexes */
function indexKey(idx) {
  const fields = idx.fields.map(f => f.fieldPath + ':' + (f.order || f.arrayConfig || '?')).join(';');
  return idx.collectionGroup + '|' + queryScope + '|' + fields;
}

async function run() {
  // Read index definitions from firestore.indexes.json (strip comments first)
  const indexPath = path.resolve(__dirname, '../firestore.indexes.json');
  const raw = fs.readFileSync(indexPath, 'utf-8')
    .replace(/\/\/.*$/gm, '')     // strip // line comments
    .replace(/\/\*[\s\S]*?\*\//g, ''); // strip /* */ block comments
  const config = JSON.parse(raw);
  const desired = config.indexes || [];
  console.log(`Desired indexes from firestore.indexes.json: ${desired.length}`);

  // Get existing indexes
  const r = await call('GET', 'firestore.googleapis.com', '/v1/projects/' + PROJECT + '/databases/(default)/collectionGroups/-/indexes');
  if (r.status !== 200) {
    console.error('Failed to list indexes:', r.body.substring(0, 200));
    process.exit(1);
  }
  const existing = JSON.parse(r.body).indexes || [];
  console.log(`Existing indexes in Firestore: ${existing.length}\n`);

  /** Extract collectionGroup from the index name field */
  function extractCollectionGroup(name) {
    const match = name.match(/collectionGroups\/([^/]+)/);
    return match ? match[1] : '?';
  }

  // Build a set of existing index keys
  const existingKeys = new Set();
  for (const idx of existing) {
    const cg = extractCollectionGroup(idx.name);
    const fields = idx.fields
      .filter(f => f.fieldPath !== '__name__')
      .map(f => f.fieldPath + ':' + (f.order || f.arrayConfig || '?'))
      .join(';');
    existingKeys.add(cg + '|' + fields);
  }

  // Create missing indexes
  let created = 0;
  let skipped = 0;
  for (const idx of desired) {
    const apiFields = idx.fields.map(toApiField);
    const fieldsStr = apiFields.map(f => f.fieldPath + ':' + (f.order || f.arrayConfig || '?')).join(';');
    const key = idx.collectionGroup + '|' + fieldsStr;

    if (existingKeys.has(key)) {
      console.log(`  ✓ EXISTS: ${idx.collectionGroup} | ${fieldsStr}`);
      skipped++;
      continue;
    }

    // Body must have ONLY fields and queryScope
    const body = {
      fields: apiFields,
      queryScope: idx.queryScope || 'COLLECTION',
    };

    const res = await call('POST', 'firestore.googleapis.com',
      `/v1/projects/${PROJECT}/databases/(default)/collectionGroups/${idx.collectionGroup}/indexes`, body);

    if (res.status === 200) {
      const name = JSON.parse(res.body).name;
      console.log(`  ✅ CREATED: ${idx.collectionGroup} | ${fieldsStr} → ${name.split('/').pop()}`);
      created++;
    } else if (res.status === 409) {
      console.log(`  ⚠️  CONFLICT (exists): ${idx.collectionGroup} | ${fieldsStr}`);
      skipped++;
    } else {
      console.log(`  ❌ ERROR: ${idx.collectionGroup} | ${fieldsStr}: ${res.status} ${res.body.substring(0, 150)}`);
    }
  }

  console.log(`\nSummary: ${created} created, ${skipped} skipped, ${desired.length - created - skipped} failed`);
}

run().catch(e => { console.error('Fatal:', e.message); process.exit(1); });
