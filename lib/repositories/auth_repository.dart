import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> signInWithGoogle() {
    final provider = GoogleAuthProvider();
    final options = _auth.app.options;

    debugPrint('Googleログイン開始 projectId: ${options.projectId}');
    debugPrint('Googleログイン開始 appId: ${options.appId}');
    debugPrint('Googleログイン開始 authDomain: ${options.authDomain}');

    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }

    return _auth.signInWithProvider(provider);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
