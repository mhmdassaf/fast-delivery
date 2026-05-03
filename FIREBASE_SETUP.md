# Firebase Setup Guide

This guide walks you through the Firebase configuration steps for the Fast Delivery project.

## Prerequisites

- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [Node.js 18+](https://nodejs.org/)
- A Firebase project created at [Firebase Console](https://console.firebase.google.com)

---

## Step 1: Download Firebase Configuration Files

### Android

1. Go to [Firebase Console](https://console.firebase.google.com/project/fast-delivery-32739)
2. Navigate to **Project Settings** (gear icon)
3. Scroll down to **Your apps** section
4. Click **Add app** → Select **Android**
5. Enter package name: `com.example.user_app`
6. Download `google-services.json`
7. Place it in: `apps/user_app/android/app/google-services.json`

### iOS (for future)

1. In Firebase Console, add iOS app
2. Enter bundle ID: `com.example.userApp`
3. Download `GoogleService-Info.plist`
4. Place it in: `apps/user_app/ios/Runner/GoogleService-Info.plist`

---

## Step 2: Enable Authentication Methods

1. Go to **Authentication** → **Sign-in method**
2. Click on **Email/Password**
3. Enable **Email/Password**
4. Click **Save**

For Google Sign-In:
1. Click on **Google**
2. Enable **Google**
3. For Android, you'll need to add SHA-1 fingerprint:
   ```bash
   # Get SHA-1 from your debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Add the SHA-1 to Firebase Console (Project Settings → General → Your apps → Android → SHA certificate fingerprints)
5. Click **Save**

---

## Step 3: Deploy Security Rules

Make sure you're in the project root directory:

```bash
cd fast-delivery

# Login to Firebase (if not already logged in)
firebase login

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

---

## Step 4: Update Firebase Options (Flutter)

Run the FlutterFire CLI to generate updated Firebase configuration:

```bash
cd apps/user_app

# Configure Firebase for this project
flutterfire configure --project=fast-delivery-32739

# Follow the prompts:
# - Select Android as target platform
# - Select all apps or specific app
# - Confirm package name
```

This will update `lib/core/firebase/firebase_options.dart` with actual API keys.

---

## Step 5: Initialize Cloud Functions

```bash
cd functions

# Install dependencies
npm install

# Deploy functions (requires Blaze plan on Firebase)
firebase deploy --only functions
```

---

## Step 6: Verify Setup

1. Run the app:
   ```bash
   cd apps/user_app
   flutter run
   ```

2. Test authentication:
   - Try registering a new account
   - Try logging in with existing account
   - Try Google Sign-In

---

## Troubleshooting

### "Invalid Firebase configuration"
- Ensure `google-services.json` is in the correct location
- Check that package name matches in Firebase Console and app

### "Auth/network error"
- Check that Authentication is enabled in Firebase Console
- Verify internet connection
- Check Firebase status at [status.firebase.google.com](https://status.firebase.google.com)

### "Firestore permission denied"
- Deploy security rules: `firebase deploy --only firestore:rules`
- Check that user is authenticated

### "Google Sign-In not working"
- Add SHA-1 fingerprint in Firebase Console
- Update `google-services.json` after adding SHA-1

---

## Firebase Services Used

| Service | Purpose | Status |
|---------|---------|--------|
| Firebase Auth | User authentication | ✅ Configured |
| Cloud Firestore | User profiles, orders, etc. | ✅ Configured |
| Cloud Functions | Auth triggers, callable functions | ✅ Code ready |
| Cloud Storage | File uploads (future) | ✅ Rules ready |
| Firebase Messaging | Push notifications (future) | 📋 Planned |

---

## Project Structure

```
fast-delivery/
├── firebase.json              # Firebase CLI config
├── firestore.rules             # Security rules
├── firestore.indexes.json      # Composite indexes
├── storage.rules               # Storage rules
├── functions/                  # Cloud Functions
│   ├── package.json
│   └── index.js
└── assets/
    └── keys/                   # Service account keys (gitignored)
```

---

## Security Considerations

⚠️ **Important**: Never commit service account keys or Firebase configuration files with secrets to version control.

The following files should be in `.gitignore`:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `assets/keys/*.json`

---

## Support

For issues or questions, refer to:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)