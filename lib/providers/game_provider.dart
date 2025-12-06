import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';
import '../models/business_data.dart';
import '../utils/experience_calculator.dart';

class GameProvider with ChangeNotifier {
  // === OYUN VERİLERİ ===
  bool _darkMode = false;
  double _balance = 0.0;
  int _todayClicks = 0;
  int _weekClicks = 0;
  int _totalClicks = 0;
  int _totalExperience = 0;
  int _clickUpgradeLevel = 0;
  int _notificationCount = 0;

  // Google Play Games / profil bilgileri (isteğe bağlı)
  String? _googlePlayProfileUrl;
  String? _googlePlayName;

  // İşletmeler
  List<Business> _businesses = [];

  // Pasif gelir zamanlayıcısı
  Timer? _passiveIncomeTimer;

  // === GETTERS ===
  bool get darkMode => _darkMode;
  double get balance => _balance;
  int get todayClicks => _todayClicks;
  int get weekClicks => _weekClicks;
  int get totalClicks => _totalClicks;
  int get totalExperience => _totalExperience;
  int get clickUpgradeLevel => _clickUpgradeLevel;
  int get notificationCount => _notificationCount;
  List<Business> get businesses => _businesses;

  String? get googlePlayProfileUrl => _googlePlayProfileUrl;
  String? get googlePlayName => _googlePlayName;

  // Seviye bilgileri (hesaplanmış)
  Map<String, int> get levelInfo =>
      ExperienceCalculator.getLevelInfo(_totalExperience);

  int get currentLevel => levelInfo['level']!;
  int get currentXP => levelInfo['currentXP']!;
  int get requiredXP => levelInfo['requiredXP']!;

  /// Google Play Games profil bilgisini güncellemek için yardımcı metot.
  void setGooglePlayProfile({String? name, String? photoUrl}) {
    _googlePlayName = name;
    _googlePlayProfileUrl = photoUrl;
    notifyListeners();
  }

  // Toplam pasif gelir
  double get passiveIncome {
    return _businesses.fold(0.0, (sum, b) => sum + b.getCurrentIncome());
  }

  // === CONSTRUCTOR ===
  GameProvider() {
    _loadGame();
    _startPassiveIncome();
  }

  // ============================================
  // 💾 VERİ YÜKLEME
  // ============================================
  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool('darkMode') ?? false;
    _balance = prefs.getDouble('balance') ?? 0.0;
    _todayClicks = prefs.getInt('todayClicks') ?? 0;
    _weekClicks = prefs.getInt('weekClicks') ?? 0;
    _totalClicks = prefs.getInt('totalClicks') ?? 0;
    _totalExperience = prefs.getInt('totalExperience') ?? 0;
    _clickUpgradeLevel = prefs.getInt('clickUpgradeLevel') ?? 0;
    _notificationCount = prefs.getInt('notificationCount') ?? 0;

    // İşletmeleri yükle
    _businesses = initialBusinesses.map((b) {
      final level = prefs.getInt('business_${b.id}_level') ?? 0;
      return Business(
        id: b.id,
        name: b.name,
        icon: b.icon,
        level: level,
        baseCost: b.baseCost,
        baseIncome: b.baseIncome,
        costMultiplier: b.costMultiplier,
        description: b.description,
        requiredExperience: b.requiredExperience,
      );
    }).toList();

