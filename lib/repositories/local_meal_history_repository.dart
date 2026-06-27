import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_history_entry.dart';
import 'repository_contracts.dart';

class LocalMealHistoryRepository implements MealHistoryRepository {
  const LocalMealHistoryRepository();

  static const String _historyKey = 'history';

  @override
  Future<List<String>> loadMealHistoryNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  @override
  Future<void> addMealHistory(String mealName) async {
    final history = await loadMealHistoryNames();
    final updatedHistory = [mealName, ...history];
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_historyKey, updatedHistory);
  }

  @override
  Future<List<MealHistoryEntry>> loadMealHistory(String userId) async {
    final historyNames = await loadMealHistoryNames();

    return historyNames
        .map(
          (mealName) => MealHistoryEntry(
            id: mealName,
            userId: userId,
            mealName: mealName,
            category: '献立',
            aiScore: 0,
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList();
  }
}
