class MealDetail {
  const MealDetail({
    required this.name,
    required this.time,
    required this.ingredients,
    required this.steps,
    required this.comment,
    required this.category,
  });

  final String name;
  final String time;
  final List<String> ingredients;
  final List<String> steps;
  final String comment;
  final String category;
}
