/**
 * Firestore Seed Script
 * 
 * Seeds categories and shops data + deploys security rules.
 * Run: node functions/seed_firestore.mjs
 */
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync, writeFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const KEY_PATH = resolve(__dirname, '../assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

// Import the service account
const serviceAccount = JSON.parse(readFileSync(KEY_PATH, 'utf-8'));

// Initialize Firebase Admin
const app = initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore(app);

// ──────────────────────────────────────────────────
// Categories
// ──────────────────────────────────────────────────
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

// ──────────────────────────────────────────────────
// Shops
// ──────────────────────────────────────────────────
const shops = [
  {
    name: 'Pizza Hut',
    categoryId: null, // will be set after categories are created
    shortDescription: 'Delicious pizzas with fresh ingredients',
    tags: ['pizza', 'italian', 'cheese'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Pizza+Hut',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Pizza+Hut+Cover',
    rating: 4.5,
    ratingCount: 234,
    deliveryTime: '25-35 min',
    deliveryFee: 3.99,
    minOrderAmount: 10.0,
    isOpen: true,
    address: '123 Main St, Downtown',
    isActive: true,
  },
  {
    name: 'Domino\'s Pizza',
    categoryId: null,
    shortDescription: 'Fast delivery pizza at your door',
    tags: ['pizza', 'fast-food', 'delivery'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Dominos',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Dominos+Cover',
    rating: 4.2,
    ratingCount: 189,
    deliveryTime: '20-30 min',
    deliveryFee: 2.99,
    minOrderAmount: 8.0,
    isOpen: true,
    address: '456 Oak Ave',
    isActive: true,
  },
  {
    name: 'McDonald\'s',
    categoryId: null,
    shortDescription: 'World-famous burgers and fries',
    tags: ['burger', 'fast-food', 'fries'],
    logoUrl: 'https://via.placeholder.com/400x225?text=McDonalds',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=McDonalds+Cover',
    rating: 4.0,
    ratingCount: 567,
    deliveryTime: '15-25 min',
    deliveryFee: 1.99,
    minOrderAmount: 5.0,
    isOpen: true,
    address: '789 Broadway',
    isActive: true,
  },
  {
    name: 'Sushi Master',
    categoryId: null,
    shortDescription: 'Premium Japanese sushi & rolls',
    tags: ['sushi', 'japanese', 'fish'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Sushi+Master',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Sushi+Cover',
    rating: 4.8,
    ratingCount: 143,
    deliveryTime: '30-45 min',
    deliveryFee: 4.99,
    minOrderAmount: 15.0,
    isOpen: true,
    address: '321 Cherry Blossom Ln',
    isActive: true,
  },
  {
    name: 'Fresh Bakery',
    categoryId: null,
    shortDescription: 'Fresh bread and pastries daily',
    tags: ['bakery', 'bread', 'pastry'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Fresh+Bakery',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Bakery+Cover',
    rating: 4.6,
    ratingCount: 98,
    deliveryTime: '15-20 min',
    deliveryFee: 2.50,
    minOrderAmount: 5.0,
    isOpen: true,
    address: '555 Flour St',
    isActive: true,
  },
  {
    name: 'Sweet Treats',
    categoryId: null,
    shortDescription: 'Cakes, ice cream & desserts',
    tags: ['dessert', 'cake', 'ice-cream'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Sweet+Treats',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Sweets+Cover',
    rating: 4.7,
    ratingCount: 312,
    deliveryTime: '20-30 min',
    deliveryFee: 3.50,
    minOrderAmount: 8.0,
    isOpen: false,
    address: '777 Sugar Rd',
    isActive: true,
  },
  {
    name: 'Green Grocery',
    categoryId: null,
    shortDescription: 'Organic fruits and vegetables',
    tags: ['vegetable', 'organic', 'fresh'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Green+Grocery',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Grocery+Cover',
    rating: 4.3,
    ratingCount: 76,
    deliveryTime: '20-30 min',
    deliveryFee: 2.99,
    minOrderAmount: 10.0,
    isOpen: true,
    address: '999 Green Valley',
    isActive: true,
  },
  {
    name: 'PharmaCare',
    categoryId: null,
    shortDescription: 'Your neighborhood pharmacy',
    tags: ['pharmacy', 'health', 'medicine'],
    logoUrl: 'https://via.placeholder.com/400x225?text=PharmaCare',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Pharmacy+Cover',
    rating: 4.1,
    ratingCount: 45,
    deliveryTime: '15-25 min',
    deliveryFee: 1.50,
    minOrderAmount: 5.0,
    isOpen: true,
    address: '222 Health Blvd',
    isActive: true,
  },
  {
    name: 'Burger King',
    categoryId: null,
    shortDescription: 'Flame-grilled burgers',
    tags: ['burger', 'fast-food', 'grill'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Burger+King',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=BK+Cover',
    rating: 3.9,
    ratingCount: 421,
    deliveryTime: '15-25 min',
    deliveryFee: 2.49,
    minOrderAmount: 5.0,
    isOpen: true,
    address: '444 King Way',
    isActive: true,
  },
  {
    name: 'Sushi Time',
    categoryId: null,
    shortDescription: 'Quick and tasty sushi rolls',
    tags: ['sushi', 'japanese', 'quick'],
    logoUrl: 'https://via.placeholder.com/400x225?text=Sushi+Time',
    coverImageUrl: 'https://via.placeholder.com/1200x400?text=Sushi+Time+Cover',
    rating: 4.4,
    ratingCount: 167,
    deliveryTime: '20-35 min',
    deliveryFee: 3.99,
    minOrderAmount: 12.0,
    isOpen: true,
    address: '666 Roll Ave',
    isActive: true,
  },
];

// ──────────────────────────────────────────────────
// Main seed function
// ──────────────────────────────────────────────────
async function seed() {
  console.log('🚀 Starting Firestore seed...\n');

  // 1. Create categories
  console.log('📁 Creating categories...');
  const categoryIds = {};
  for (const cat of categories) {
    const docRef = db.collection('categories').doc();
    await docRef.set({
      ...cat,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    categoryIds[cat.name] = docRef.id;
    console.log(`  ✅ ${cat.name} → ${docRef.id}`);
  }

  // Map category names to their IDs
  const categoryMap = {
    'Pizza Hut': 'Pizza',
    'Domino\'s Pizza': 'Pizza',
    'McDonald\'s': 'Burger',
    'Burger King': 'Burger',
    'Sushi Master': 'Sushi',
    'Sushi Time': 'Sushi',
    'Fresh Bakery': 'Bakery',
    'Sweet Treats': 'Dessert',
    'Green Grocery': 'Vegetables',
    'PharmaCare': 'Pharmacy',
  };

  // 2. Create shops
  console.log('\n🏪 Creating shops...');
  for (const shop of shops) {
    const catName = categoryMap[shop.name];
    const docRef = db.collection('shops').doc();
    await docRef.set({
      ...shop,
      categoryId: categoryIds[catName] || null,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    console.log(`  ✅ ${shop.name} (${catName || 'uncategorized'}) → ${docRef.id}`);
  }

  console.log('\n✅✅✅ Seed complete! Categories and shops are ready.');

  // 3. Verify data
  console.log('\n📊 Verifying data...');
  const catsSnapshot = await db.collection('categories').count().get();
  const shopsSnapshot = await db.collection('shops').count().get();
  console.log(`  Categories: ${catsSnapshot.data().count}`);
  console.log(`  Shops: ${shopsSnapshot.data().count}`);

  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
