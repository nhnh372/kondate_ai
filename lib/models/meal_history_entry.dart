class MealHistoryEntry {
  const MealHistoryEntry({
    required this.id,
    required this.userId,
    required this.mealName,
    required this.category,
    required this.aiScore,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String mealName;
  final String category;
  final int aiScore;
  final DateTime createdAt;
}
