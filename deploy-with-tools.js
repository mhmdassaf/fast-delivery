/**
 * Firebase Rules Deployment using Firebase Tools API
 */

const firebaseTools = require('C:/Users/mhmd.assaf/AppData/Roaming/npm/node_modules/firebase-tools');
const fs = require('fs');

async function main() {
  console.log('='.repeat(50));
  console.log('Firebase Rules Deployment (Firebase Tools)');
  console.log('='.repeat(50));
  console.log('');

  try {
    // Deploy Firestore rules
    console.log('Deploying Firestore security rules...');
    const firestoreRules = fs.readFileSync('./firestore.rules', 'utf8');

    await firebaseTools.deploy({
      project: 'fast-delivery-32739',
      force: true
    }, ['firestore:deploy']);

    console.log('✓ Firestore rules deployed!\n');

    // Deploy Firestore indexes
    console.log('Deploying Firestore indexes...');
    await firebaseTools.firestore.indexes.push('./firestore.indexes.json', {
      project: 'fast-delivery-32739'
    });
    console.log('✓ Firestore indexes deployed!\n');

    // Deploy Storage rules
    console.log('Deploying Storage security rules...');
    await firebaseTools.deploy({
      project: 'fast-delivery-32739',
      force: true
    }, ['storage:deploy']);

    console.log('✓ Storage rules deployed!\n');

    console.log('='.repeat(50));
    console.log('🎉 All Firebase rules deployed successfully!');
    console.log('='.repeat(50));

  } catch (error) {
    console.error('\n❌ Deployment failed:', error.message);
    console.log('\nNote: Firebase Tools may require interactive login.');
    console.log('Run: firebase login');
  }
}

main();