const { GoogleAuth } = require('google-auth-library');
const key = require('C:/Users/mhmd.assaf/source/repos/fast-delivery/assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const https = require('https');
const PROJECT = 'fast-delivery-32739';

function call(urlPath) {
  return new Promise((resolve, reject) => {
    const auth = new GoogleAuth({ credentials: key, scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/datastore'] });
    auth.getAccessToken().then(token => {
      const opts = {
        hostname: 'firestore.googleapis.com',
        path: '/v1/projects/' + PROJECT + '/databases/(default)' + urlPath,
        headers: { 'Authorization': 'Bearer ' + token }
      };
      https.get(opts, res => { let d=''; res.on('data',c=>d+=c); res.on('end',()=>resolve(JSON.parse(d))); });
    }).catch(reject);
  });
}

async function main() {
  const data = await call('/collectionGroups/-/indexes');
  for (const idx of (data.indexes || [])) {
    console.log(idx.collectionGroup, '| state:', idx.state, '| fields:', idx.fields.map(f => f.fieldPath+':'+f.order).join(', '));
  }
}

main().catch(e => console.error(e.message));
