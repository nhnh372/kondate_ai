import 'recipe.dart';

class WeeklyPlan {
  const WeeklyPlan({required this.days});

  final List<WeeklyDayPlan> days;

  int get totalMinutes =>
      days.fold(0, (total, day) => total + day.cookingMinutes);

  int get totalCostYen =>
      days.fold(0, (total, day) => total + day.estimatedCostYen);

  NutritionBalance get averageNutritionBalance {
    if (days.isEmpty) {
      return const NutritionBalance(protein: 0, vegetable: 0, energy: 0);
    }

    final totalProtein = days.fold(
      0,
      (total, day) => total + day.nutritionBalance.protein,
    );
    final totalVegetable = days.fold(
      0,
      (total, day) => total + day.nutritionBalance.vegetable,
    );
    final totalEnergy = days.fold(
      0,
      (total, day) => total + day.nutritionBalance.energy,
    );

    return NutritionBalance(
      protein: totalProtein ~/ days.length,
      vegetable: totalVegetable ~/ days.length,
      energy: totalEnergy ~/ days.length,
    );
  }

  List<String> get shoppingItems {
    final items = <String>{};

    for (final day in days) {
      items.addAll(day.shoppingItems);
    }

    return items.toList();
  }
}

class WeeklyDayPlan {
  const WeeklyDayPlan({
    required this.dayName,
    required this.mainDish,
    required this.sideDish,
    required this.soup,
    required this.cookingMinutes,
    required this.estimatedCostYen,
    required this.nutritionBalance,
    required this.shoppingItems,
  });

  final String dayName;
  final WeeklyMealItem mainDish;
  final WeeklyMealItem sideDish;
  final WeeklyMealItem soup;
  final int cookingMinutes;
  final int estimatedCostYen;
  final NutritionBalance nutritionBalance;
  final List<String> shoppingItems;
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

class NutritionBalance {
  const NutritionBalance({
    required this.protein,
    required this.vegetable,
    required this.energy,
  });

  final int protein;
  final int vegetable;
  final int energy;
}
