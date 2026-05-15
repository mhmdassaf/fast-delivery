const { GoogleAuth } = require('google-auth-library');
const key = require('C:/Users/mhmd.assaf/source/repos/fast-delivery/assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const https = require('https');
const PROJECT = 'fast-delivery-32739';

function call(method, urlPath, body) {
  return new Promise((resolve, reject) => {
    const auth = new GoogleAuth({
      credentials: key,
      scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/datastore']
    });
    auth.getAccessToken().then(token => {
      const opts = {
        hostname: 'firestore.googleapis.com',
        path: '/v1/projects/' + PROJECT + '/databases/(default)' + urlPath,
        method,
        headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' }
      };
      const req = https.request(opts, res => {
        let d = '';
        res.on('data', c => d += c);
        res.on('end', () => resolve({ status: res.statusCode, body: d }));
      });
      req.on('error', reject);
      if (body) req.write(JSON.stringify(body));
      req.end();
    }).catch(reject);
  });
}

const indexDefs = [
  // 1. Categories: isActive ASC, order ASC
  { collection: 'categories', body: { queryScope: 'COLLECTION', fields: [
    { fieldPath: 'isActive', order: 'ASCENDING' },
    { fieldPath: 'order', order: 'ASCENDING' }]
  }},
  // 2. Shops: isActive ASC, createdAt DESC (base)
  { collection: 'shops', body: { queryScope: 'COLLECTION', fields: [
    { fieldPath: 'isActive', order: 'ASCENDING' },
    { fieldPath: 'createdAt', order: 'DESCENDING' }]
  }},
  // 3. Shops: isActive ASC, categoryId ASC, createdAt DESC (category filter)
  { collection: 'shops', body: { queryScope: 'COLLECTION', fields: [
    { fieldPath: 'isActive', order: 'ASCENDING' },
    { fieldPath: 'categoryId', order: 'ASCENDING' },
    { fieldPath: 'createdAt', order: 'DESCENDING' }]
  }},
  // 4. Shops: isActive ASC, isOpen ASC, createdAt DESC (open now filter)
  { collection: 'shops', body: { queryScope: 'COLLECTION', fields: [
    { fieldPath: 'isActive', order: 'ASCENDING' },
    { fieldPath: 'isOpen', order: 'ASCENDING' },
    { fieldPath: 'createdAt', order: 'DESCENDING' }]
  }},
  // 5. Shops: isActive ASC, categoryId ASC, isOpen ASC, createdAt DESC
  { collection: 'shops', body: { queryScope: 'COLLECTION', fields: [
    { fieldPath: 'isActive', order: 'ASCENDING' },
    { fieldPath: 'categoryId', order: 'ASCENDING' },
    { fieldPath: 'isOpen', order: 'ASCENDING' },
    { fieldPath: 'createdAt', order: 'DESCENDING' }]
  }}
];

async function main() {
  // List existing indexes
  console.log('Listing existing indexes...');
  const listRes = await call('GET', '/collectionGroups/-/indexes');
  const list = JSON.parse(listRes.body);
  const existingByName = {};
  for (const idx of (list.indexes || [])) {
    const sig = idx.fields.map(f => f.fieldPath + ':' + f.order).sort().join('|');
    existingByName[sig] = idx;
    console.log('  Existing:', idx.collectionGroup, 'state:', idx.state, 'sig:', sig);
  }

  for (const def of indexDefs) {
    const sig = def.body.fields.map(f => f.fieldPath + ':' + f.order).sort().join('|');
    
    if (existingByName[sig]) {
      console.log('  SKIP (exists):', def.collection, '->', sig);
      continue;
    }

    console.log('  Creating:', def.collection, '->', sig);
    const createRes = await call('POST', '/collectionGroups/' + def.collection + '/indexes', def.body);
    if (createRes.status === 200) {
      const data = JSON.parse(createRes.body);
      console.log('    OK:', data.name, 'state:', data.state);
    } else {
      console.log('    ERR:', createRes.body.substring(0, 300));
    }
  }

  console.log('\nDone! Indexes that are CREATING will take a few minutes to build.');
  console.log('The app will automatically use them once ready.');
}

main().catch(e => { console.error('Error:', e.message); process.exit(1); });
