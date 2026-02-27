import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketly/data/models/notification_model.dart';

class UserNotificationServices {
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppNotification.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> markAsRead(String id) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});
  }
}
