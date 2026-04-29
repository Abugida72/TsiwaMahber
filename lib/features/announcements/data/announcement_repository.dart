import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/domain/read_receipt.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore;

  AnnouncementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Announcement>> watchAnnouncements(String areaId) {
    return _firestore
        .collection(FirestorePaths.announcements(areaId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromDoc(doc))
            .toList());
  }

  Stream<Announcement?> watchAnnouncement(
      String areaId, String announcementId) {
    return _firestore
        .doc(FirestorePaths.announcement(areaId, announcementId))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Announcement.fromDoc(doc);
    });
  }

  Future<void> createAnnouncement(
      String areaId, Announcement announcement) async {
    await _firestore
        .collection(FirestorePaths.announcements(areaId))
        .add(announcement.toCreateMap());
  }

  Future<void> updateAnnouncement(
      String areaId, Announcement announcement) async {
    await _firestore
        .doc(FirestorePaths.announcement(areaId, announcement.id))
        .update(announcement.toUpdateMap());
  }

  Future<void> deleteAnnouncement(
      String areaId, String announcementId) async {
    await _firestore
        .doc(FirestorePaths.announcement(areaId, announcementId))
        .delete();
  }

  Stream<List<ReadReceipt>> watchReadReceipts(
      String areaId, String announcementId) {
    return _firestore
        .collection(
            FirestorePaths.readReceipts(areaId, announcementId))
        .orderBy('readAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReadReceipt.fromDoc(doc))
            .toList());
  }

  Future<bool> hasUserRead(
      String areaId, String announcementId, String userId) async {
    final doc = await _firestore
        .doc(FirestorePaths.readReceipt(
            areaId, announcementId, userId))
        .get();
    return doc.exists;
  }

  Stream<bool> watchHasUserRead(
      String areaId, String announcementId, String userId) {
    return _firestore
        .doc(FirestorePaths.readReceipt(
            areaId, announcementId, userId))
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> markAsRead({
    required String areaId,
    required String announcementId,
    required String userId,
    required String userName,
  }) async {
    final batch = _firestore.batch();

    final receiptRef = _firestore.doc(
        FirestorePaths.readReceipt(areaId, announcementId, userId));

    batch.set(receiptRef, ReadReceipt(
      userId: userId,
      userName: userName,
    ).toMap());

    final announcementRef = _firestore
        .doc(FirestorePaths.announcement(areaId, announcementId));
    batch.update(announcementRef, {
      'readCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Stream<int> watchUnreadCount(String areaId, String userId) {
    return _firestore
        .collection(FirestorePaths.announcements(areaId))
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      int unread = 0;
      for (final doc in snapshot.docs) {
        final receiptDoc = await _firestore
            .doc(FirestorePaths.readReceipt(
                areaId, doc.id, userId))
            .get();
        if (!receiptDoc.exists) unread++;
      }
      return unread;
    });
  }
}
