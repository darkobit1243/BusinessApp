import 'dart:math';

class Business {
  final int id;
  final String name;
  final String icon;
  int level;
  final double baseCost;
  final double baseIncome;
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
    this.costMultiplier = 1.15,
    required this.description,
    required this.requiredExperience,
  });

  // Mevcut seviye maliyeti
  double getCurrentCost() {
    if (level == 0) return baseCost;
    return baseCost * pow(costMultiplier, level);
  }

  // Mevcut seviye geliri (YENİ FORMÜL: baseIncome * 1.5^(level-1))
  double getCurrentIncome() {
    if (level == 0) return 0.0;
    return baseIncome * pow(1.5, level - 1);
  }

  // Sonraki seviye maliyeti
  double getNextLevelCost() {
    return baseCost * pow(costMultiplier, level);
  }

  // Sonraki seviye geliri
  double getNextLevelIncome() {
    return baseIncome * pow(1.5, level);
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