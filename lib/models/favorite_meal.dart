class FavoriteMeal {
  const FavoriteMeal({
    required this.id,
    required this.userId,
    required this.mealName,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String mealName;
  final String category;
  final DateTime createdAt;
}
