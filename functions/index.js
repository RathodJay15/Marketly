const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewProductNotification = onDocumentCreated(
  "products/{productId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const product = snap.data();
    const productId = event.params.productId;

    const message = {
      topic: "all_users",
      // token:"fB2VOMe2TOW5XgfS1e21Fj:APA91bGLK591T7ZPZ93b91wVpY90fH2UN9Dz9vGrqI3P4YzW4OWeTCqSd_i6AJXc3JaRqa5Vnkf4e-qx7Ked6FpeJ6r1f5C32WNyeOOpIK-3j-MWaQUuFFw",
      notification: {
        title: "New Product Added!!",
        body: `${product.name} is now available!`,
       },
      data: {
        type: "new_product",
        productid: productId.toString(),
      },  
    };

    try {
      await admin.messaging().send(message);
      console.log("Notification sent successfully!");
    } catch (error) {
      console.error("Error sending notification:", error);
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