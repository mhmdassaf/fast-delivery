const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// In production, this uses the service account automatically
// In emulator, it uses the emulator credentials
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// =============================================================================
// AUTH TRIGGERS - User Document Management
// =============================================================================

/**
 * Creates a user profile in Firestore when a new user registers via Firebase Auth
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(user.uid);

  try {
    // Check if user document already exists (for Google sign-in or re-registration)
    const existingDoc = await userRef.get();
    if (existingDoc.exists) {
      console.log(`User document already exists for uid: ${user.uid}`);
      return null;
    }

    // Create new user document with default values
    const userData = {
      uid: user.uid,
      email: user.email || "",
      displayName: user.displayName || "",
      photoURL: user.photoURL || null,
      role: "user", // Default role
      emailVerified: user.emailVerified || false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      fcmTokens: [],
      phoneNumber: user.phoneNumber || null,
    };

    await userRef.set(userData);
    console.log(`✓ User document created for uid: ${user.uid}`);
    return null;
  } catch (error) {
    console.error("❌ Error creating user document:", error);
    throw error;
  }
});

/**
 * Deletes user profile from Firestore when user account is deleted
 */
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(user.uid);

  try {
    // Delete user document
    await userRef.delete();
    console.log(`✓ User document deleted for uid: ${user.uid}`);

    // Clean up related subcollections (addresses)
    const addressesRef = userRef.collection("addresses");
    const addresses = await addressesRef.listDocuments();

    if (addresses.length > 0) {
      const batch = db.batch();
      addresses.forEach((doc) => batch.delete(doc));
      await batch.commit();
      console.log(`✓ Deleted ${addresses.length} address documents for uid: ${user.uid}`);
    }

    return null;
  } catch (error) {
    console.error("❌ Error deleting user document:", error);
    throw error;
  }
});

// =============================================================================
// CALLABLE FUNCTIONS - User Management
// =============================================================================

/**
 * Updates user role (Admin only)
 * Usage: Call from Flutter app with admin privileges
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can perform this action"
    );
  }

  const { uid, role } = data;

  // Validate input
  if (!uid || !role) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "uid and role are required"
    );
  }

  // Validate role
  const validRoles = ["user", "rider", "seller", "admin"];
  if (!validRoles.includes(role)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid role. Must be one of: user, rider, seller, admin"
    );
  }

  try {
    // Check if current user is admin
    const adminDoc = await admin
      .firestore()
      .collection("users")
      .doc(context.auth.uid)
      .get();

    if (!adminDoc.exists || adminDoc.data().role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can change user roles"
      );
    }

    // Update custom claims in Firebase Auth
    await admin.auth().setCustomUserClaims(uid, { role });

    // Update role in Firestore
    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .update({
        role,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`✓ Role updated to "${role}" for uid: ${uid}`);
    return { success: true, message: `Role updated to ${role}` };
  } catch (error) {
    console.error("❌ Error setting user role:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to update user role"
    );
  }
});

/**
 * Updates user FCM token for push notifications
 */
exports.updateFcmToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can perform this action"
    );
  }

  const { token, action = "add" } = data;
  const uid = context.auth.uid;

  if (!token) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "FCM token is required"
    );
  }

  const userRef = admin.firestore().collection("users").doc(uid);

  try {
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "User document not found"
      );
    }

    const currentTokens = userDoc.data().fcmTokens || [];

    if (action === "remove") {
      // Remove token from array
      const updatedTokens = currentTokens.filter((t) => t !== token);
      await userRef.update({
        fcmTokens: updatedTokens,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`✓ FCM token removed for uid: ${uid}`);
    } else {
      // Add token (avoid duplicates)
      if (!currentTokens.includes(token)) {
        const updatedTokens = [...currentTokens, token];
        await userRef.update({
          fcmTokens: updatedTokens,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`✓ FCM token added for uid: ${uid}`);
      } else {
        console.log(`FCM token already exists for uid: ${uid}`);
      }
    }

    return { success: true };
  } catch (error) {
    console.error("❌ Error updating FCM token:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to update FCM token"
    );
  }
});

/**
 * Updates last login timestamp
 */
exports.updateLastLogin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can perform this action"
    );
  }

  const uid = context.auth.uid;

  try {
    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .update({
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`✓ Last login updated for uid: ${uid}`);
    return { success: true };
  } catch (error) {
    console.error("❌ Error updating last login:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to update last login"
    );
  }
});

/**
 * Deactivates user account (Admin only)
 */
exports.deactivateUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can perform this action"
    );
  }

  const { uid } = data;

  if (!uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "uid is required"
    );
  }

  try {
    // Check if current user is admin
    const adminDoc = await admin
      .firestore()
      .collection("users")
      .doc(context.auth.uid)
      .get();

    if (!adminDoc.exists || adminDoc.data().role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can deactivate users"
      );
    }

    // Disable the Firebase Auth account
    await admin.auth().updateUser(uid, { disabled: true });

    // Update isActive in Firestore
    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .update({
        isActive: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`✓ User deactivated: ${uid}`);
    return { success: true, message: "User deactivated" };
  } catch (error) {
    console.error("❌ Error deactivating user:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to deactivate user"
    );
  }
});

// =============================================================================
// SCHEDULED FUNCTIONS
// =============================================================================

/**
 * Cleans up inactive user sessions (runs daily)
 */
exports.cleanupInactiveUsers = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    console.log("Running cleanup of inactive users...");
    // Implementation depends on your inactive threshold
    // Example: Delete users who haven't logged in for 90 days
    return null;
  });

// =============================================================================
// NOTIFICATION FUNCTIONS (Future)
// =============================================================================

/**
 * Sends push notification when order status changes
 * Triggered when an order document is updated
 */
exports.onOrderStatusChange = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const orderId = context.params.orderId;

    // Check if status changed
    if (before.status === after.status) {
      return null;
    }

    console.log(`Order ${orderId} status changed: ${before.status} → ${after.status}`);

    try {
      // Get user's FCM tokens
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(after.userId)
        .get();

      if (!userDoc.exists) {
        console.log(`User not found: ${after.userId}`);
        return null;
      }

      const fcmTokens = userDoc.data().fcmTokens || [];
      if (fcmTokens.length === 0) {
        console.log(`No FCM tokens for user: ${after.userId}`);
        return null;
      }

      // TODO: Implement FCM push notification
      // This requires Firebase Cloud Messaging setup
      console.log(`Would send notification to ${fcmTokens.length} tokens`);

      return null;
    } catch (error) {
      console.error("❌ Error sending notification:", error);
      return null;
    }
  });
