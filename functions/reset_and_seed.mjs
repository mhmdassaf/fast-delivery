/**
 * Reset & Re-Seed Script
 * 
 * Deletes ALL documents from categories, shops (with menu_items subcollections),
 * and users collections, then re-seeds fresh data.
 * 
 * Prerequisites: Permissive dev rules must be deployed (run deploy_dev_rules.js first).
 * 
 * Usage: node functions/reset_and_seed.mjs
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

// Initialize Firebase Admin (for Auth only)
const app = initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth(app);

// ─── HTTP Helpers ─────────────────────────────────────────────

function callFirestore(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'firestore.googleapis.com',
      path: '/v1/projects/' + PROJECT + '/databases/(default)/documents' + path,
      method,
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json',
      },
    };
    const req = https.request(opts, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
      res.on('end', () => resolve({ status: res.statusCode, body: d }));
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

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

async function getUserIdToken(uid) {
  const customToken = await auth.createCustomToken(uid);
  const body = JSON.stringify({ token: customToken, returnSecureToken: true });
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      path: `/v1/accounts:signInWithCustomToken?key=${API_KEY}`,
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    };
    const req = https.request(opts, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
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

// ─── Delete Helpers ──────────────────────────────────────────

async function deleteAllDocs(collectionPath, token) {
  // Fetch all documents
  const r = await callFirestore('GET', `${collectionPath}?pageSize=500`, null, token);
  if (r.status !== 200) {
    console.log(`  ⚠️  Cannot list ${collectionPath}: ${r.status} — skipping.`);
    return 0;
  }
  const data = JSON.parse(r.body);
  const docs = data.documents || [];
  if (docs.length === 0) return 0;

  let count = 0;
  for (const doc of docs) {
    const docId = doc.name.split('/').pop();
    const docPath = `${collectionPath}/${docId}`;
    
    // Check for subcollections by trying to list menu_items
    const subR = await callFirestore('GET', `${docPath}/menu_items?pageSize=500`, null, token);
    if (subR.status === 200) {
      const subData = JSON.parse(subR.body);
      const subDocs = subData.documents || [];
      for (const subDoc of subDocs) {
        const subId = subDoc.name.split('/').pop();
        const delR = await callFirestore('DELETE', `${docPath}/menu_items/${subId}`, null, token);
        if (delR.status === 200) count++;
        else console.log(`    ⚠️  Failed to delete menu_item ${subId}: ${delR.status}`);
      }
      if (subDocs.length > 0) {
        console.log(`  🗑️  Deleted ${subDocs.length} menu_items from ${docId}`);
      }
    }

    // Delete the document itself
    const delR = await callFirestore('DELETE', docPath, null, token);
    if (delR.status === 200) {
      count++;
    } else {
      console.log(`  ⚠️  Failed to delete ${docId}: ${delR.status} ${delR.body.substring(0, 100)}`);
    }

    if (count % 10 === 0) process.stdout.write('.');
  }
  return docs.length;
}

// ─── Seed Data ────────────────────────────────────────────────

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
  { name: 'Pizza Hut', cat: 'Pizza', desc: 'Delicious pizzas with fresh ingredients', tags: ['pizza', 'italian', 'cheese'], rating: 4.5, rc: 234, time: '25-35 min', fee: 3.99, min: 10.0, logo: 'https://picsum.photos/seed/pizzahut/400/225' },
  { name: "Domino's Pizza", cat: 'Pizza', desc: 'Fast delivery pizza at your door', tags: ['pizza', 'fast-food', 'delivery'], rating: 4.2, rc: 189, time: '20-30 min', fee: 2.99, min: 8.0, logo: 'https://picsum.photos/seed/dominos/400/225' },
  { name: "McDonald's", cat: 'Burger', desc: 'World-famous burgers and fries', tags: ['burger', 'fast-food', 'fries'], rating: 4.0, rc: 567, time: '15-25 min', fee: 1.99, min: 5.0, logo: 'https://picsum.photos/seed/mcdonalds/400/225' },
  { name: 'Burger King', cat: 'Burger', desc: 'Flame-grilled burgers', tags: ['burger', 'fast-food', 'grill'], rating: 3.9, rc: 421, time: '15-25 min', fee: 2.49, min: 5.0, logo: 'https://picsum.photos/seed/burgerking/400/225' },
  { name: 'Sushi Master', cat: 'Sushi', desc: 'Premium Japanese sushi & rolls', tags: ['sushi', 'japanese', 'fish'], rating: 4.8, rc: 143, time: '30-45 min', fee: 4.99, min: 15.0, logo: 'https://picsum.photos/seed/sushimaster/400/225' },
  { name: 'Sushi Time', cat: 'Sushi', desc: 'Quick and tasty sushi rolls', tags: ['sushi', 'japanese', 'quick'], rating: 4.4, rc: 167, time: '20-35 min', fee: 3.99, min: 12.0, logo: 'https://picsum.photos/seed/sushitime/400/225' },
  { name: 'Fresh Bakery', cat: 'Bakery', desc: 'Fresh bread and pastries daily', tags: ['bakery', 'bread', 'pastry'], rating: 4.6, rc: 98, time: '15-20 min', fee: 2.50, min: 5.0, logo: 'https://picsum.photos/seed/freshbakery/400/225' },
  { name: 'Sweet Treats', cat: 'Dessert', desc: 'Cakes, ice cream & desserts', tags: ['dessert', 'cake', 'ice-cream'], rating: 4.7, rc: 312, time: '20-30 min', fee: 3.50, min: 8.0, logo: 'https://picsum.photos/seed/sweettreats/400/225', open: false },
  { name: 'Green Grocery', cat: 'Vegetables', desc: 'Organic fruits and vegetables', tags: ['vegetable', 'organic', 'fresh'], rating: 4.3, rc: 76, time: '20-30 min', fee: 2.99, min: 10.0, logo: 'https://picsum.photos/seed/greengrocery/400/225' },
  { name: 'PharmaCare', cat: 'Pharmacy', desc: 'Your neighborhood pharmacy', tags: ['pharmacy', 'health', 'medicine'], rating: 4.1, rc: 45, time: '15-25 min', fee: 1.50, min: 5.0, logo: 'https://picsum.photos/seed/pharmacare/400/225' },
];

const menuTemplates = {
  'Pizza Hut': [
    { name: 'Margherita Pizza', description: 'Classic tomato sauce, mozzarella, fresh basil', price: 9.99, category: 'Classic Pizzas', order: 1 },
    { name: 'Pepperoni Pizza', description: 'Loaded with pepperoni and melted mozzarella', price: 11.99, category: 'Classic Pizzas', order: 2, isPopular: true },
    { name: 'BBQ Chicken Pizza', description: 'Grilled chicken, BBQ sauce, red onions, cilantro', price: 13.99, category: 'Specialty Pizzas', order: 1 },
    { name: 'Veggie Supreme', description: 'Bell peppers, mushrooms, olives, onions, tomatoes', price: 12.49, category: 'Specialty Pizzas', order: 2 },
    { name: 'Meat Lovers', description: 'Pepperoni, sausage, bacon, ham, ground beef', price: 15.99, category: 'Specialty Pizzas', order: 3, isPopular: true },
    { name: 'Garlic Breadsticks', description: 'Oven-baked with garlic butter, parmesan', price: 4.99, category: 'Sides', order: 1 },
    { name: 'Buffalo Wings (6pc)', description: 'Crispy wings tossed in buffalo sauce', price: 7.99, category: 'Sides', order: 2 },
    { name: 'Chocolate Lava Cake', description: 'Warm chocolate cake with molten center', price: 5.99, category: 'Desserts', order: 1 },
    { name: 'Pepsi (2L)', description: 'Chilled Pepsi 2-liter bottle', price: 2.99, category: 'Drinks', order: 1 },
    { name: 'Garlic Dip', description: 'Creamy garlic dipping sauce', price: 0.99, category: 'Extras', order: 1 },
  ],
  "Domino's Pizza": [
    { name: 'Cheese Pizza', description: 'Mozzarella and provolone on hand-tossed crust', price: 7.99, category: 'Pizzas', order: 1 },
    { name: 'Pepperoni Pizza', description: 'Classic pepperoni with extra mozzarella', price: 9.99, category: 'Pizzas', order: 2, isPopular: true },
    { name: 'Hawaiian Pizza', description: 'Ham, pineapple, mozzarella cheese', price: 10.99, category: 'Pizzas', order: 3 },
    { name: 'Philly Steak Pizza', description: 'Steak, green peppers, onions, provolone', price: 13.49, category: 'Specialty Pizzas', order: 1, isPopular: true },
    { name: 'ExtravaganZZa', description: 'Pepperoni, ham, Italian sausage, beef, onions', price: 14.99, category: 'Specialty Pizzas', order: 2 },
    { name: 'Chicken Alfredo Pasta', description: 'Creamy alfredo with grilled chicken', price: 8.99, category: 'Pasta', order: 1 },
    { name: 'Breadsticks (8pc)', description: 'Seasoned with garlic and herbs', price: 4.49, category: 'Sides', order: 1 },
    { name: 'Cinna Sticks', description: 'Sweet cinnamon twists with icing dip', price: 5.49, category: 'Desserts', order: 1 },
    { name: 'Coke (2L)', description: 'Chilled Coca-Cola 2-liter', price: 2.99, category: 'Drinks', order: 1 },
  ],
  "McDonald's": [
    { name: 'Big Mac', description: 'Two beef patties, special sauce, lettuce, cheese', price: 5.99, category: 'Burgers', order: 1, isPopular: true },
    { name: 'Quarter Pounder with Cheese', description: 'Quarter-pound beef patty, cheese, pickles', price: 6.49, category: 'Burgers', order: 2 },
    { name: 'McChicken', description: 'Crispy chicken patty with lettuce and mayo', price: 4.49, category: 'Chicken', order: 1 },
    { name: '10pc Chicken McNuggets', description: 'Crispy chicken nuggets with your choice of dip', price: 5.99, category: 'Chicken', order: 2, isPopular: true },
    { name: 'Filet-O-Fish', description: 'Fish fillet with tartar sauce and cheese', price: 4.99, category: 'Burgers', order: 3 },
    { name: 'World Famous Fries (Large)', description: 'Golden, crispy, salted fries', price: 3.49, category: 'Sides', order: 1, isPopular: true },
    { name: 'McFlurry with Oreo', description: 'Soft serve with crushed Oreo pieces', price: 3.99, category: 'Desserts', order: 1 },
    { name: 'Apple Pie', description: 'Warm baked apple pastry', price: 1.99, category: 'Desserts', order: 2 },
    { name: 'Coca-Cola (Medium)', description: 'Classic Coca-Cola fountain drink', price: 1.99, category: 'Drinks', order: 1 },
    { name: 'Milkshake (Chocolate)', description: 'Creamy chocolate milkshake', price: 3.49, category: 'Drinks', order: 2 },
  ],
  'Burger King': [
    { name: 'Whopper', description: 'Flame-grilled beef, tomatoes, lettuce, mayo, pickles', price: 6.29, category: 'Burgers', order: 1, isPopular: true },
    { name: 'Double Whopper', description: 'Two flame-grilled beef patties, all toppings', price: 8.49, category: 'Burgers', order: 2 },
    { name: 'Impossible Whopper', description: 'Plant-based patty with all the classic toppings', price: 7.29, category: 'Burgers', order: 3 },
    { name: 'Chicken Fries (9pc)', description: 'Crispy chicken fries with dipping sauce', price: 4.99, category: 'Chicken', order: 1, isPopular: true },
    { name: 'Original Chicken Sandwich', description: 'Crispy chicken with lettuce and mayo', price: 5.49, category: 'Chicken', order: 2 },
    { name: 'Onion Rings', description: 'Crispy battered onion rings', price: 3.49, category: 'Sides', order: 1 },
    { name: 'French Fries (Large)', description: 'Hot and crispy salted fries', price: 3.29, category: 'Sides', order: 2 },
    { name: "Hershey's Sundae Pie", description: 'Chocolate and vanilla layered dessert', price: 2.49, category: 'Desserts', order: 1 },
    { name: 'Sprite (Medium)', description: 'Crisp lemon-lime soda', price: 1.99, category: 'Drinks', order: 1 },
  ],
  'Sushi Master': [
    { name: 'California Roll (8pc)', description: 'Crab, avocado, cucumber inside-out roll', price: 8.99, category: 'Maki Rolls', order: 1, isPopular: true },
    { name: 'Spicy Tuna Roll (8pc)', description: 'Fresh tuna with spicy mayo and cucumber', price: 10.99, category: 'Maki Rolls', order: 2, isPopular: true },
    { name: 'Salmon Avocado Roll (8pc)', description: 'Fresh salmon and avocado', price: 9.99, category: 'Maki Rolls', order: 3 },
    { name: 'Dragon Roll (8pc)', description: 'Shrimp tempura, cucumber, eel sauce', price: 13.99, category: 'Special Rolls', order: 1 },
    { name: 'Rainbow Roll (8pc)', description: 'Assorted fresh fish over California roll', price: 14.99, category: 'Special Rolls', order: 2 },
    { name: 'Salmon Nigiri (2pc)', description: 'Fresh salmon over seasoned rice', price: 5.99, category: 'Nigiri', order: 1 },
    { name: 'Tuna Nigiri (2pc)', description: 'Fresh tuna over seasoned rice', price: 6.99, category: 'Nigiri', order: 2 },
    { name: 'Edamame', description: 'Steamed soybeans with sea salt', price: 4.49, category: 'Appetizers', order: 1 },
    { name: 'Miso Soup', description: 'Traditional miso with tofu and seaweed', price: 3.49, category: 'Appetizers', order: 2 },
    { name: 'Green Tea Ice Cream', description: 'Creamy matcha flavored ice cream', price: 4.99, category: 'Desserts', order: 1 },
  ],
  'Sushi Time': [
    { name: 'Philadelphia Roll (8pc)', description: 'Smoked salmon, cream cheese, cucumber', price: 9.49, category: 'Maki Rolls', order: 1, isPopular: true },
    { name: 'Shrimp Tempura Roll (8pc)', description: 'Crispy shrimp tempura with avocado', price: 11.99, category: 'Maki Rolls', order: 2, isPopular: true },
    { name: 'Vegetable Roll (8pc)', description: 'Cucumber, avocado, carrot, bell pepper', price: 7.99, category: 'Maki Rolls', order: 3 },
    { name: 'Crunchy Roll (8pc)', description: 'Shrimp, avocado, tempura flakes, spicy mayo', price: 12.49, category: 'Special Rolls', order: 1 },
    { name: 'Spider Roll (8pc)', description: 'Soft shell crab, avocado, cucumber, eel sauce', price: 14.49, category: 'Special Rolls', order: 2 },
    { name: 'Chicken Teriyaki Bowl', description: 'Grilled chicken with teriyaki sauce over rice', price: 11.99, category: 'Bowls', order: 1 },
    { name: 'Gyoza (6pc)', description: 'Pan-fried pork dumplings', price: 5.99, category: 'Appetizers', order: 1 },
    { name: 'Seaweed Salad', description: 'Seasoned seaweed with sesame seeds', price: 4.49, category: 'Appetizers', order: 2 },
    { name: 'Mochi Ice Cream (3pc)', description: 'Assorted flavors of mochi ice cream', price: 5.49, category: 'Desserts', order: 1 },
    { name: 'Ramune Soda', description: 'Japanese carbonated drink', price: 3.49, category: 'Drinks', order: 1 },
  ],
  'Fresh Bakery': [
    { name: 'Croissant', description: 'Buttery, flaky French croissant', price: 3.49, category: 'Pastries', order: 1, isPopular: true },
    { name: 'Chocolate Croissant', description: 'Flaky croissant filled with dark chocolate', price: 4.29, category: 'Pastries', order: 2 },
    { name: 'Blueberry Muffin', description: 'Moist muffin with fresh blueberries', price: 3.99, category: 'Muffins', order: 1, isPopular: true },
    { name: 'Chocolate Chip Muffin', description: 'Classic muffin loaded with chocolate chips', price: 3.99, category: 'Muffins', order: 2 },
    { name: 'Sourdough Loaf', description: 'Artisan sourdough, crusty exterior, soft interior', price: 6.99, category: 'Breads', order: 1 },
    { name: 'Whole Wheat Bread', description: 'Freshly baked whole wheat sandwich bread', price: 5.49, category: 'Breads', order: 2 },
    { name: 'Cinnamon Roll', description: 'Soft roll with cinnamon sugar and cream cheese icing', price: 4.99, category: 'Pastries', order: 3, isPopular: true },
    { name: 'Bagel (Plain)', description: 'Chewy New York-style bagel', price: 2.49, category: 'Bagels', order: 1 },
    { name: 'Everything Bagel', description: 'Sesame, poppy, garlic, onion bagel', price: 2.99, category: 'Bagels', order: 2 },
    { name: 'Vanilla Latte', description: 'Espresso with steamed milk and vanilla', price: 4.99, category: 'Drinks', order: 1 },
  ],
  'Sweet Treats': [
    { name: 'Chocolate Fudge Cake', description: 'Rich three-layer chocolate fudge cake', price: 6.99, category: 'Cakes', order: 1, isPopular: true },
    { name: 'Cheesecake (New York)', description: 'Classic creamy cheesecake with graham crust', price: 7.49, category: 'Cakes', order: 2 },
    { name: 'Strawberry Shortcake', description: 'Layered sponge cake with fresh strawberries', price: 6.49, category: 'Cakes', order: 3 },
    { name: 'Chocolate Ice Cream (Scoop)', description: 'Rich Belgian chocolate ice cream', price: 3.99, category: 'Ice Cream', order: 1 },
    { name: 'Vanilla Ice Cream (Scoop)', description: 'Classic Madagascar vanilla ice cream', price: 3.49, category: 'Ice Cream', order: 2 },
    { name: 'Cookie Dough Scoop', description: 'Chocolate chip cookie dough ice cream', price: 4.49, category: 'Ice Cream', order: 3, isPopular: true },
    { name: 'Macarons (6pc)', description: 'Assorted French macarons', price: 8.99, category: 'Pastries', order: 1 },
    { name: 'Tiramisu', description: 'Coffee-soaked ladyfingers with mascarpone', price: 6.99, category: 'Cakes', order: 4, isPopular: true },
    { name: 'Hot Fudge Sundae', description: 'Vanilla ice cream with hot fudge and whipped cream', price: 5.99, category: 'Ice Cream', order: 4 },
    { name: 'Espresso', description: 'Double shot of rich espresso', price: 2.99, category: 'Drinks', order: 1 },
    { name: 'Cappuccino', description: 'Espresso with foamed milk', price: 4.49, category: 'Drinks', order: 2 },
  ],
  'Green Grocery': [
    { name: 'Organic Bananas (1lb)', description: 'Fresh organic bananas', price: 1.29, category: 'Fruits', order: 1 },
    { name: 'Organic Avocados (2pc)', description: 'Ripe Hass avocados', price: 2.99, category: 'Fruits', order: 2, isPopular: true },
    { name: 'Organic Strawberries (1lb)', description: 'Fresh picked strawberries', price: 4.99, category: 'Fruits', order: 3 },
    { name: 'Organic Mixed Greens (5oz)', description: 'Spring mix lettuce blend', price: 3.99, category: 'Vegetables', order: 1 },
    { name: 'Organic Tomatoes (3pc)', description: 'Vine-ripened Roma tomatoes', price: 2.49, category: 'Vegetables', order: 2 },
    { name: 'Organic Broccoli', description: 'Fresh broccoli crown', price: 2.29, category: 'Vegetables', order: 3 },
    { name: 'Organic Baby Spinach (5oz)', description: 'Tender young spinach leaves', price: 3.99, category: 'Vegetables', order: 4 },
    { name: 'Organic Eggs (12pk)', description: 'Cage-free organic brown eggs', price: 5.99, category: 'Dairy', order: 1, isPopular: true },
    { name: 'Organic Whole Milk (1gal)', description: 'Fresh organic whole milk', price: 6.49, category: 'Dairy', order: 2 },
    { name: 'Organic Honey (12oz)', description: 'Local raw organic honey', price: 8.99, category: 'Pantry', order: 1 },
  ],
  'PharmaCare': [
    { name: 'Vitamin C 1000mg (60ct)', description: 'Immune support supplement', price: 12.99, category: 'Vitamins', order: 1, isPopular: true },
    { name: 'Vitamin D3 2000IU (90ct)', description: 'Bone health and immune support', price: 14.99, category: 'Vitamins', order: 2 },
    { name: 'Multivitamin (60ct)', description: 'Complete daily multivitamin', price: 18.99, category: 'Vitamins', order: 3 },
    { name: 'Ibuprofen 200mg (100ct)', description: 'Pain relief and anti-inflammatory', price: 8.99, category: 'Pain Relief', order: 1 },
    { name: 'Acetaminophen 500mg (100ct)', description: 'Fever reducer and pain reliever', price: 7.49, category: 'Pain Relief', order: 2 },
    { name: 'Cold & Flu Relief (24ct)', description: 'Multi-symptom cold and flu relief', price: 11.99, category: 'Cold & Flu', order: 1 },
    { name: 'Allergy Relief 24hr (30ct)', description: 'Non-drowsy allergy relief', price: 15.99, category: 'Allergy', order: 1 },
    { name: 'Antacid Tablets (150ct)', description: 'Heartburn and acid indigestion relief', price: 9.49, category: 'Digestive', order: 1 },
    { name: 'Probiotic (30ct)', description: 'Digestive health support', price: 22.99, category: 'Digestive', order: 2 },
    { name: 'First Aid Kit (50pc)', description: 'Complete home first aid kit', price: 16.99, category: 'First Aid', order: 1 },
    { name: 'Hand Sanitizer (8oz)', description: 'Antibacterial hand sanitizer gel', price: 4.99, category: 'Personal Care', order: 1 },
  ],
};

// ─── Main ────────────────────────────────────────────────────

async function main() {
  console.log('🔐 Getting auth token...');
  const uid = 'reset-seed-admin-' + Date.now();
  const token = await getUserIdToken(uid);
  console.log('✅ Got ID token.\n');

  // ── 1. DELETE ALL DATA ──────────────────────────────────────
  console.log('🧹 STEP 1: Deleting all existing data...\n');

  // Delete shops (including their menu_items subcollections)
  console.log('Deleting shops + menu_items...');
  const shopsDeleted = await deleteAllDocs('/shops', token);
  console.log(`\n  ✅ Deleted ${shopsDeleted} shops (with their menu_items)\n`);

  // Delete categories
  console.log('Deleting categories...');
  const catsDeleted = await deleteAllDocs('/categories', token);
  console.log(`\n  ✅ Deleted ${catsDeleted} categories\n`);

  // Delete any existing seed users
  console.log('Deleting seed users...');
  const usersDeleted = await deleteAllDocs('/users', token);
  console.log(`\n  ✅ Deleted ${usersDeleted} users\n`);

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // ── 2. CREATE SEED USER ────────────────────────────────────
  console.log('👤 STEP 2: Creating seed admin user...');
  const adminUid = 'seed-admin-' + Date.now();
  const adminToken = await getUserIdToken(adminUid);
  
  let r = await callFirestore('PATCH', '/users/' + adminUid, buildDoc({
    uid: adminUid,
    email: 'seed@fast-delivery.dev',
    displayName: 'Seed Admin',
    role: 'admin',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  }), adminToken);
  console.log(`  User doc status: ${r.status} ${r.status === 200 ? '✅' : '❌'}\n`);

  // ── 3. CREATE CATEGORIES ───────────────────────────────────
  console.log('📁 STEP 3: Creating categories...');
  const catIds = {};
  for (const cat of categories) {
    r = await callFirestore('POST', '/categories', buildDoc({
      ...cat,
      createdAt: new Date(),
      updatedAt: new Date(),
    }), adminToken);
    if (r.status === 200) {
      const id = JSON.parse(r.body).name.split('/').pop();
      catIds[cat.name] = id;
      console.log(`  ✅ ${cat.name} → ${id}`);
    } else {
      console.log(`  ❌ ${cat.name}: ${r.status} ${r.body.substring(0, 100)}`);
    }
  }
  console.log('');

  // ── 4. CREATE SHOPS ────────────────────────────────────────
  console.log('🏪 STEP 4: Creating shops...');
  const shopNameToId = {};
  for (const shop of shopTemplates) {
    const catId = catIds[shop.cat];
    const shopData = {
      name: shop.name,
      categoryId: catId || null,
      shortDescription: shop.desc,
      tags: shop.tags,
      logoUrl: shop.logo,
      coverImageUrl: `https://picsum.photos/seed/${shop.name.toLowerCase().replace(/[^a-z]/g, '')}cover/1200/400`,
      rating: shop.rating,
      ratingCount: shop.rc,
      deliveryTime: shop.time,
      deliveryFee: shop.fee,
      minOrderAmount: shop.min,
      isOpen: shop.open !== undefined ? shop.open : true,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    
    r = await callFirestore('POST', '/shops', buildDoc(shopData), adminToken);
    if (r.status === 200) {
      const id = JSON.parse(r.body).name.split('/').pop();
      shopNameToId[shop.name] = id;
      console.log(`  ✅ ${shop.name} (${shop.cat}) → ${id}`);
    } else {
      console.log(`  ❌ ${shop.name}: ${r.status} ${r.body.substring(0, 100)}`);
    }
  }
  console.log('');

  // ── 5. CREATE MENU ITEMS ───────────────────────────────────
  console.log('🍽️  STEP 5: Creating menu items...');
  let totalMenuItems = 0;
  for (const [shopName, items] of Object.entries(menuTemplates)) {
    const shopId = shopNameToId[shopName];
    if (!shopId) {
      console.log(`  ⚠️  Shop "${shopName}" not found, skipping.`);
      continue;
    }

    let count = 0;
    for (const item of items) {
      r = await callFirestore('POST', `/shops/${shopId}/menu_items`, buildDoc({
        ...item,
        isAvailable: true,
        isActive: true,
        isPopular: item.isPopular || false,
        createdAt: new Date(),
        updatedAt: new Date(),
      }), adminToken);
      if (r.status === 200) {
        count++;
      } else {
        console.log(`  ❌ ${shopName}/${item.name}: ${r.status} ${r.body.substring(0, 80)}`);
      }
    }
    console.log(`  ✅ ${shopName}: ${count} menu items`);
    totalMenuItems += count;
  }

  console.log(`\n  ✅ Total: ${totalMenuItems} menu items across ${Object.keys(shopNameToId).length} shops\n`);

  // ── VERIFY ──────────────────────────────────────────────────
  console.log('📊 VERIFICATION:');
  
  // Check categories
  r = await callFirestore('GET', '/categories?pageSize=100', null, adminToken);
  if (r.status === 200) {
    const data = JSON.parse(r.body);
    const docs = data.documents || [];
    console.log(`  Categories: ${docs.length}`);
    for (const d of docs) {
      const name = d.fields?.name?.stringValue || 'unknown';
      console.log(`    - ${name}`);
    }
  }

  // Check shops
  r = await callFirestore('GET', '/shops?pageSize=100', null, adminToken);
  if (r.status === 200) {
    const data = JSON.parse(r.body);
    const docs = data.documents || [];
    console.log(`  Shops: ${docs.length}`);
    for (const d of docs) {
      const name = d.fields?.name?.stringValue || 'unknown';
      console.log(`    - ${name}`);
    }
  }

  console.log('\n🎉✅🎉✅🎉 Reset and seed complete! All data is fresh and clean.');
}

main().catch((e) => {
  console.error('❌ Failed:', e.message);
  process.exit(1);
});
