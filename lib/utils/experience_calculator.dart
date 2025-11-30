import 'dart:math';

class ExperienceCalculator {
  // Belirli bir seviye için gereken XP (50 * 1.5^(level-1))
  static int getRequiredXPForLevel(int level) {
    if (level == 1) return 50;
    return (50 * pow(1.5, level - 1)).floor();
  }

  // Toplam XP'den seviye bilgilerini çıkar
  static Map<String, int> getLevelInfo(int totalExperience) {
    int level = 1;
    int remainingXP = totalExperience;
    int requiredXP = getRequiredXPForLevel(level);

    while (remainingXP >= requiredXP) {
      remainingXP -= requiredXP;
      level++;
      requiredXP = getRequiredXPForLevel(level);
    }

    return {
      'level': level,
      'currentXP': remainingXP,
      'requiredXP': requiredXP,
    };
  }

  // İşletme satın alınca XP bonusu (%30)
  static int getBusinessPurchaseXPBonus(int businessRequiredXP) {
    return (businessRequiredXP * 0.3).floor();
  }
}