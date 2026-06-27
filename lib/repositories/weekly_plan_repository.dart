import '../data/recipes.dart';
import '../models/recipe.dart';
import '../models/weekly_plan.dart';
import '../services/menu_generator.dart';

class WeeklyPlanRepository {
  const WeeklyPlanRepository({this.menuGenerator = const MenuGenerator()});

  final MenuGenerator menuGenerator;

  static const List<String> _days = [
    '月曜日',
    '火曜日',
    '水曜日',
    '木曜日',
    '金曜日',
    '土曜日',
    '日曜日',
  ];

  static const List<String> _sideDishes = [
    'ほうれん草のおひたし',
    'ひじき煮',
    'ポテトサラダ',
    'きゅうりの浅漬け',
    '小松菜のごま和え',
    '冷奴',
    '切り干し大根',
  ];

  static const List<String> _soups = [
    '豆腐の味噌汁',
    'わかめスープ',
    '野菜スープ',
    '卵スープ',
    'きのこの味噌汁',
    '豚汁',
    '玉ねぎの味噌汁',
  ];

  static const List<List<String>> _sideDishIngredients = [
    ['ほうれん草', 'かつお節'],
    ['ひじき', 'にんじん'],
    ['じゃがいも', 'きゅうり'],
    ['きゅうり', '塩昆布'],
    ['小松菜', 'ごま'],
    ['豆腐', 'ねぎ'],
    ['切り干し大根', '油揚げ'],
  ];

  static const List<List<String>> _soupIngredients = [
    ['豆腐', '味噌'],
    ['わかめ', '鶏がらスープ'],
    ['キャベツ', 'にんじん'],
    ['卵', 'ねぎ'],
    ['きのこ', '味噌'],
    ['豚こま肉', '大根'],
    ['玉ねぎ', '味噌'],
  ];

  WeeklyPlan generate({
    required PriorityWeights weights,
    int generationIndex = 0,
    List<Recipe> sourceRecipes = recipes,
  }) {
    final usedRecipes = <String>{};

    final days = List.generate(_days.length, (index) {
      final dayIndex = index + generationIndex;
      final candidates = sourceRecipes
          .where((recipe) => !usedRecipes.contains(recipe.name))
          .toList();
      final availableRecipes = candidates.isEmpty ? sourceRecipes : candidates;
      final recommendation = menuGenerator.recommend(
        recipes: availableRecipes,
        weights: _weightsForDay(weights, dayIndex),
      );

      usedRecipes.add(recommendation.recipe.name);

      return WeeklyDayPlan(
        dayName: _days[index],
        cookingMinutes: _cookingMinutesFor(recommendation.recipe, dayIndex),
        estimatedCostYen: _estimatedCostFor(dayIndex),
        nutritionBalance: _nutritionBalanceFor(dayIndex),
        shoppingItems: _shoppingItemsFor(recommendation.recipe, dayIndex),
        mainDish: WeeklyMealItem(
          label: '主菜',
          name: recommendation.recipe.name,
          iconName: 'restaurant_menu',
          recipe: recommendation.recipe,
        ),
        sideDish: WeeklyMealItem(
          label: '副菜',
          name: _sideDishes[dayIndex % _sideDishes.length],
          iconName: 'spa',
        ),
        soup: WeeklyMealItem(
          label: '汁物',
          name: _soups[dayIndex % _soups.length],
          iconName: 'ramen_dining',
        ),
      );
    });

    return WeeklyPlan(days: days);
  }

  PriorityWeights _weightsForDay(PriorityWeights weights, int index) {
    final dayAdjustments = [
      const PriorityWeights(nutrition: 12, quick: 0, easy: 0, fresh: 0),
      const PriorityWeights(nutrition: 0, quick: 12, easy: 0, fresh: 0),
      const PriorityWeights(nutrition: 0, quick: 0, easy: 12, fresh: 0),
      const PriorityWeights(nutrition: 0, quick: 0, easy: 0, fresh: 12),
      const PriorityWeights(nutrition: 8, quick: 8, easy: 0, fresh: 0),
      const PriorityWeights(nutrition: 0, quick: 0, easy: 8, fresh: 8),
      const PriorityWeights(nutrition: 8, quick: 0, easy: 0, fresh: 8),
    ];

    final adjustment = dayAdjustments[index % dayAdjustments.length];

    return PriorityWeights(
      nutrition: weights.nutrition + adjustment.nutrition,
      quick: weights.quick + adjustment.quick,
      easy: weights.easy + adjustment.easy,
      fresh: weights.fresh + adjustment.fresh,
    );
  }

  int _cookingMinutesFor(Recipe recipe, int index) {
    final parsedMinutes = int.tryParse(recipe.time.replaceAll('分', '')) ?? 20;
    final sideAndSoupMinutes = 12 + (index % 3) * 3;

    return parsedMinutes + sideAndSoupMinutes;
  }

  int _estimatedCostFor(int index) {
    const baseCost = 780;
    const dayCostSteps = [0, 120, 80, 160, 100, 220, 140];

    return baseCost + dayCostSteps[index % dayCostSteps.length];
  }

  NutritionBalance _nutritionBalanceFor(int index) {
    const balances = [
      NutritionBalance(protein: 84, vegetable: 78, energy: 72),
      NutritionBalance(protein: 76, vegetable: 82, energy: 78),
      NutritionBalance(protein: 80, vegetable: 74, energy: 82),
      NutritionBalance(protein: 72, vegetable: 86, energy: 76),
      NutritionBalance(protein: 82, vegetable: 80, energy: 74),
      NutritionBalance(protein: 78, vegetable: 76, energy: 86),
      NutritionBalance(protein: 86, vegetable: 72, energy: 80),
    ];

    return balances[index % balances.length];
  }

  List<String> _shoppingItemsFor(Recipe recipe, int index) {
    return [
      recipe.name,
      ..._sideDishIngredients[index % _sideDishIngredients.length],
      ..._soupIngredients[index % _soupIngredients.length],
    ];
  }
}
