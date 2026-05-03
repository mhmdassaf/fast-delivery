# Fast Delivery - Cloud Functions

This directory contains Firebase Cloud Functions for the Fast Delivery app.

## 📦 Available Functions

### Auth Triggers
- **`onUserCreate`** - Creates a Firestore user document when a new user registers
- **`onUserDelete`** - Cleans up Firestore data when a user is deleted

### Callable Functions
- **`setUserRole`** - Updates user role (Admin only)
- **`updateFcmToken`** - Manages FCM tokens for push notifications
- **`updateLastLogin`** - Updates last login timestamp
- **`deactivateUser`** - Deactivates a user account (Admin only)

### Firestore Triggers
- **`onOrderStatusChange`** - Sends push notifications on order status changes

### Scheduled Functions
- **`cleanupInactiveUsers`** - Runs daily to clean up inactive sessions

## 🚀 Development

### Prerequisites
- Node.js 20+
- Firebase CLI
- Service account key in `../assets/keys/`

### Install Dependencies
```bash
npm install
```

### Run Emulator
```bash
firebase emulators:start --only functions
```

### Deploy
```bash
firebase deploy --only functions --project fast-delivery-32739
```

## 📝 Notes

- Functions use Firebase Admin SDK for server-side operations
- Custom claims are set for role-based access control
- FCM tokens are stored in user documents for push notifications
- All functions include error handling and logging

## 🔐 Security

- Only authenticated users can call callable functions
- Admin-only functions check the `role` field in Firestore
- User document creation is automatic via Auth trigger
