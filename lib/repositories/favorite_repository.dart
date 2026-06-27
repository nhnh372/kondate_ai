import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRepository {
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
}
