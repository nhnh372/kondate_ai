import 'package:flutter_test/flutter_test.dart';
import 'package:kondate_ai/models/recipe.dart';
import 'package:kondate_ai/services/menu_generator.dart';

void main() {
  const generator = MenuGenerator();
  const recipes = [
    Recipe(
      name: '栄養重視メニュー',
      time: '30分',
      tags: ['#栄養'],
      nutrition: 100,
      quick: 10,
      easy: 10,
      fresh: 10,
    ),
    Recipe(
      name: '時短メニュー',
      time: '10分',
      tags: ['#時短'],
      nutrition: 10,
      quick: 100,
      easy: 50,
      fresh: 10,
    ),
  ];

  test('栄養の優先度が高いと栄養スコアの高い料理を選ぶ', () {
    final recommendation = generator.recommend(
      recipes: recipes,
      weights: const PriorityWeights(
        nutrition: 100,
        quick: 0,
        easy: 0,
        fresh: 0,
      ),
    );

    expect(recommendation.recipe.name, '栄養重視メニュー');
    expect(recommendation.score, 100);
  });

  test('時短の優先度が高いと時短スコアの高い料理を選ぶ', () {
    final recommendation = generator.recommend(
      recipes: recipes,
      weights: const PriorityWeights(
        nutrition: 0,
        quick: 100,
        easy: 0,
        fresh: 0,
      ),
    );

    expect(recommendation.recipe.name, '時短メニュー');
    expect(recommendation.score, 100);
  });
}
