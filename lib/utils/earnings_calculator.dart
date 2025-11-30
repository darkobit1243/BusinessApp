// ============================================
// 🎮 TIKLA MA KAZANÇ HESAPLAMA SİSTEMİ
// ============================================

class UpgradeLevel {
  final int level;
  final int clickValue;
  final int upgradeCost;

  UpgradeLevel({
    required this.level,
    required this.clickValue,
    required this.upgradeCost,
  });
}

// ============================================
// 📊 SEVİYE LİMİTLERİ VE MALİYETLER
// ============================================
final List<UpgradeLevel> upgradeLevels = [
  UpgradeLevel(level: 0, clickValue: 1, upgradeCost: 500),         // Seviye 0: $1/tık → $500 ile Seviye 1
  UpgradeLevel(level: 1, clickValue: 2, upgradeCost: 1500),        // Seviye 1: $2/tık → $1.5K ile Seviye 2
  UpgradeLevel(level: 2, clickValue: 4, upgradeCost: 3000),        // Seviye 2: $4/tık → $3K ile Seviye 3
  UpgradeLevel(level: 3, clickValue: 8, upgradeCost: 7000),        // Seviye 3: $8/tık → $7K ile Seviye 4
  UpgradeLevel(level: 4, clickValue: 15, upgradeCost: 15000),      // Seviye 4: $15/tık → $15K ile Seviye 5
  UpgradeLevel(level: 5, clickValue: 30, upgradeCost: 35000),      // Seviye 5: $30/tık → $35K ile Seviye 6
  UpgradeLevel(level: 6, clickValue: 50, upgradeCost: 75000),      // Seviye 6: $50/tık → $75K ile Seviye 7
  UpgradeLevel(level: 7, clickValue: 100, upgradeCost: 150000),    // Seviye 7: $100/tık → $150K ile Seviye 8
  UpgradeLevel(level: 8, clickValue: 200, upgradeCost: 350000),    // Seviye 8: $200/tık → $350K ile Seviye 9
  UpgradeLevel(level: 9, clickValue: 400, upgradeCost: 750000),    // Seviye 9: $400/tık → $750K ile Seviye 10
  UpgradeLevel(level: 10, clickValue: 1000, upgradeCost: 0),       // Seviye 10: $1000/tık → MAKSİMUM!
];

// ============================================
// 💰 SEVİYEYE GÖRE TIKLA MA DEĞERİ
// ============================================
int getClickValueByLevel(int level) {
  if (level >= 0 && level < upgradeLevels.length) {
    return upgradeLevels[level].clickValue;
  }
  return 1; // Varsayılan
}

// ============================================
// 💵 SEVİYE YÜKSELTME MALİYETİ
// ============================================
int getUpgradeCost(int currentLevel) {
  if (currentLevel >= 0 && currentLevel < upgradeLevels.length) {
    return upgradeLevels[currentLevel].upgradeCost;
  }
  return 0; // Maksimum seviye
}

// ============================================
// 🔢 SAYILARI OKUNAKLI FORMATLAMA
// ============================================
// Örnek: 500 → "500", 1500 → "1.5K", 1000000 → "1M"
String formatNumber(double number) {
  if (number >= 1000000000) {
    // 1 Milyar ve üzeri → "1.2B"
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  } else if (number >= 1000000) {
    // 1 Milyon ve üzeri → "1.5M"
    double millions = number / 1000000;
    if (millions >= 10) {
      return '${millions.toStringAsFixed(0)}M'; // 10M, 25M
    } else {
      return '${millions.toStringAsFixed(1)}M'; // 1.5M, 2.3M
    }
  } else if (number >= 1000) {
    // 1000 ve üzeri → "1.5K"
    double thousands = number / 1000;
    if (thousands >= 10) {
      return '${thousands.toStringAsFixed(0)}K'; // 10K, 25K, 100K
    } else {
      return '${thousands.toStringAsFixed(1)}K'; // 1.5K, 2.3K, 9.8K
    }
  } else {
    // 1000'den küçük → "500", "123"
    return number.toStringAsFixed(0);
  }
}

// ============================================
// 🎯 UPGRADE BUTONU İÇİN ÖZEL FORMAT
// ============================================
// Upgrade butonunda daha kısa gösterim
String formatUpgradeCost(int cost) {
  if (cost >= 1000000) {
    // 1 Milyon ve üzeri
    double millions = cost / 1000000;
    if (millions % 1 == 0) {
      return '${millions.toInt()}M'; // 1M, 2M
    } else {
      return '${millions.toStringAsFixed(1)}M'; // 1.5M
    }
  } else if (cost >= 1000) {
    // 1000 ve üzeri
    double thousands = cost / 1000;
    if (thousands % 1 == 0) {
      return '${thousands.toInt()}K'; // 1K, 15K, 75K
    } else {
      return '${thousands.toStringAsFixed(1)}K'; // 1.5K, 3.5K
    }
  } else {
    // 1000'den küçük
    return cost.toString(); // 500
  }
}

// ============================================
// 📈 SONRAKI SEVİYE BİLGİSİ
// ============================================
Map<String, dynamic> getNextLevelInfo(int currentLevel, double currentBalance) {
  if (currentLevel >= 10) {
    return {
      'isMaxLevel': true,
      'remaining': 0,
      'nextClickValue': 1000,
      'upgradeCost': 0,
    };
  }

  final upgradeCost = getUpgradeCost(currentLevel);
  final nextClickValue = getClickValueByLevel(currentLevel + 1);
  final remaining = (upgradeCost - currentBalance).clamp(0, double.infinity);

  return {
    'isMaxLevel': false,
    'remaining': remaining,
    'nextClickValue': nextClickValue,
    'upgradeCost': upgradeCost,
  };
}