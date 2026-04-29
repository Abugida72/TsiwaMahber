import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/area/domain/area.dart';

class AreaRepository {
  final FirebaseFirestore _firestore;

  AreaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<Area?> watchArea(String areaId) {
    return _firestore
        .doc(FirestorePaths.area(areaId))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Area.fromDoc(doc);
    });
  }

  Future<void> ensureDefaultArea() async {
    final docRef = _firestore.doc(
      FirestorePaths.area(AppConstants.defaultAreaId),
    );
    final doc = await docRef.get();
    if (!doc.exists) {
      const defaultArea = Area(
        id: '',
        name: AppConstants.defaultAreaName,
        shortName: AppConstants.defaultAreaShortName,
        location: AppConstants.defaultAreaLocation,
        description: AppConstants.defaultAreaDescription,
      );
      await docRef.set(defaultArea.toCreateMap());
    }
  }

  Future<void> updateArea(Area area) async {
    await _firestore
        .doc(FirestorePaths.area(area.id))
        .update(area.toUpdateMap());
  }
}
