# Firebase API Key Configuration Fix

## Issue
Error: `An internal error has occurred. [API key not valid. Please pass a valid API key]`

## Root Cause
The `firebase_options.dart` file contained placeholder values (`YOUR_WEB_API_KEY`, `YOUR_ANDROID_API_KEY`, etc.) instead of real Firebase configuration values.

## What Was Fixed ✅

### 1. Android Configuration - FIXED
Updated `apps/user_app/lib/core/firebase/firebase_options.dart` with real values from `google-services.json`:
- **API Key**: `AIzaSyAPlmPufMDNBdpgtAfvhiuMVYR-cBAnP8U`
- **App ID**: `1:130528704034:android:34d87b3d6c1956b8947c7b`
- **Messaging Sender ID**: `130528704034`
- **Storage Bucket**: Updated to `fast-delivery-32739.firebasestorage.app`

## What You Need to Do 🔧

### Get Web API Key from Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **fast-delivery-32739**
3. Click the **⚙️ Gear Icon** → **Project Settings**
4. Scroll to **"Your apps"** section
5. **If no Web app exists**:
   - Click the **`</>` (Web)** icon to add a web app
   - Register app with nickname "user_app_web"
   - Copy the configuration
6. **If Web app already exists**:
   - Click on the Web app icon
   - Copy the `apiKey` and `appId` values

### Update `firebase_options.dart`:

Edit: `apps/user_app/lib/core/firebase/firebase_options.dart`

Replace these lines (around line 37-44):
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAPlmPufMDNBdpgtAfvhiuMVYR-cBAnP8U', // Replace with your actual Web API Key
  appId: 'YOUR_WEB_APP_ID', // Replace with your Web App ID
  messagingSenderId: '130528704034',
  projectId: 'fast-delivery-32739',
  authDomain: 'fast-delivery-32739.firebaseapp.com',
  storageBucket: 'fast-delivery-32739.firebasestorage.app',
);
```

With the real values from Firebase Console:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'REPLACE_WITH_REAL_WEB_API_KEY',
  appId: 'REPLACE_WITH_REAL_WEB_APP_ID',
  messagingSenderId: '130528704034',
  projectId: 'fast-delivery-32739',
  authDomain: 'fast-delivery-32739.firebaseapp.com',
  storageBucket: 'fast-delivery-32739.firebasestorage.app',
);
```

## For Other Apps (rider_app, seller_app, admin_panel)

You'll need to run FlutterFire CLI for each app:

```bash
# For each app directory
cd apps/rider_app
flutterfire configure

cd ../seller_app
flutterfire configure

cd ../admin_panel
flutterfire configure
```

Or manually create `firebase_options.dart` for each app using the same Firebase project configuration.

## Testing

After updating the Web API key:

1. **For Android**: The app should work now (already fixed)
2. **For Web**: Update the web config, then run `flutter run -d chrome`
3. **For iOS**: You'll need to update the iOS config similarly (add `google-service-info.plist` to iOS folder)

## Verification

The error should disappear once:
- ✅ Android API key is valid (DONE)
- ⏳ Web API key is valid (NEEDS YOUR ACTION)
- ⏳ iOS configuration is set up (if testing on iOS)

## Quick Test

Run the app on Android:
```bash
cd apps/user_app
flutter run
```

If testing on Chrome:
```bash
cd apps/user_app
flutter run -d chrome
```
(Only after updating the Web API key)
