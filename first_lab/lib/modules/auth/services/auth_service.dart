import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Future<bool> checkEmailExists(String email);
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<UserCredential> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  );
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> updateDisplayName(String name);
  Future<String?> getIdToken({bool forceRefresh = false});
}

class FirebaseAuthService implements AuthService {
  const FirebaseAuthService({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: 'I_KNOW_DEAR_TEACHER_DENYS_IS_BAD_PRACTICE_AT_ALL',
      );
      await cred.user?.delete();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      rethrow;
    }
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  @override
  Future<void> updateDisplayName(String name) async {
    await _firebaseAuth.currentUser?.updateDisplayName(name);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) {
    final user = _firebaseAuth.currentUser;
    if (user == null) return Future<String?>.value();
    return user.getIdToken(forceRefresh);
  }
}
