import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_collection_names.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> saveCurrentUser(User user) async {
    await _firestore.collection(FirestoreCollectionNames.users).doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFavorite(
    String userId,
    Map<String, dynamic> recipe,
  ) async {
    final recipeId = _resolveRecipeId(recipe);

    await _favoritesCollection(userId).doc(recipeId).set({
      ...recipe,
      'id': recipeId,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': recipe['createdAt'] ?? FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final snapshot = await _favoritesCollection(userId).get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCurrentUserFavorites() async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    return getFavorites(userId);
  }

  Future<void> deleteFavorite(String userId, String recipeId) async {
    await _favoritesCollection(userId).doc(recipeId).delete();
  }

  CollectionReference<Map<String, dynamic>> _favoritesCollection(
    String userId,
  ) {
    return _firestore
        .collection(FirestoreCollectionNames.users)
        .doc(userId)
        .collection(FirestoreCollectionNames.favorites);
  }

  String _resolveRecipeId(Map<String, dynamic> recipe) {
    final id = recipe['id'] ?? recipe['recipeId'];

    if (id is String && id.isNotEmpty) {
      return id;
    }

    throw ArgumentError('recipeにはidまたはrecipeIdが必要です');
  }
}
