import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_meal.dart';
import 'firestore_repository.dart';
import 'repository_contracts.dart';

class FavoriteRepository implements FavoriteMealRepository {
  const FavoriteRepository({this.firestoreRepository});

  static const String _favoritesKey = 'favorites';

  final FirestoreRepository? firestoreRepository;

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<List<Map<String, dynamic>>> loadFirestoreFavoritesForCurrentUser() async {
    try {
      debugPrint('Firestoreお気に入り取得開始');
      final repository = firestoreRepository ?? FirestoreRepository();
      final userId = repository.currentUserId;

      if (userId == null) {
        debugPrint('Firestoreお気に入り取得スキップ: 未ログイン');
        return [];
      }

      final favorites = await repository.getFavorites(userId);
      final favoriteNames = favorites
          .map((favorite) => favorite['mealName'] ?? favorite['id'])
          .whereType<String>()
          .toList();

      debugPrint(
        'Firestoreお気に入り取得成功: uid=$userId, ${favorites.length}件, ${favoriteNames.join(', ')}',
      );

      return favorites;
    } catch (error) {
      debugPrint('Firestoreお気に入り取得エラー: $error');
      // Firestore取得に失敗しても、ローカルのお気に入り表示は維持する。
      return [];
    }
  }

  Future<List<String>> addFavorite(String menu) async {
    final favorites = await loadFavorites();

    if (favorites.contains(menu)) {
      await _saveFavoriteToFirestore(menu);
      return favorites;
    }

    final updatedFavorites = [...favorites, menu];
    await _saveFavorites(updatedFavorites);
    await _saveFavoriteToFirestore(menu);

    return updatedFavorites;
  }

  Future<List<String>> removeFavorite(String menu) async {
    final favorites = await loadFavorites();
    final updatedFavorites = favorites.where((item) => item != menu).toList();

    await _saveFavorites(updatedFavorites);
    await _deleteFavoriteFromFirestore(menu);

    return updatedFavorites;
  }

  Future<void> _saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<void> _saveFavoriteToFirestore(String menu) async {
    try {
      // ignore: avoid_print
      print('Firestoreお気に入り保存開始: $menu');
      final repository = firestoreRepository ?? FirestoreRepository();
      final userId = repository.currentUserId;

      if (userId == null) {
        // ignore: avoid_print
        print('Firestoreお気に入り保存スキップ: 未ログイン');
        return;
      }

      await repository.saveFavorite(userId, {
        'id': menu,
        'mealName': menu,
        'category': '献立',
      });
      // ignore: avoid_print
      print('Firestoreお気に入り保存成功: $menu');
    } catch (error) {
      // ignore: avoid_print
      print('Firestoreお気に入り保存エラー: $error');
      // Firestore保存に失敗しても、ローカルのお気に入り保存は維持する。
    }
  }

  Future<void> _deleteFavoriteFromFirestore(String menu) async {
    try {
      // ignore: avoid_print
      print('Firestoreお気に入り削除開始: $menu');
      final repository = firestoreRepository ?? FirestoreRepository();
      final userId = repository.currentUserId;

      if (userId == null) {
        // ignore: avoid_print
        print('Firestoreお気に入り削除スキップ: 未ログイン');
        return;
      }

      await repository.deleteFavorite(userId, menu);
      // ignore: avoid_print
      print('Firestoreお気に入り削除成功: $menu');
    } catch (error) {
      // ignore: avoid_print
      print('Firestoreお気に入り削除エラー: $error');
      // Firestore削除に失敗しても、ローカルのお気に入り削除は維持する。
    }
  }

  @override
  Future<List<String>> loadFavoriteMealNames() {
    return loadFavorites();
  }

  @override
  Future<List<String>> addFavoriteMeal(String mealName) {
    return addFavorite(mealName);
  }

  @override
  Future<List<String>> removeFavoriteMeal(String mealName) {
    return removeFavorite(mealName);
  }

  @override
  Future<List<FavoriteMeal>> loadFavoriteMeals(String userId) async {
    final favorites = await loadFavorites();

    return favorites
        .map(
          (mealName) => FavoriteMeal(
            id: mealName,
            userId: userId,
            mealName: mealName,
            category: '献立',
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList();
  }
}
