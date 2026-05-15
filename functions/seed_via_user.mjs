/**
 * Seed script that uses Firebase Auth custom token + REST API
 * to bypass the service account IAM restriction.
 */
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'fs';
import https from 'https';
import { resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = resolve(fileURLToPath(import.meta.url), '..');
const KEY_PATH = resolve(__dirname, '../assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const serviceAccount = JSON.parse(readFileSync(KEY_PATH, 'utf-8'));
const PROJECT = serviceAccount.project_id;

// Initialize Firebase Admin (for Auth only - creating custom tokens)
const app = initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth(app);

function toFV(val) {
  if (typeof val === 'string') return { stringValue: val };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (typeof val === 'number') {
    if (Number.isInteger(val)) return { integerValue: String(val) };
    return { doubleValue: val };
  }
  if (val === null || val === undefined) return { nullValue: null };
  if (Array.isArray(val)) return { arrayValue: { values: val.map(toFV) } };
  if (val instanceof Date) return { timestampValue: val.toISOString() };
  return { nullValue: null };
}

function buildDoc(obj) {
  const fields = {};
  const now = new Date();
  for (const [k, v] of Object.entries(obj)) {
    if (k === 'id') continue;
    if (k === 'createdAt' || k === 'updatedAt') {
      fields[k] = { timestampValue: (v || now).toISOString() };
    } else {
      fields[k] = toFV(v);
    }
  }
  return { fields };
}

async function callFirestore(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'firestore.googleapis.com',
      path: '/v1/projects/' + PROJECT + '/databases/(default)/documents' + path,
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
  });
}

