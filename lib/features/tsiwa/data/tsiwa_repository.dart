import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

class TsiwaRepository {
  final FirebaseFirestore _firestore;

  TsiwaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<TsiwaMahber>> watchTsiwas(String areaId) {
    return _firestore
        .collection(FirestorePaths.tsiwaMahbers(areaId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TsiwaMahber.fromDoc(doc, areaId))
            .toList());
  }

  Stream<TsiwaMahber?> watchTsiwa(String areaId, String tsiwaId) {
    return _firestore
        .doc(FirestorePaths.tsiwaMahber(areaId, tsiwaId))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return TsiwaMahber.fromDoc(doc, areaId);
    });
  }

  Future<void> createTsiwa(String areaId, TsiwaMahber tsiwa) async {
    await _firestore
        .collection(FirestorePaths.tsiwaMahbers(areaId))
        .add(tsiwa.toCreateMap());
  }

  Future<void> updateTsiwa(String areaId, TsiwaMahber tsiwa) async {
    await _firestore
        .doc(FirestorePaths.tsiwaMahber(areaId, tsiwa.id))
        .update(tsiwa.toUpdateMap());
  }

  Future<void> deleteTsiwa(String areaId, String tsiwaId) async {
    await _firestore
        .doc(FirestorePaths.tsiwaMahber(areaId, tsiwaId))
        .delete();
  }
}
