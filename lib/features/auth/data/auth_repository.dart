import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'ያልተጠበቀ ስህተት: $e';
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String displayName,
    String phone = '',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);

        final appUser = AppUser(
          uid: user.uid,
          email: email,
          displayName: displayName,
          phone: phone,
          role: UserRole.viewer,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toCreateMap());
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'ያልተጠበቀ ስህተት: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'ያልተጠበቀ ስህተት: $e';
    }
  }

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

    await _auth.currentUser?.updateDisplayName(displayName);
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role.firestoreValue,
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

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ተጠቃሚ አልተገኘም';
      case 'wrong-password':
        return 'የተሳሳተ ይለፍ ቃል';
      case 'email-already-in-use':
        return 'ይህ ኢሜይል አስቀድሞ ተመዝግቧል';
      case 'weak-password':
        return 'ይለፍ ቃል ደካማ ነው (ቢያንስ 6 ቁምፊ)';
      case 'invalid-email':
        return 'ትክክለኛ ኢሜይል ያስገቡ';
      case 'invalid-credential':
        return 'ኢሜይል ወይም ይለፍ ቃል ትክክል አይደለም';
      case 'too-many-requests':
        return 'በጣም ብዙ ሙከራ — ትንሽ ቆይተው ይሞክሩ';
      case 'network-request-failed':
        return 'የኢንተርኔት ግንኙነት ያረጋግጡ';
      default:
        return 'ስህተት: $code';
    }
  }
}
