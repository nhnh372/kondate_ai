import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMigrationSnapshot {
  const SharedPreferencesMigrationSnapshot({
    required this.favoriteMealNames,
    required this.mealHistoryNames,
    required this.nutritionPriority,
    required this.quickPriority,
    required this.easyPriority,
    required this.newPriority,
  });

  final List<String> favoriteMealNames;
  final List<String> mealHistoryNames;
  final double nutritionPriority;
  final double quickPriority;
  final double easyPriority;
  final double newPriority;
}

class SharedPreferencesMigrationRepository {
  const SharedPreferencesMigrationRepository();

  static const favoritesKey = 'favorites';
  static const historyKey = 'history';
  static const nutritionPriorityKey = 'nutritionPriority';
  static const quickPriorityKey = 'quickPriority';
  static const easyPriorityKey = 'easyPriority';
  static const newPriorityKey = 'newPriority';

  Future<SharedPreferencesMigrationSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();

    return SharedPreferencesMigrationSnapshot(
      favoriteMealNames: prefs.getStringList(favoritesKey) ?? [],
      mealHistoryNames: prefs.getStringList(historyKey) ?? [],
      nutritionPriority: prefs.getDouble(nutritionPriorityKey) ?? 40,
      quickPriority: prefs.getDouble(quickPriorityKey) ?? 20,
      easyPriority: prefs.getDouble(easyPriorityKey) ?? 20,
      newPriority: prefs.getDouble(newPriorityKey) ?? 20,
    );
  }
}
