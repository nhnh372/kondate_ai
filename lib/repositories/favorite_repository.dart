import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_meal.dart';
import 'repository_contracts.dart';

class FavoriteRepository implements FavoriteMealRepository {
  const FavoriteRepository();

  static const String _favoritesKey = 'favorites';

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<List<String>> addFavorite(String menu) async {
    final favorites = await loadFavorites();

    if (favorites.contains(menu)) {
      return favorites;
    }

    final updatedFavorites = [...favorites, menu];
    await _saveFavorites(updatedFavorites);
    return updatedFavorites;
  }

  Future<List<String>> removeFavorite(String menu) async {
    final favorites = await loadFavorites();
    final updatedFavorites = favorites.where((item) => item != menu).toList();

    await _saveFavorites(updatedFavorites);
    return updatedFavorites;
  }

  Future<void> _saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
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
