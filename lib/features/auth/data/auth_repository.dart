import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Member (phone+code) auth ──

  Future<AppUser> signInWithPhone(String phone, String code) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw S.phoneNotRegistered;
    }

    final doc = query.docs.first;
    final user = AppUser.fromDoc(doc);

    if (user.passwordCode != code) {
      throw S.wrongCode;
    }

    if (user.kickedOut) {
      throw S.accountKicked;
    }

    if (!user.isActive) {
      throw S.accountBlocked;
    }

    return user;
  }

  Stream<AppUser?> watchAppUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  // ── Global Member CRUD (used by devs/admins) ──

  Future<String?> createMemberAccount({
    required String displayName,
    required String phone,
    required String passwordCode,
    required String areaId,
    UserRole role = UserRole.member,
    List<String> assignedTsiwaIds = const [],
    List<String> assignedEdirIds = const [],
    Map<String, String> tsiwaRoles = const {},
    bool isEdirAmerar = false,
  }) async {
    final existing = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return S.phoneAlreadyRegistered;
    }

    final user = AppUser(
      displayName: displayName,
      phone: phone,
      passwordCode: passwordCode,
      role: role,
      areaId: areaId,
      assignedTsiwaIds: assignedTsiwaIds,
      assignedEdirIds: assignedEdirIds,
      tsiwaRoles: tsiwaRoles,
      isEdirAmerar: isEdirAmerar,
    );

    await _firestore.collection('users').add(user.toCreateMap());
    return null;
  }

  Future<String?> updateMemberFull({
    required String uid,
    required AppUser updatedUser,
  }) async {
    // Check phone uniqueness (excluding self)
    final existing = await _firestore
        .collection('users')
        .where('phone', isEqualTo: updatedUser.phone)
        .limit(2)
        .get();

    for (final doc in existing.docs) {
      if (doc.id != uid) {
        return S.phoneAlreadyRegistered;
      }
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .update(updatedUser.toFullUpdateMap());
    return null;
  }

  Future<void> updateMemberCredentials({
    required String uid,
    String? phone,
    String? passwordCode,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (phone != null) updates['phone'] = phone;
    if (passwordCode != null) updates['passwordCode'] = passwordCode;
    await _firestore.collection('users').doc(uid).update(updates);
  }

  Future<void> updateMemberAssignments({
    required String uid,
    required List<String> assignedTsiwaIds,
    required List<String> assignedEdirIds,
    required Map<String, String> tsiwaRoles,
    required bool isEdirAmerar,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'assignedTsiwaIds': assignedTsiwaIds,
      'assignedEdirIds': assignedEdirIds,
      'tsiwaRoles': tsiwaRoles,
      'isEdirAmerar': isEdirAmerar,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> kickOutUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'kickedOut': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reinstateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'kickedOut': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Profile / role management ──

  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserArea(String uid, String areaId) async {
    await _firestore.collection('users').doc(uid).update({
      'areaId': areaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppUser>> watchAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }

  Stream<List<AppUser>> watchUsersByArea(String areaId) {
    return _firestore
        .collection('users')
        .where('areaId', isEqualTo: areaId)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }

  Stream<List<AppUser>> watchMembersByTsiwa(String tsiwaId) {
    return _firestore
        .collection('users')
        .where('assignedTsiwaIds', arrayContains: tsiwaId)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }

  Stream<List<AppUser>> watchMembersByEdir(String edirId) {
    return _firestore
        .collection('users')
        .where('assignedEdirIds', arrayContains: edirId)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Batch-create multiple member accounts from CSV import.
  Future<int> batchCreateMembers(List<AppUser> members) async {
    int created = 0;
    final batch = _firestore.batch();

    for (final member in members) {
      final ref = _firestore.collection('users').doc();
      batch.set(ref, member.toCreateMap());
      created++;
    }

    await batch.commit();
    return created;
  }

  // ── Firebase Auth (devs only) ──

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
