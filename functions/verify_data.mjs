/**
 * Quick verification script - checks data counts and duplicates.
 * Usage: node functions/verify_data.mjs
 */
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'fs';
import https from 'https';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const KEY_PATH = resolve(__dirname, '../assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const serviceAccount = JSON.parse(readFileSync(KEY_PATH, 'utf-8'));
const PROJECT = serviceAccount.project_id;
const API_KEY = 'AIzaSyBQMojgcMa626RRFJCYJ7r1y9AZ9vn3jPs';

const app = initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth(app);

function callFirestore(method, path, token) {
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'firestore.googleapis.com',
      path: '/v1/projects/' + PROJECT + '/databases/(default)/documents' + path,
      method,
      headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' },
    };
    const req = https.request(opts, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
      res.on('end', () => resolve({ status: res.statusCode, body: d }));
    });
    req.on('error', reject);
    req.end();
  });
}

async function getToken() {
  const customToken = await auth.createCustomToken('verify-' + Date.now());
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      path: '/v1/accounts:signInWithCustomToken?key=' + API_KEY,
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    };
    const req = https.request(opts, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
      res.on('end', () => {
        const data = JSON.parse(d);
        if (data.idToken) resolve(data.idToken);
        else reject(new Error(JSON.stringify(data)));
      });
    });
    req.on('error', reject);
    req.write(JSON.stringify({ token: customToken, returnSecureToken: true }));
    req.end();
  });
}

async function main() {
  const token = await getToken();
  console.log('🔐 Authenticated.\n');

  // Check categories
  const catRes = await callFirestore('GET', '/categories?pageSize=100', token);
  const catData = JSON.parse(catRes.body);
  const cats = catData.documents || [];
  console.log('📁 Categories (' + cats.length + '):');
  if (cats.length !== 8) console.log('  ⚠️  Expected 8, found ' + cats.length);
  for (const d of cats) {
    console.log('  ✅ ' + (d.fields?.name?.stringValue || '?'));
  }

  // Check shops
  const shopRes = await callFirestore('GET', '/shops?pageSize=100', token);
  const shopData = JSON.parse(shopRes.body);
  const shops = shopData.documents || [];
  console.log('\n🏪 Shops (' + shops.length + '):');
  if (shops.length !== 10) console.log('  ⚠️  Expected 10, found ' + shops.length);
  
  const shopNames = new Set();
  for (const d of shops) {
    const name = d.fields?.name?.stringValue || '?';
    shopNames.add(name);
    console.log('  ✅ ' + name);
  }
  
  if (shops.length !== shopNames.size) {
    console.log('\n❌ DUPLICATE SHOP NAMES FOUND! (' + shops.length + ' docs, ' + shopNames.size + ' unique names)');
  } else {
    console.log('\n✅ No duplicate shops.');
  }

  // Check menu items for each shop
  console.log('\n🍽️  Menu items per shop:');
  let totalMenuItems = 0;
  for (const d of shops) {
    const shopId = d.name.split('/').pop();
    const name = d.fields?.name?.stringValue || '?';
    const menuRes = await callFirestore('GET', '/shops/' + shopId + '/menu_items?pageSize=100', token);
    if (menuRes.status === 200) {
      const menuData = JSON.parse(menuRes.body);
      const items = menuData.documents || [];
      totalMenuItems += items.length;
      console.log('  ' + name + ': ' + items.length + ' items');
    } else {
      console.log('  ' + name + ': ❌ ' + menuRes.status);
    }
  }
  console.log('\n📊 Total menu items: ' + totalMenuItems);

  // Summary
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━');
  if (cats.length === 8 && shops.length === 10 && shops.length === shopNames.size) {
    console.log('✅✅✅ DATA IS CLEAN - No duplicates!');
  } else {
    console.log('❌ Issues found!');
  }
}

main().catch(e => { console.error('❌ Error:', e.message); process.exit(1); });
