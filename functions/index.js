const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewProductNotification = onDocumentUpdated(
  "products/{productId}",
  async (event) => {

    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) {
      console.log("Missing before/after data.");
      return;
    }

    // 🔥 Trigger ONLY when thumbnail is added for the first time
    if (!before.thumbnail && after.thumbnail) {

      const productId = event.params.productId;
      const productName = after.title || after.name || "New Product";
      const productImg = after.thumbnail || "";

      console.log("Thumbnail detected. Sending notification for:", productName);

      const message = {
        topic: "all_users",

        // ✅ For background & terminated state
        notification: {
          title: "New Product Added!!",
          body: `${productName} is now available!`,
          image: productImg,   // 🔥 correct key
        },

        // ✅ For foreground BigPicture handling in Flutter
        data: {
          type: "new_product",
          productid: String(productId),
          imageUrl: String(productImg),
        },
      };

      try {
        await admin.messaging().send(message);
        console.log("Notification sent successfully!");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    } else {
      console.log("No new thumbnail detected. No notification sent.");
    }
  }
);

exports.sendOrderStatusNotification = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();

      const beforeTimeline = before.statusTimeline || [];
      const afterTimeline = after.statusTimeline || [];

      if (afterTimeline.length <= beforeTimeline.length) {
        return;
      }

      const latestStatus =
        afterTimeline[afterTimeline.length - 1].status;

      const userId = after.userId;
      const orderId = event.params.orderId;

      console.log("New status detected:", latestStatus);

      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();

      if (!userDoc.exists) {
        console.log("User not found");
        return;
      }

      const tokens = userDoc.data().fcmToken;

      if (!tokens || tokens.length === 0) {
        console.log("No FCM tokens found");
        return;
      }

      const cleanStatus = latestStatus
        .replace("ORDER_", "")
        .replace(/_/g, " ");

      // Send FCM
      await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        notification: {
          title: "Order Update",
          body: `Your order is now ${cleanStatus}`,
        },
        data: {
          type: "order_update",
          orderId: orderId,
          status: latestStatus,
        },
      });

      // Store notification
      await admin.firestore().collection("notifications").add({
        userId: userId,
        title: "Order Update",
        body: `Your order is now ${cleanStatus}`,
        orderId: orderId,
        status: latestStatus,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Order status notification sent and stored!");
    } catch (error) {
      console.error("Error sending order notification:", error);
    }
  }
);
exports.notifyExpiringCarts = onSchedule("every 5 minutes", async () => {
  const db = admin.firestore();

  const now = admin.firestore.Timestamp.now();
  const tenMinutesLater = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 10 * 60 * 1000)
  );

  const snapshot = await db
    .collection("cart")
    .where("expiresAt", "<=", tenMinutesLater)
    .where("expiresAt", ">", now)
    .where("notificationSent", "==", false) // Prevent duplicates
    .get();


    
  for (const doc of snapshot.docs) {
    const userId = doc.id;

    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) continue;

      console.log("User data:", userDoc.data());  
      console.log("User data:", userDoc.data());

      const tokens = userDoc.data().fcmToken;
      
      if (!tokens || tokens.length === 0) {
        console.log("No FCM tokens found");
        continue;
      }

      // Send FCM
      await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        notification: {
          title: "Your cart is about to expire ⏳",
          body: "Only 10 minutes left! Complete your purchase now.",
        },
        data: {
          type: "cart_expiry",
        },
      });

      // Save notification in collection
      await db.collection("notifications").add({
        userId: userId,
        title: "Cart Expiring Soon",
        body: "Only 10 minutes left! Complete your purchase now.",
        type: "cart_expiry",
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Mark notification as sent
      await doc.ref.update({
        notificationSent: true,
      });

      console.log(`Cart expiry notification sent to: ${userId}`);

    } catch (error) {
      console.error("Error sending cart expiry notification:", error);
    }
  }
});

exports.cleanExpiredCarts = onSchedule("every 10 minutes", async () => {
  const now = admin.firestore.Timestamp.now();

  const snapshot = await admin.firestore()
    .collection("cart")
    .where("expiresAt", "<=", now)
    .get();

  const batch = admin.firestore().batch();

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
  }

  await batch.commit();
});