import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';
import '../models/business_data.dart';
import '../models/item.dart';
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

  // Eşyalar (buff / item sistemi)
  List<Item> _items = [];

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
  List<Item> get items => _items;
  List<Item> get ownedItems =>
      _items.where((item) => item.owned > 0).toList();

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

    // Eşyaları yükle
    _initializeItems(prefs);

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

    // Eşya envanterini kaydet
    for (final item in _items) {
      await prefs.setInt('item_${item.id}_owned', item.owned);
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

  // ============================================
  // 🧪 EŞYA / ENVANTER SİSTEMİ
  // ============================================

  /// Belirli bir eşyanın mevcut fiyatını hesapla.
  /// Her satın almada fiyat mevcut fiyata ×1.5 uygulanmış gibi artar.
  double getItemCurrentPrice(Item item) {
    double price = item.price.toDouble();
    for (int i = 0; i < item.owned; i++) {
      price *= 1.5;
    }
    return price;
  }

  /// Eşya satın alma mantığı.
  /// Yeterli bakiye varsa fiyat düşülür, adet artırılır ve kaydedilir.
  bool buyItem(Item item) {
    final currentPrice = getItemCurrentPrice(item);

    if (_balance < currentPrice) {
      return false;
    }

    if (item.owned >= item.maxStack) {
      return false;
    }

    _balance -= currentPrice;
    item.owned++;
    _saveGame();
    notifyListeners();
    return true;
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

    // Eşya envanterini sıfırla
    _initializeItems(null);

    notifyListeners();
  }

  // ============================================
  // 🧩 EŞYA BAŞLANGIÇ VERİLERİ
  // ============================================

  void _initializeItems(SharedPreferences? prefs) {
    final ownedFromPrefs = (int id) =>
        prefs?.getInt('item_${id}_owned') ?? 0;

    _items = [
      // ⚡ GÜÇLENDİRİCİ (boost)
      Item(
        id: 1,
        name: 'Şans Tılsımı',
        icon: '🍀',
        rarity: ItemRarity.common,
        description: 'Şansını artıran küçük tılsım.',
        effect: '+5% tıklama kazancı.',
        price: 100,
        owned: ownedFromPrefs(1),
        maxStack: 10,
        category: ItemCategory.boost,
      ),
      Item(
        id: 2,
        name: 'Altın Yonca',
        icon: '☘️',
        rarity: ItemRarity.rare,
        description: 'Daha yüksek kazanç şansı sağlar.',
        effect: '+15% tıklama kazancı.',
        price: 500,
        owned: ownedFromPrefs(2),
        maxStack: 5,
        category: ItemCategory.boost,
      ),
      Item(
        id: 3,
        name: 'Elmas Tılsım',
        icon: '💎',
        rarity: ItemRarity.epic,
        description: 'İşletme gelirlerini parlatır.',
        effect: '+25% işletme geliri.',
        price: 2000,
        owned: ownedFromPrefs(3),
        maxStack: 3,
        category: ItemCategory.boost,
      ),
      Item(
        id: 4,
        name: 'Zaman Kristali',
        icon: '⏰',
        rarity: ItemRarity.legendary,
        description: 'Kısa süreli tıklama gücü patlaması.',
        effect: '10 dakika boyunca 2x tıklama.',
        price: 5000,
        owned: ownedFromPrefs(4),
        maxStack: 2,
        category: ItemCategory.boost,
      ),
      Item(
        id: 5,
        name: 'Altın Saat',
        icon: '⌚',
        rarity: ItemRarity.rare,
        description: 'İşletmelerini hızlandırır.',
        effect: '+20% işletme hızı.',
        price: 1200,
        owned: ownedFromPrefs(5),
        maxStack: 4,
        category: ItemCategory.boost,
      ),
      Item(
        id: 6,
        name: 'Turbo Pekiştirici',
        icon: '⚡',
        rarity: ItemRarity.epic,
        description: 'Tüm ekonomiyi kısa süreli turbo moda alır.',
        effect: '30 dakika boyunca +50% tüm gelir.',
        price: 3000,
        owned: ownedFromPrefs(6),
        maxStack: 2,
        category: ItemCategory.boost,
      ),
      Item(
        id: 7,
        name: 'Manyetik Çekici',
        icon: '🧲',
        rarity: ItemRarity.rare,
        description: 'Otomatik tıklama üreten mıknatıs.',
        effect: 'Her 5 saniyede 1 otomatik tıklama.',
        price: 800,
        owned: ownedFromPrefs(7),
        maxStack: 5,
        category: ItemCategory.boost,
      ),
      Item(
        id: 8,
        name: 'Çift Gelir Tozu',
        icon: '✨',
        rarity: ItemRarity.epic,
        description: 'Kısa süreli tüm gelirleri ikiye katlar.',
        effect: '15 dakika boyunca 2x tüm gelir.',
        price: 4500,
        owned: ownedFromPrefs(8),
        maxStack: 3,
        category: ItemCategory.boost,
      ),
      Item(
        id: 9,
        name: 'Meteor Parçası',
        icon: '☄️',
        rarity: ItemRarity.legendary,
        description: 'İşletmelerinin üzerine meteorit düşürür (iyi anlamda).',
        effect: '+100% işletme geliri.',
        price: 8000,
        owned: ownedFromPrefs(9),
        maxStack: 2,
        category: ItemCategory.boost,
      ),
      Item(
        id: 10,
        name: 'Güneş Taşı',
        icon: '🌟',
        rarity: ItemRarity.mythic,
        description: 'Tüm ekonomini aydınlatan efsanevi taş.',
        effect: '+200% tüm gelir.',
        price: 25000,
        owned: ownedFromPrefs(10),
        maxStack: 1,
        category: ItemCategory.boost,
      ),
      Item(
        id: 11,
        name: 'Büyülü Zar',
        icon: '🎲',
        rarity: ItemRarity.rare,
        description: 'Risk sevenler için şans tılsımı.',
        effect: '%10 ihtimalle 5x kazanç.',
        price: 1500,
        owned: ownedFromPrefs(11),
        maxStack: 3,
        category: ItemCategory.boost,
      ),
      Item(
        id: 12,
        name: 'Kraliyet Yüzüğü',
        icon: '💍',
        rarity: ItemRarity.epic,
        description: 'Kral seviyesinde tıklama gücü.',
        effect: '+35% tıklama kazancı.',
        price: 3500,
        owned: ownedFromPrefs(12),
        maxStack: 2,
        category: ItemCategory.boost,
      ),
      Item(
        id: 13,
        name: 'Ateş Ruhu',
        icon: '🔥',
        rarity: ItemRarity.legendary,
        description: 'Kısa süreli aşırı kazanç patlaması.',
        effect: '20 dakika boyunca +150% tüm gelir.',
        price: 10000,
        owned: ownedFromPrefs(13),
        maxStack: 1,
        category: ItemCategory.boost,
      ),
      Item(
        id: 14,
        name: 'Buz Kristali',
        icon: '❄️',
        rarity: ItemRarity.rare,
        description: 'İşletmelerini soğukkanlı şekilde büyütür.',
        effect: '+18% işletme geliri.',
        price: 1800,
        owned: ownedFromPrefs(14),
        maxStack: 4,
        category: ItemCategory.boost,
      ),
      Item(
        id: 15,
        name: 'Şimşek Ampulü',
        icon: '💡',
        rarity: ItemRarity.epic,
        description: 'Tıklama hızını göz açıp kapayıncaya kadar artırır.',
        effect: '+40% tıklama hızı.',
        price: 4000,
        owned: ownedFromPrefs(15),
        maxStack: 2,
        category: ItemCategory.boost,
      ),

      // ⚙️ OTOMASYON
      Item(
        id: 16,
        name: 'Mini Tıklayıcı',
        icon: '🖱️',
        rarity: ItemRarity.common,
        description: 'Sen oynamasan bile yavaş yavaş tıklar.',
        effect: 'Her 10 saniyede 1 tıklama.',
        price: 250,
        owned: ownedFromPrefs(16),
        maxStack: 5,
        category: ItemCategory.automation,
      ),
      Item(
        id: 17,
        name: 'Hızlı Bot',
        icon: '🤖',
        rarity: ItemRarity.rare,
        description: 'Ortalama bir oyuncudan daha hızlı tıklar.',
        effect: 'Her 5 saniyede 1 tıklama.',
        price: 800,
        owned: ownedFromPrefs(17),
        maxStack: 3,
        category: ItemCategory.automation,
      ),
      Item(
        id: 18,
        name: 'Turbo Asistan',
        icon: '⚙️',
        rarity: ItemRarity.epic,
        description: 'Neredeyse sürekli tıklar.',
        effect: 'Her 2 saniyede 1 tıklama.',
        price: 2500,
        owned: ownedFromPrefs(18),
        maxStack: 2,
        category: ItemCategory.automation,
      ),
      Item(
        id: 19,
        name: 'AI İşçi',
        icon: '🧠',
        rarity: ItemRarity.legendary,
        description: 'Tam otomatik yapay zekâ işçi.',
        effect: 'Her saniye 1 tıklama.',
        price: 8000,
        owned: ownedFromPrefs(19),
        maxStack: 1,
        category: ItemCategory.automation,
      ),
      Item(
        id: 20,
        name: 'Para Mıknatısı',
        icon: '🧲',
        rarity: ItemRarity.rare,
        description: 'Etrafındaki pasif gelirleri otomatik toplar.',
        effect: 'Pasif gelirleri otomatik toplama.',
        price: 1200,
        owned: ownedFromPrefs(20),
        maxStack: 3,
        category: ItemCategory.automation,
      ),
      Item(
        id: 21,
        name: 'Akıllı Sistem',
        icon: '💻',
        rarity: ItemRarity.epic,
        description: 'İşletmelerini senin yerine yükseltir.',
        effect: 'Tüm işletmeleri otomatik yükselt.',
        price: 5000,
        owned: ownedFromPrefs(21),
        maxStack: 1,
        category: ItemCategory.automation,
      ),
      Item(
        id: 22,
        name: 'Kuantum İşlemci',
        icon: '⚛️',
        rarity: ItemRarity.mythic,
        description: 'Tüm otomasyonu ışık hızına çıkarır.',
        effect: 'Tüm otomasyon 2x daha hızlı.',
        price: 15000,
        owned: ownedFromPrefs(22),
        maxStack: 1,
        category: ItemCategory.automation,
      ),
      Item(
        id: 23,
        name: 'Robo Kol',
        icon: '🦾',
        rarity: ItemRarity.rare,
        description: 'Tıklama yükünü üzerinden alır.',
        effect: 'Her 3 saniyede 1 tıklama.',
        price: 1500,
        owned: ownedFromPrefs(23),
        maxStack: 4,
        category: ItemCategory.automation,
      ),
      Item(
        id: 24,
        name: 'Nano Botlar',
        icon: '🔬',
        rarity: ItemRarity.epic,
        description: 'Otomasyon hızını artıran minik botlar.',
        effect: '+30% otomasyon hızı.',
        price: 3500,
        owned: ownedFromPrefs(24),
        maxStack: 2,
        category: ItemCategory.automation,
      ),
      Item(
        id: 25,
        name: 'Otopark Yöneticisi',
        icon: '🏭',
        rarity: ItemRarity.legendary,
        description: 'İşletmelerini kendi kendine çalıştırır.',
        effect: 'İşletmeler kendi kendine sürekli çalışır.',
        price: 10000,
        owned: ownedFromPrefs(25),
        maxStack: 1,
        category: ItemCategory.automation,
      ),
      Item(
        id: 26,
        name: 'Hologram Asistan',
        icon: '👾',
        rarity: ItemRarity.epic,
        description: 'İşletmelerini holografik bir asistan destekler.',
        effect: '+20% işletme geliri.',
        price: 4000,
        owned: ownedFromPrefs(26),
        maxStack: 2,
        category: ItemCategory.automation,
      ),
      Item(
        id: 27,
        name: 'Drone Filosu',
        icon: '🚁',
        rarity: ItemRarity.rare,
        description: 'Gökyüzünden sürekli tıklama yağdırır.',
        effect: 'Her 4 saniyede 1 tıklama.',
        price: 2000,
        owned: ownedFromPrefs(27),
        maxStack: 3,
        category: ItemCategory.automation,
      ),
      Item(
        id: 28,
        name: 'Mega Server',
        icon: '🖥️',
        rarity: ItemRarity.mythic,
        description: 'Tüm otomasyonu tek noktadan kontrol eder.',
        effect: 'Tüm otomasyon efektleri aktif.',
        price: 20000,
        owned: ownedFromPrefs(28),
        maxStack: 1,
        category: ItemCategory.automation,
      ),

      // 📚 XP PEKİŞTİRİCİ
      Item(
        id: 29,
        name: 'Yıldız Tozu',
        icon: '✨',
        rarity: ItemRarity.common,
        description: 'Küçük ama etkili bir XP takviyesi.',
        effect: '+50 XP.',
        price: 50,
        owned: ownedFromPrefs(29),
        maxStack: 20,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 30,
        name: 'Deneyim İksiri',
        icon: '🧪',
        rarity: ItemRarity.rare,
        description: 'Bir yudumla ciddi tecrübe kazandırır.',
        effect: '+200 XP.',
        price: 200,
        owned: ownedFromPrefs(30),
        maxStack: 15,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 31,
        name: 'Bilgelik Kitabı',
        icon: '📖',
        rarity: ItemRarity.epic,
        description: 'Uzun okuma seansları için XP kaynağı.',
        effect: '+500 XP.',
        price: 500,
        owned: ownedFromPrefs(31),
        maxStack: 10,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 32,
        name: 'Antik Tomar',
        icon: '📜',
        rarity: ItemRarity.legendary,
        description: 'Kadim bilgelik içeren nadir bir tomar.',
        effect: '+1500 XP.',
        price: 1500,
        owned: ownedFromPrefs(32),
        maxStack: 5,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 33,
        name: 'XP Çarpanı',
        icon: '🔮',
        rarity: ItemRarity.epic,
        description: 'Kısa süreli XP kazanımını çarpar.',
        effect: '30 dakika boyunca 2x XP.',
        price: 3000,
        owned: ownedFromPrefs(33),
        maxStack: 3,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 34,
        name: 'Bilge Baykuş',
        icon: '🦉',
        rarity: ItemRarity.rare,
        description: 'Her hareketinden biraz daha fazla öğrenirsin.',
        effect: '+10% tüm XP kazancı.',
        price: 2000,
        owned: ownedFromPrefs(34),
        maxStack: 4,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 35,
        name: 'Öğrenci Rozeti',
        icon: '🎓',
        rarity: ItemRarity.common,
        description: 'Yeni başlayanlar için temel eğitim rozeti.',
        effect: '+100 XP.',
        price: 100,
        owned: ownedFromPrefs(35),
        maxStack: 15,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 36,
        name: 'Usta Sertifikası',
        icon: '📜',
        rarity: ItemRarity.epic,
        description: 'Deneyimli oyuncular için onay belgesi.',
        effect: '+750 XP.',
        price: 750,
        owned: ownedFromPrefs(36),
        maxStack: 8,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 37,
        name: 'Akıl Topu',
        icon: '🔮',
        rarity: ItemRarity.rare,
        description: 'Kısa sürede fazladan tecrübe kazandırır.',
        effect: '+300 XP.',
        price: 300,
        owned: ownedFromPrefs(37),
        maxStack: 12,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 38,
        name: 'Deneyim Kristali',
        icon: '💠',
        rarity: ItemRarity.legendary,
        description: 'Büyük miktarda deneyim depolar.',
        effect: '+2000 XP.',
        price: 2000,
        owned: ownedFromPrefs(38),
        maxStack: 3,
        category: ItemCategory.xpBoost,
      ),
      Item(
        id: 39,
        name: 'Guru Madalyası',
        icon: '🏅',
        rarity: ItemRarity.mythic,
        description: 'Gerçek ustalara verilen özel madalya.',
        effect: '60 dakika boyunca 3x XP.',
        price: 10000,
        owned: ownedFromPrefs(39),
        maxStack: 1,
        category: ItemCategory.xpBoost,
      ),

      // ⭐ ÖZEL
      Item(
        id: 40,
        name: 'Hazine Sandığı',
        icon: '🎁',
        rarity: ItemRarity.legendary,
        description: 'İçinden ne çıkacağı belli olmayan büyük sandık.',
        effect: '\$1000 – \$10000 rastgele ödül.',
        price: 5000,
        owned: ownedFromPrefs(40),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 41,
        name: 'Ejderha Yumurtası',
        icon: '🥚',
        rarity: ItemRarity.mythic,
        description: 'Uyuyan ejderhanın gücünü barındırır.',
        effect: '+100% tüm gelir.',
        price: 15000,
        owned: ownedFromPrefs(41),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 42,
        name: 'Şans Ruleti',
        icon: '🎰',
        rarity: ItemRarity.epic,
        description: 'Günlük bonus ruletini açar.',
        effect: 'Günlük bonus rulet.',
        price: 3000,
        owned: ownedFromPrefs(42),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 43,
        name: 'Altın Kaz',
        icon: '🦢',
        rarity: ItemRarity.legendary,
        description: 'Sürekli altın yumurtlar.',
        effect: 'Saatte \$500 pasif gelir.',
        price: 8000,
        owned: ownedFromPrefs(43),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 44,
        name: 'Sihirli Lamba',
        icon: '🪔',
        rarity: ItemRarity.mythic,
        description: 'İçindeki cin sana 3 özel istek sunar.',
        effect: '3 özel istek hakkı (tasarımsal).',
        price: 20000,
        owned: ownedFromPrefs(44),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 45,
        name: 'Otomatik Tıklayıcı',
        icon: '🤖',
        rarity: ItemRarity.epic,
        description: 'Sen dokunmadan tıklamaya devam eder.',
        effect: 'Saniyede 1 otomatik tıklama.',
        price: 5000,
        owned: ownedFromPrefs(45),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 46,
        name: 'Zaman Makinesi',
        icon: '⏱️',
        rarity: ItemRarity.legendary,
        description: 'Gelecekteki kazançları bugüne çeker.',
        effect: '1 saatlik geliri anında verir.',
        price: 12000,
        owned: ownedFromPrefs(46),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 47,
        name: 'Feniks Kuşu',
        icon: '🦅',
        rarity: ItemRarity.mythic,
        description: 'Kaybettiklerini geri getirir.',
        effect: 'Kayıp verileri / ilerlemeyi geri yükleme (tasarımsal).',
        price: 25000,
        owned: ownedFromPrefs(47),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 48,
        name: 'Unicorn Pet',
        icon: '🦄',
        rarity: ItemRarity.legendary,
        description: 'Yanında dolaşan efsanevi destek.',
        effect: '+75% tüm gelir.',
        price: 10000,
        owned: ownedFromPrefs(48),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 49,
        name: 'Yıldız Gemisi',
        icon: '🚀',
        rarity: ItemRarity.mythic,
        description: 'Özel uzay görevlerine açılan kapı.',
        effect: 'Özel uzay görevi (event/mini-game için hook).',
        price: 30000,
        owned: ownedFromPrefs(49),
        maxStack: 1,
        category: ItemCategory.special,
      ),
      Item(
        id: 50,
        name: 'Kraliyet Scepter',
        icon: '👑',
        rarity: ItemRarity.mythic,
        description: 'Ekonomini yöneten en güçlü asa.',
        effect: '+250% tüm gelir.',
        price: 50000,
        owned: ownedFromPrefs(50),
        maxStack: 1,
        category: ItemCategory.special,
      ),
    ];
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