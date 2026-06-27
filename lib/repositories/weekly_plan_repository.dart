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
}
