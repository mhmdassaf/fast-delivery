/**
 * Firebase Rules Deployment using Admin SDK
 * Uses Firebase Admin SDK's built-in rules management
 */

const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin SDK with service account
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'fast-delivery-32739'
});

async function main() {
  console.log('='.repeat(50));
  console.log('Firebase Rules Deployment (Admin SDK)');
  console.log('='.repeat(50));
  console.log('');

  try {
    // Get Firestore to verify connection
    const db = admin.firestore();
    console.log('✓ Firebase Admin SDK initialized');

    // Test connection
    await db.collection('_admin_test').limit(1).get();
    console.log('✓ Firestore connection verified');

    console.log('\n📝 Note: Firebase Admin SDK does not support programmatic rules deployment.');
    console.log('   You have two options:\n');

    console.log('   Option 1: Firebase Console (Manual)');
    console.log('   1. Go to https://console.firebase.google.com/project/fast-delivery-32739/firestore');
    console.log('   2. Click "Rules" tab');
    console.log('   3. Copy contents of firestore.rules file');
    console.log('   4. Paste and click "Publish"\n');

    console.log('   Option 2: Firebase CLI (After login)');
    console.log('   Run in your terminal:');
    console.log('   $ firebase login');
    console.log('   $ firebase deploy --only firestore:rules --project fast-delivery-32739\n');

    console.log('='.repeat(50));
    console.log('The Firestore rules content:');
    console.log('='.repeat(50));
    console.log(fs.readFileSync('./firestore.rules', 'utf8'));

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    if (error.code === 'PERMISSION_DENIED') {
      console.log('\nThe service account lacks Firestore permissions.');
      console.log('Grant Editor role to the service account in Firebase Console:');
      console.log('IAM & Admin → Grant access → Add member with "Editor" role');
    }
  }
}

main();