    notifyListeners();
  }

  // ============================================
  // 💾 VERİ KAYDETME
  // ============================================
  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkMode', _darkMode);
    await prefs.setDouble('balance', _balance);
    await prefs.setInt('todayClicks', _todayClicks);
    await prefs.setInt('weekClicks', _weekClicks);
    await prefs.setInt('totalClicks', _totalClicks);
    await prefs.setInt('totalExperience', _totalExperience);
    await prefs.setInt('clickUpgradeLevel', _clickUpgradeLevel);
    await prefs.setInt('notificationCount', _notificationCount);

    // İşletmeleri kaydet
    for (var b in _businesses) {
      await prefs.setInt('business_${b.id}_level', b.level);
    }
  }

  // ============================================
  // 🎮 OYUN METODLARI
  // ============================================

  // Dark mode değiştir
  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _saveGame();
    notifyListeners();
  }

  // Para ekle
  void addBalance(double amount) {
    _balance += amount;
    _saveGame();
    notifyListeners();
  }

  // Para çıkar
  void subtractBalance(double amount) {
    if (_balance >= amount) {
      _balance -= amount;
      _saveGame();
      notifyListeners();
    }
  }

  // Tıklama (her tıklama +1 para, +1 XP)
  void handleClick() {
    final clickValue = 1.0 + _clickUpgradeLevel;
    _balance += clickValue;
    _todayClicks++;
    _weekClicks++;
    _totalClicks++;
    _totalExperience++; // ← Her tıklama +1 XP
    _saveGame();
    notifyListeners();
  }

  // Mevcut tıklama değeri (seviye + 1)
  int get currentClickValue => _clickUpgradeLevel + 1;

  // Sonraki seviye tıklama değeri
  int get nextClickValue => _clickUpgradeLevel + 2;

  // Sonraki seviye maliyeti
  double get nextLevelCost {
    if (_clickUpgradeLevel == 0) return 500.0;
    if (_clickUpgradeLevel == 1) return 1000.0;
    if (_clickUpgradeLevel == 2) return 2000.0;
    if (_clickUpgradeLevel == 3) return 4000.0;
    if (_clickUpgradeLevel == 4) return 8000.0;
    if (_clickUpgradeLevel == 5) return 16000.0;
    if (_clickUpgradeLevel == 6) return 32000.0;
    if (_clickUpgradeLevel == 7) return 64000.0;
    if (_clickUpgradeLevel == 8) return 128000.0;
    if (_clickUpgradeLevel == 9) return 256000.0;
    return 0.0; // Maksimum seviye
  }

  // Maksimum seviyede mi?
  bool get isMaxClickLevel => _clickUpgradeLevel >= 10;

  // Tıklama değerini yükselt
  void upgradeClickValue([double? cost]) {
    final upgradeCost = cost ?? nextLevelCost;
    if (_balance >= upgradeCost && !isMaxClickLevel) {
      _balance -= upgradeCost;
      _clickUpgradeLevel++;
      _saveGame();
      notifyListeners();
    }
  }

  // Bildirim sayısını ayarla
  void setNotificationCount(int count) {
    _notificationCount = count;
    _saveGame();
    notifyListeners();
  }

  // ============================================
  // 🏢 İŞLETME SATIN ALMA
  // ============================================
  bool purchaseBusiness(Business business) {
    // Maks seviye kontrolü (Tap Tapcoon: 15)
    if (business.level >= Business.maxLevel) {
      return false;
    }

    // Mevcut seviyeden bir sonraki seviyeye geçiş maliyeti
    final cost = business.getCurrentCost();

    // Para kontrolü
    if (_balance < cost) {
      return false;
    }

    // XP unlock kontrolü (ilk satın almada)
    if (business.level == 0 && !business.isUnlocked(_totalExperience)) {
      return false;
    }

    final isFirstPurchase = business.level == 0;

    // Satın al
    _balance -= cost;
    business.level++;

    // İlk satın almada %30 XP bonusu
    if (isFirstPurchase) {
      final bonus = ExperienceCalculator.getBusinessPurchaseXPBonus(
          business.requiredExperience
      );
      _totalExperience += bonus;
    }

    _saveGame();
    notifyListeners();
    return true;
  }

  // ============================================
  // 💰 PASİF GELİR OTOMATİZASYONU
  // ============================================
  void _startPassiveIncome() {
    _passiveIncomeTimer?.cancel();
    _passiveIncomeTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (passiveIncome > 0) {
          _balance += passiveIncome;
          // Not: Her saniye kaydetmiyoruz, performans için
          // Sadece notifyListeners çağırıyoruz
          notifyListeners();
        }
      },
    );
  }

  // ============================================
  // 🔄 OYUNU SIFIRLA
  // ============================================
  Future<void> resetGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _darkMode = false;
    _balance = 0.0;
    _todayClicks = 0;
    _weekClicks = 0;
    _totalClicks = 0;
    _totalExperience = 0;
    _clickUpgradeLevel = 0;
    _notificationCount = 0;

    // İşletmeleri sıfırla
    _businesses = initialBusinesses.map((b) => Business(
      id: b.id,
      name: b.name,
      icon: b.icon,
      level: 0,
      baseCost: b.baseCost,
      baseIncome: b.baseIncome,
      costMultiplier: b.costMultiplier,
      description: b.description,
      requiredExperience: b.requiredExperience,
    )).toList();

    notifyListeners();
  }

  // ============================================
  // 🗑️ DISPOSE
  // ============================================
  @override
  void dispose() {
    _passiveIncomeTimer?.cancel();
    // Son kez kaydet (async ama dispose'da await edemeyiz)
    _saveGame().catchError((_) {
      // Hata durumunda sessizce devam et
    });
    super.dispose();
  }
}