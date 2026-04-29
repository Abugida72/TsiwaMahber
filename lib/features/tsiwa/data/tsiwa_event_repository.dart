import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_event.dart';

class TsiwaEventRepository {
  final FirebaseFirestore _firestore;

  TsiwaEventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<TsiwaEvent>> watchEvents(String areaId, String tsiwaId) {
    return _firestore
        .collection(FirestorePaths.events(areaId, tsiwaId))
        .orderBy('ethiopianYear', descending: true)
        .orderBy('ethiopianMonth', descending: true)
        .orderBy('ethiopianDay', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TsiwaEvent.fromDoc(doc)).toList());
  }

  Stream<List<TsiwaEvent>> watchRecentEvents(
      String areaId, String tsiwaId,
      {int limit = 12}) {
    return _firestore
        .collection(FirestorePaths.events(areaId, tsiwaId))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TsiwaEvent.fromDoc(doc)).toList());
  }

  Future<void> createEvent(
      String areaId, String tsiwaId, TsiwaEvent event) async {
    await _firestore
        .collection(FirestorePaths.events(areaId, tsiwaId))
        .add(event.toCreateMap());
  }

  Future<void> updateEvent(
      String areaId, String tsiwaId, TsiwaEvent event) async {
    await _firestore
        .doc(FirestorePaths.event(areaId, tsiwaId, event.id))
        .update(event.toUpdateMap());
  }

  Future<void> updateEventStatus(String areaId, String tsiwaId,
      String eventId, TsiwaEventStatus status) async {
    await _firestore
        .doc(FirestorePaths.event(areaId, tsiwaId, eventId))
        .update({
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvent(
      String areaId, String tsiwaId, String eventId) async {
    await _firestore
        .doc(FirestorePaths.event(areaId, tsiwaId, eventId))
        .delete();
  }
}
