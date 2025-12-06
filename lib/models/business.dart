import 'dart:math';

class Business {
  /// Maksimum seviye: 15
  static const int maxLevel = 15;

  final int id;
  final String name;
  final String icon;
  int level;
  final double baseCost;
  final double baseIncome;

  /// Eski tasarımdan kalan alan, geriye dönük uyumluluk için tutuluyor
  /// ancak maliyet hesabında artık sabit 3x çarpanı kullanıyoruz.
  final double costMultiplier;
  final String description;
  final int requiredExperience;

  Business({
    required this.id,
    required this.name,
    required this.icon,
    this.level = 0,
    required this.baseCost,
    required this.baseIncome,
    this.costMultiplier = 3.0,
    required this.description,
    required this.requiredExperience,
  });

  /// Mevcut seviye için UPGRADE maliyeti
  ///
  /// Tap Tapcoon mantığı:
  /// - Level 0 → 1: cost = baseCost
  /// - Level 1 → 2: cost = baseCost * 3
  /// - Level 2 → 3: cost = baseCost * 3^2
  ///   ...
  /// Genel formül:
  ///   cost(level) = baseCost * 3^level
  double getCurrentCost() {
    if (level >= maxLevel) return double.infinity;
    return baseCost * pow(3, level).toDouble();
  }

  /// Mevcut seviye pasif gelir (/s)
  ///
  /// - Level 0: 0
  /// - Level 1: baseIncome
  /// - Level 2: baseIncome * 1.2
  /// - Level 3: baseIncome * 1.2^2
  /// Genel formül:
  ///   revenue(level) = baseIncome * 1.2^(level-1), level >= 1
  double getCurrentIncome() {
    if (level == 0) return 0.0;
    return baseIncome * pow(1.2, (level - 1)).toDouble();
  }

  /// Sonraki seviye için maliyet (sadece gösterim amaçlı)
  double getNextLevelCost() {
    if (level >= maxLevel) return double.infinity;
    return baseCost * pow(3, level + 1).toDouble();
  }

  /// Sonraki seviye için gelir (sadece gösterim amaçlı)
  double getNextLevelIncome() {
    if (level >= maxLevel) return getCurrentIncome();
    // Level 0 iken next income baseIncome olur (1.2^0 = 1)
    return baseIncome * pow(1.2, level).toDouble();
  }

  // İşletme unlock edilmiş mi?
  bool isUnlocked(int playerTotalXP) {
    return playerTotalXP >= requiredExperience;
  }

  // JSON'a çevir (kaydetme için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
    };
  }

  // JSON'dan oluştur (yükleme için)
  factory Business.fromJson(Map<String, dynamic> json, Business template) {
    return Business(
      id: template.id,
      name: template.name,
      icon: template.icon,
      level: json['level'] ?? 0,
      baseCost: template.baseCost,
      baseIncome: template.baseIncome,
      costMultiplier: template.costMultiplier,
      description: template.description,
      requiredExperience: template.requiredExperience,
    );
  }
}