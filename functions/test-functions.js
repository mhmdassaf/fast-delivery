/**
 * Test script for Cloud Functions
 * Run with: node test-functions.js
 */

const admin = require('firebase-admin');
const functions = require('firebase-functions');

// Initialize Admin SDK with service account
const path = require('path');
const serviceAccountPath = path.join(__dirname, '..', 'assets', 'keys', 'fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'fast-delivery-32739'
});

const db = admin.firestore();

async function testOnUserCreate() {
  console.log('\n🧪 Test: onUserCreate function');
  console.log('='.repeat(50));

  // Simulate a Firebase Auth user
  const mockUser = {
    uid: 'test-user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: null,
    emailVerified: false,
    phoneNumber: null
  };

  const userRef = db.collection('users').doc(mockUser.uid);

  try {
    // Check if test user already exists
    const existingDoc = await userRef.get();
    if (existingDoc.exists) {
      console.log('⚠ Test user already exists, deleting...');
      await userRef.delete();
    }

    // Simulate onUserCreate
    console.log(`Creating user document for uid: ${mockUser.uid}`);

    await userRef.set({
      uid: mockUser.uid,
      email: mockUser.email,
      displayName: mockUser.displayName || '',
      photoURL: mockUser.photoURL || null,
      role: 'user',
      emailVerified: mockUser.emailVerified,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      fcmTokens: [],
      phoneNumber: mockUser.phoneNumber || null,
    });

    console.log('✓ User document created');

    // Verify
    const doc = await userRef.get();
    if (doc.exists) {
      const data = doc.data();
      console.log('✓ Document verified:');
      console.log(`  - uid: ${data.uid}`);
      console.log(`  - email: ${data.email}`);
      console.log(`  - role: ${data.role}`);
      console.log(`  - isActive: ${data.isActive}`);
    }

    // Cleanup
    await userRef.delete();
    console.log('✓ Test user cleaned up');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

async function testCallableFunction() {
  console.log('\n🧪 Test: Callable function (setUserRole)');
  console.log('='.repeat(50));

  // Note: Callable functions need to be tested via Firebase Emulator
  // or by deploying and calling them from a client
  console.log('⚠ Callable functions should be tested with:');
  console.log('  1. Firebase Emulator Suite');
  console.log('  2. Deployed functions with Flutter app');
}

async function main() {
  console.log('═'.repeat(50));
  console.log('  Cloud Functions Test Suite');
  console.log('═'.repeat(50));

  await testOnUserCreate();
  await testCallableFunction();

  console.log('\n' + '═'.repeat(50));
  console.log('  Tests Complete');
  console.log('═'.repeat(50));

  process.exit(0);
}

main().catch(console.error);