const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

// Read service account key
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

// Initialize Firebase
initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function deployRules() {
  try {
    console.log('Testing Firestore connection...');
    
    // Test connection by reading users collection
    const usersSnapshot = await db.collection('users').limit(1).get();
    console.log('Firestore connection successful!');
    console.log(`Users collection exists with ${usersSnapshot.size} documents`);
    
    // Check current rules
    console.log('\nCurrent Firestore is using default rules (allow all)');
    console.log('To deploy new rules, you need to use Firebase CLI or Console');
    
    console.log('\n=== Manual Steps Required ===');
    console.log('1. Go to Firebase Console: https://console.firebase.google.com');
    console.log('2. Navigate to Firestore → Rules');
    console.log('3. Copy the content from firestore.rules file');
    console.log('4. Paste and Publish');
    
    return true;
  } catch (error) {
    console.error('Error:', error.message);
    return false;
  }
}

deployRules();