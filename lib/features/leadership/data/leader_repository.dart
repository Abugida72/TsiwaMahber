import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';

class LeaderRepository {
  final FirebaseFirestore _firestore;

  LeaderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Leader>> watchLeaders(String areaId) {
    return _firestore
        .collection(FirestorePaths.leaders(areaId))
        .orderBy('role')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Leader.fromDoc(doc)).toList());
  }

  Stream<Leader?> watchLeader(String areaId, String leaderId) {
    return _firestore
        .doc(FirestorePaths.leader(areaId, leaderId))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Leader.fromDoc(doc);
    });
  }

  Future<void> createLeader(String areaId, Leader leader) async {
    await _firestore
        .collection(FirestorePaths.leaders(areaId))
        .add(leader.toCreateMap());
  }

  Future<void> updateLeader(String areaId, Leader leader) async {
    await _firestore
        .doc(FirestorePaths.leader(areaId, leader.id))
        .update(leader.toUpdateMap());
  }

  Future<void> deleteLeader(String areaId, String leaderId) async {
    await _firestore
        .doc(FirestorePaths.leader(areaId, leaderId))
        .delete();
  }
}
