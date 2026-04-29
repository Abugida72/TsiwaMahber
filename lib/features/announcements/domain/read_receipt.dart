import 'package:cloud_firestore/cloud_firestore.dart';

class ReadReceipt {
  final String id;
  final String userId;
  final String userName;
  final DateTime? readAt;

  const ReadReceipt({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.readAt,
  });

  factory ReadReceipt.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReadReceipt(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'readAt': FieldValue.serverTimestamp(),
    };
  }
}
