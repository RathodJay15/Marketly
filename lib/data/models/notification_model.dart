import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String orderId;
  final String status;
  final bool isRead;
  final Timestamp createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.orderId,
    required this.status,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      orderId: data['orderId'] ?? '',
      status: data['status'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'],
    );
  }
}
