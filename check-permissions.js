/**
 * Check service account permissions for Firebase Rules API
 */

const admin = require('firebase-admin');
const fetch = require('node-fetch');
const crypto = require('crypto');

// Initialize Firebase Admin SDK with service account
const serviceAccount = require('./assets/keys/fast-delivery-32739-firebase-adminsdk-fbsvc-0547c726e6.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'fast-delivery-32739'
});

const projectId = 'fast-delivery-32739';

/**
 * Get access token using JWT assertion
 */
async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const expiry = now + 3600;

  const header = Buffer.from(JSON.stringify({
    alg: 'RS256',
    typ: 'JWT'
  })).toString('base64url');

  const payload = Buffer.from(JSON.stringify({
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: expiry,
    scope: 'https://www.googleapis.com/auth/cloud-platform'
  })).toString('base64url');

  const sign = crypto.createSign('RSA-SHA256');
  sign.update(`${header}.${payload}`);
  const signature = sign.sign(serviceAccount.private_key, 'base64url');

  const assertion = `${header}.${payload}.${signature}`;

  const postData = `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${encodeURIComponent(assertion)}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(postData)
    },
    body: postData
  });

  const result = await response.json();
  return result.access_token;
}

async function main() {
  console.log('Checking Firebase Rules API permissions...\n');

  try {
    const accessToken = await getAccessToken();
    console.log('✓ Got access token');

    // Try to list existing rulesets
    const response = await fetch(
      `https://firebaserules.googleapis.com/v1/projects/${projectId}/rulesets`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      }
    );

    console.log(`\nAPI Response Status: ${response.status}`);

    if (response.status === 403) {
      console.log('\n❌ PERMISSION DENIED');
      console.log('\nThe service account needs the "Firebase Rules Admin" role.');
      console.log('\nTo fix this, in Firebase Console:');
      console.log('1. Go to IAM & Admin → IAM');
      console.log('2. Find your service account:');
      console.log(`   ${serviceAccount.client_email}`);
      console.log('3. Click the pencil/edit icon');
      console.log('4. Add Role: "Firebase Rules Admin"');
      console.log('5. Save');
      console.log('\nThen re-run this script.');
    } else if (response.ok) {
      const data = await response.json();
      console.log('\n✓ Service account has Rules API access!');
      console.log(`Found ${data.rulesets?.length || 0} existing rulesets`);
    } else {
      const error = await response.text();
      console.log(`\nError: ${error}`);
    }

  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

main();