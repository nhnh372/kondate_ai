import '../models/app_user.dart';
import '../models/favorite_meal.dart';
import '../models/meal_history_entry.dart';
import '../models/shopping_list.dart';
import '../models/user_settings.dart';
import '../models/weekly_plan.dart';

abstract class UserRepository {
  Future<AppUser?> loadCurrentUser();

  Future<void> saveUser(AppUser user);
}

abstract class FavoriteMealRepository {
  Future<List<String>> loadFavoriteMealNames();

  Future<List<String>> addFavoriteMeal(String mealName);

  Future<List<String>> removeFavoriteMeal(String mealName);

  Future<List<FavoriteMeal>> loadFavoriteMeals(String userId);
}

abstract class MealHistoryRepository {
  Future<List<String>> loadMealHistoryNames();

  Future<void> addMealHistory(String mealName);

  Future<List<MealHistoryEntry>> loadMealHistory(String userId);
}

abstract class WeeklyPlanStorageRepository {
  Future<void> saveWeeklyPlan(String userId, WeeklyPlan weeklyPlan);

  Future<WeeklyPlan?> loadLatestWeeklyPlan(String userId);
}

abstract class ShoppingListRepository {
  Future<void> saveShoppingList(ShoppingList shoppingList);

  Future<ShoppingList?> loadShoppingList(String userId, String weeklyPlanId);
}

abstract class SettingsRepository {
  Future<UserSettings?> loadSettings(String userId);

  Future<void> saveSettings(UserSettings settings);
}
