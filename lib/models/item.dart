enum ItemRarity {
  common,
  rare,
  epic,
  legendary,
  mythic,
}

enum ItemCategory {
  boost,
  automation,
  xpBoost,
  special,
}

class Item {
  final int id;
  final String name;
  final String icon;
  final ItemRarity rarity;
  final String description;
  final String effect;
  final int price;
  int owned;
  final int maxStack;
  final ItemCategory category;

  Item({
    required this.id,
    required this.name,
    required this.icon,
    required this.rarity,
    required this.description,
    required this.effect,
    required this.price,
    required this.owned,
    required this.maxStack,
    required this.category,
  });
}