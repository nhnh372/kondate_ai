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

    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }

    return _auth.signInWithProvider(provider);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
