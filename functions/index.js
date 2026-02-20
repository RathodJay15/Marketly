const { onDocumentCreated } = require("firebase-functions/v2/firestore");
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
      data: {
        type: "new_product",
        productid: productId,
        title: "New Product Added 🛍",
        body: `${product.name} is now available!`,
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
