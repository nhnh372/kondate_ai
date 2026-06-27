import '../models/recipe.dart';

class PriorityWeights {
  const PriorityWeights({
    required this.nutrition,
    required this.quick,
    required this.easy,
    required this.fresh,
  });

  final double nutrition;
  final double quick;
  final double easy;
  final double fresh;
}

class MenuRecommendation {
  const MenuRecommendation({
    required this.recipe,
    required this.score,
    required this.reason,
  });

  final Recipe recipe;
  final double score;
  final String reason;
}

class MenuGenerator {
  const MenuGenerator();

  MenuRecommendation recommend({
    required List<Recipe> recipes,
    required PriorityWeights weights,
  }) {
    if (recipes.isEmpty) {
      throw ArgumentError.value(
        recipes,
        'recipes',
        'Recipes must not be empty.',
      );
    }

    Recipe bestRecipe = recipes.first;
    double bestScore = _score(recipes.first, weights);

    for (final recipe in recipes.skip(1)) {
      final score = _score(recipe, weights);

      if (score > bestScore) {
        bestRecipe = recipe;
        bestScore = score;
      }
    }

    return MenuRecommendation(
      recipe: bestRecipe,
      score: bestScore,
      reason: _buildReason(bestRecipe, weights),
    );
  }

  double _score(Recipe recipe, PriorityWeights weights) {
    final totalWeight =
        weights.nutrition + weights.quick + weights.easy + weights.fresh;

    if (totalWeight == 0) {
      return 0;
    }

    return (recipe.nutrition * weights.nutrition +
            recipe.quick * weights.quick +
            recipe.easy * weights.easy +
            recipe.fresh * weights.fresh) /
        totalWeight;
  }

  String _buildReason(Recipe recipe, PriorityWeights weights) {
    final priorities = <String, double>{
      '栄養バランス': weights.nutrition,
      '時短': weights.quick,
      '簡単さ': weights.easy,
      '新しさ': weights.fresh,
    }.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final topPriority = priorities.first.key;

    return '$topPriorityを重視して、${recipe.name}を選びました。';
  }
}
