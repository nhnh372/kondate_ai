import '../models/meal_detail.dart';
import '../models/weekly_plan.dart';
import 'menu_generator.dart';

class AiCommentService {
  const AiCommentService();

  String priorityComment(PriorityWeights weights) {
    final priorities = <String, double>{
      '栄養バランス': weights.nutrition,
      '時短': weights.quick,
      '簡単さ': weights.easy,
      '新しさ': weights.fresh,
    }.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return '${priorities.first.key}を軸に、無理なく続けやすい献立に整えました。';
  }

  String weeklyPlanComment(WeeklyPlan plan, PriorityWeights weights) {
    final mainDishes = plan.days.map((day) => day.mainDish.name).toSet().length;
    return '${priorityComment(weights)} 主菜は$mainDishes種類を使い、1週間で飽きにくい流れにしています。';
  }

  String detailComment(MealDetail detail) {
    return '${detail.name}は${detail.category}として使いやすい一品です。調理時間は${detail.time}を目安にしてください。';
  }
}
