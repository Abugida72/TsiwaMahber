import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  FcmService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initialize(String userId) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(userId, token);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _saveToken(userId, newToken);
      });
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    await _firestore.doc('users/$userId').update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore.doc('users/$userId').update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }

  Future<void> subscribeToArea(String areaId) async {
    await _messaging.subscribeToTopic('area_$areaId');
  }

  Future<void> unsubscribeFromArea(String areaId) async {
    await _messaging.unsubscribeFromTopic('area_$areaId');
  }
}
