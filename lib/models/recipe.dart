class Recipe {
  const Recipe({
    required this.name,
    required this.time,
    required this.tags,
    required this.nutrition,
    required this.quick,
    required this.easy,
    required this.fresh,
    required this.aiScore,
  });

  final String name;
  final String time;
  final List<String> tags;
  final int nutrition;
  final int quick;
  final int easy;
  final int fresh;
  final int aiScore;
}
