import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';

class DeveloperService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static const String _developersCollection = 'developers';

  DeveloperService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<List<String>> watchDeveloperEmails() {
    return _firestore
        .collection(_developersCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<List<String>> getDeveloperEmails() async {
    final snapshot =
        await _firestore.collection(_developersCollection).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<bool> isDeveloperEmail(String email) async {
    final doc =
        await _firestore.collection(_developersCollection).doc(email).get();
    return doc.exists;
  }

  Future<void> ensureDefaultDevelopers() async {
    const defaultDevs = [
      'habte.selase.721@gmail.com',
      'bernabasgirma00@gmail.com',
    ];

    final batch = _firestore.batch();
    for (final email in defaultDevs) {
      final ref = _firestore.collection(_developersCollection).doc(email);
      final doc = await ref.get();
      if (!doc.exists) {
        batch.set(ref, {
          'addedAt': FieldValue.serverTimestamp(),
          'addedBy': 'system',
        });
      }
    }
    await batch.commit();
  }

  Future<void> addDeveloper(String email) async {
    await _firestore.collection(_developersCollection).doc(email).set({
      'addedAt': FieldValue.serverTimestamp(),
      'addedBy': _auth.currentUser?.email ?? 'unknown',
    });
  }

  Future<void> removeDeveloper(String email) async {
    await _firestore.collection(_developersCollection).doc(email).delete();

    // Also downgrade user if exists
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    for (final doc in userQuery.docs) {
      if (doc.data()['role'] == 'developer') {
        await doc.reference.update({
          'role': UserRole.admin.firestoreValue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  static const _defaultDevEmails = [
    'habte.selase.721@gmail.com',
    'bernabasgirma00@gmail.com',
  ];

  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'ግብዓት ተሰርዟል';

      final email = googleUser.email;

      // Check hardcoded list first (no Firestore read needed)
      final isDefaultDev = _defaultDevEmails.contains(email);

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase first so Firestore reads are allowed
      final userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Now check Firestore for dynamically added developers
      final isDev = isDefaultDev || await isDeveloperEmail(email);
      if (!isDev) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        return 'ይህ ኢሜይል ($email) የገንቢ ፈቃድ የለውም';
      }

      if (user != null) {
        // Ensure default developer docs exist
        await ensureDefaultDevelopers();

        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          final appUser = AppUser(
            uid: user.uid,
            email: email,
            displayName: googleUser.displayName ?? email,
            role: UserRole.developer,
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toCreateMap());
        } else {
          await _firestore.collection('users').doc(user.uid).update({
            'role': UserRole.developer.firestoreValue,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return 'Firebase error: ${e.message}';
    } catch (e) {
      return 'ስህተት: $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
