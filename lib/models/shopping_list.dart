class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.userId,
    required this.weeklyPlanId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String weeklyPlanId;
  final List<ShoppingListItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ShoppingListItem {
  const ShoppingListItem({required this.name, this.checked = false});

  final String name;
  final bool checked;
}
