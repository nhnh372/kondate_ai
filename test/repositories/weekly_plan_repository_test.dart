import 'package:flutter_test/flutter_test.dart';
import 'package:kondate_ai/repositories/weekly_plan_repository.dart';
import 'package:kondate_ai/services/menu_generator.dart';

void main() {
  const repository = WeeklyPlanRepository();

  test('月曜日から日曜日まで主菜・副菜・汁物の週間献立を生成する', () {
    final plan = repository.generate(
      weights: const PriorityWeights(
        nutrition: 40,
        quick: 20,
        easy: 20,
        fresh: 20,
      ),
    );

    expect(plan.days, hasLength(7));
    expect(plan.days.first.dayName, '月曜日');
    expect(plan.days.last.dayName, '日曜日');

    for (final day in plan.days) {
      expect(day.mainDish.label, '主菜');
      expect(day.mainDish.name, isNotEmpty);
      expect(day.sideDish.label, '副菜');
      expect(day.sideDish.name, isNotEmpty);
      expect(day.soup.label, '汁物');
      expect(day.soup.name, isNotEmpty);
    }
  });
}
