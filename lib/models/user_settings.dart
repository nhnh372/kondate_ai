class UserSettings {
  const UserSettings({
    required this.userId,
    required this.familySize,
    required this.allergies,
    required this.dislikedIngredients,
    required this.busyLevel,
    required this.returnHomeTime,
    required this.favoriteGenres,
    required this.budgetYenPerWeek,
    this.updatedAt,
  });

  final String userId;
  final int familySize;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final String busyLevel;
  final String returnHomeTime;
  final List<String> favoriteGenres;
  final int budgetYenPerWeek;
  final DateTime? updatedAt;
}