async function getUserIdToken(uid) {
  // Create a custom token using Admin SDK
  const customToken = await auth.createCustomToken(uid);
  
  // Exchange for ID token using Firebase Auth REST API via https
  const apiKey = 'AIzaSyAPlmPufMDNBdpgtAfvhiuMVYR-cBAnP8U';
  const body = JSON.stringify({ token: customToken, returnSecureToken: true });
  
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      path: `/v1/accounts:signInWithCustomToken?key=${apiKey}`,
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    };
    const req = https.request(opts, res => {
      let d = '';
      res.on('data', c => d += c);
      res.on('end', () => {
        const data = JSON.parse(d);
        if (data.idToken) resolve(data.idToken);
        else reject(new Error('Failed to get ID token: ' + JSON.stringify(data)));
      });
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

const categories = [
  { name: 'Pizza', icon: 'restaurant', order: 1, isActive: true },
  { name: 'Burger', icon: 'restaurant', order: 2, isActive: true },
  { name: 'Sushi', icon: 'restaurant', order: 3, isActive: true },
  { name: 'Bakery', icon: 'bakery', order: 4, isActive: true },
  { name: 'Dessert', icon: 'sweets', order: 5, isActive: true },
  { name: 'Supermarket', icon: 'supermarket', order: 6, isActive: true },
  { name: 'Pharmacy', icon: 'pharmacy', order: 7, isActive: true },
  { name: 'Vegetables', icon: 'vegetable', order: 8, isActive: true },
];

const shopTemplates = [
  { name: 'Pizza Hut', cat: 'Pizza', desc: 'Delicious pizzas with fresh ingredients', tags: ['pizza', 'italian', 'cheese'], rating: 4.5, rc: 234, time: '25-35 min', fee: 3.99, min: 10.0 },
  { name: 'Domino\'s Pizza', cat: 'Pizza', desc: 'Fast delivery pizza at your door', tags: ['pizza', 'fast-food', 'delivery'], rating: 4.2, rc: 189, time: '20-30 min', fee: 2.99, min: 8.0 },
  { name: 'McDonald\'s', cat: 'Burger', desc: 'World-famous burgers and fries', tags: ['burger', 'fast-food', 'fries'], rating: 4.0, rc: 567, time: '15-25 min', fee: 1.99, min: 5.0 },
  { name: 'Burger King', cat: 'Burger', desc: 'Flame-grilled burgers', tags: ['burger', 'fast-food', 'grill'], rating: 3.9, rc: 421, time: '15-25 min', fee: 2.49, min: 5.0 },
  { name: 'Sushi Master', cat: 'Sushi', desc: 'Premium Japanese sushi & rolls', tags: ['sushi', 'japanese', 'fish'], rating: 4.8, rc: 143, time: '30-45 min', fee: 4.99, min: 15.0 },
  { name: 'Sushi Time', cat: 'Sushi', desc: 'Quick and tasty sushi rolls', tags: ['sushi', 'japanese', 'quick'], rating: 4.4, rc: 167, time: '20-35 min', fee: 3.99, min: 12.0 },
  { name: 'Fresh Bakery', cat: 'Bakery', desc: 'Fresh bread and pastries daily', tags: ['bakery', 'bread', 'pastry'], rating: 4.6, rc: 98, time: '15-20 min', fee: 2.50, min: 5.0 },
  { name: 'Sweet Treats', cat: 'Dessert', desc: 'Cakes, ice cream & desserts', tags: ['dessert', 'cake', 'ice-cream'], rating: 4.7, rc: 312, time: '20-30 min', fee: 3.50, min: 8.0, open: false },
  { name: 'Green Grocery', cat: 'Vegetables', desc: 'Organic fruits and vegetables', tags: ['vegetable', 'organic', 'fresh'], rating: 4.3, rc: 76, time: '20-30 min', fee: 2.99, min: 10.0 },
  { name: 'PharmaCare', cat: 'Pharmacy', desc: 'Your neighborhood pharmacy', tags: ['pharmacy', 'health', 'medicine'], rating: 4.1, rc: 45, time: '15-25 min', fee: 1.50, min: 5.0 },
];

async function seed() {
  console.log('Getting auth token for seed user...');
  
  // Use a dedicated UID for seeding
  const adminUid = 'seed-admin-user-' + Date.now();
  const token = await getUserIdToken(adminUid);
  console.log('Got ID token (first 50 chars):', token.substring(0, 50) + '...\n');

  // Create user document for adminUid with admin role (rules now permissive)
  console.log('Creating seed user document...');
  let r = await callFirestore('PATCH', '/users/' + adminUid, buildDoc({
    uid: adminUid,
    email: 'seed@fast-delivery.dev',
    displayName: 'Seed Admin',
    role: 'admin',
    isActive: true,
    createdAt: new Date()
  }), token);
  console.log('User doc status:', r.status);
  
  // Create categories
  console.log('\nCreating categories...');
  const catIds = {};
  for (const cat of categories) {
    r = await callFirestore('POST', '/categories', buildDoc({
      ...cat,
      createdAt: new Date()
    }), token);
    if (r.status === 200) {
      const id = JSON.parse(r.body).name.split('/').pop();
      catIds[cat.name] = id;
      console.log('  OK', cat.name, '->', id);
    } else {
      console.log('  ERR', cat.name, ':', r.body.substring(0, 100));
    }
  }

  // Create shops
  console.log('\nCreating shops...');
  const catNameMap = {};
  shopTemplates.forEach(s => { catNameMap[s.name] = s.cat; });
  
  for (const shop of shopTemplates) {
    const catId = catIds[shop.cat];
    const shopData = {
      name: shop.name,
      categoryId: catId || null,
      shortDescription: shop.desc,
      tags: shop.tags,
      logoUrl: `https://picsum.photos/seed/${shop.name.toLowerCase().replace(/[^a-z]/g, '')}/400/225`,
      rating: shop.rating,
      ratingCount: shop.rc,
      deliveryTime: shop.time,
      deliveryFee: shop.fee,
      minOrderAmount: shop.min,
      isOpen: shop.open !== undefined ? shop.open : true,
      isActive: true,
    };
    
    r = await callFirestore('POST', '/shops', buildDoc({
      ...shopData,
      createdAt: new Date(),
      updatedAt: new Date()
    }), token);
    if (r.status === 200) {
      const id = JSON.parse(r.body).name.split('/').pop();
      console.log('  OK', shop.name, '(' + shop.cat + ') ->', id);
    } else {
      console.log('  ERR', shop.name, ':', r.body.substring(0, 100));
    }
  }

  console.log('\n✅ Seed complete!');
}

seed().catch(e => { console.error('❌ Seed failed:', e); process.exit(1); });
