import 'recipe.dart';

class WeeklyPlan {
  const WeeklyPlan({required this.days});

  final List<WeeklyDayPlan> days;
}

class WeeklyDayPlan {
  const WeeklyDayPlan({
    required this.dayName,
    required this.mainDish,
    required this.sideDish,
    required this.soup,
  });

  final String dayName;
  final WeeklyMealItem mainDish;
  final WeeklyMealItem sideDish;
  final WeeklyMealItem soup;
}

class WeeklyMealItem {
  const WeeklyMealItem({
    required this.label,
    required this.name,
    required this.iconName,
    this.recipe,
  });

  final String label;
  final String name;
  final String iconName;
  final Recipe? recipe;
}
