import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final double target;
  double progress;
  final String rarity;
  final Map<String, dynamic> reward;
  bool isCompleted;
  DateTime? completedAt;
  bool isSecret;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.target,
    this.progress = 0,
    this.rarity = 'common',
    required this.reward,
    this.isCompleted = false,
    this.completedAt,
    this.isSecret = false,
  });

  double get progressPercentage =>
      progress >= target ? 100 : (progress / target * 100);
  bool get canClaim => progress >= target && !isCompleted;

  static Color getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return const Color(0xFF6B7280);
      case 'rare':
        return const Color(0xFF3B82F6);
      case 'epic':
        return const Color(0xFF9333EA);
      case 'legendary':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static List<Color> getRarityGradient(String rarity) {
    switch (rarity) {
      case 'common':
        return [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)];
      case 'rare':
        return [const Color(0xFFDCEEFF), const Color(0xFFBAE6FF)];
      case 'epic':
        return [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)];
      case 'legendary':
        return [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)];
      default:
        return [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)];
    }
  }

  static String getCategoryName(String category) {
    switch (category) {
      case 'money':
        return 'Para';
      case 'clicks':
        return 'Tıklama';
      case 'business':
        return 'İşletme';
      case 'level':
        return 'Seviye';
      case 'items':
        return 'Eşya';
      case 'category':
        return 'Kategori';
      case 'speed':
        return 'Hız';
      case 'gameplay':
        return 'Oyun';
      case 'secret':
        return 'Gizli';
      default:
        return 'Diğer';
    }
  }

  static String getCategoryIcon(String category) {
    switch (category) {
      case 'money':
        return '💰';
      case 'clicks':
        return '👆';
      case 'business':
        return '🏢';
      case 'level':
        return '⭐';
      case 'items':
        return '🎒';
      case 'category':
        return '⚡';
      case 'speed':
        return '⏱️';
      case 'gameplay':
        return '🎮';
      case 'secret':
        return '🎁';
      default:
        return '🏆';
    }
  }

  static List<Achievement> getInitialAchievements() {
    return [
      // PARA BAŞARIMLARI (10)
      Achievement(
          id: 'm1',
          name: 'İlk Adım',
          description: 'İlk 100\$ kazan',
          icon: '💵',
          category: 'money',
          target: 100,
          reward: {'money': 50, 'xp': 25},
          rarity: 'common'),
      Achievement(
          id: 'm2',
          name: 'Küçük Servet',
          description: '1,000\$ kazan',
          icon: '💰',
          category: 'money',
          target: 1000,
          reward: {'money': 200, 'xp': 100},
          rarity: 'common'),
      Achievement(
          id: 'm3',
          name: 'Zenginlik',
          description: '10,000\$ kazan',
          icon: '💎',
          category: 'money',
          target: 10000,
          reward: {'money': 1000, 'xp': 500},
          rarity: 'rare'),
      Achievement(
          id: 'm4',
          name: 'Milyoner Yolunda',
          description: '100,000\$ kazan',
          icon: '💸',
          category: 'money',
          target: 100000,
          reward: {'money': 5000, 'xp': 2000},
          rarity: 'rare'),
      Achievement(
          id: 'm5',
          name: 'Milyoner',
          description: '1,000,000\$ kazan',
          icon: '🤑',
          category: 'money',
          target: 1000000,
          reward: {'money': 50000, 'xp': 10000},
          rarity: 'epic'),
      Achievement(
          id: 'm6',
          name: 'Multi-Milyoner',
          description: '10,000,000\$ kazan',
          icon: '💲',
          category: 'money',
          target: 10000000,
          reward: {'money': 500000, 'xp': 50000},
          rarity: 'epic'),
      Achievement(
          id: 'm7',
          name: 'Milyarder Adayı',
          description: '100,000,000\$ kazan',
          icon: '🏦',
          category: 'money',
          target: 100000000,
          reward: {'money': 5000000, 'xp': 200000},
          rarity: 'legendary'),
      Achievement(
          id: 'm8',
          name: 'Milyarder',
          description: '1,000,000,000\$ kazan',
          icon: '👑',
          category: 'money',
          target: 1000000000,
          reward: {'money': 50000000, 'xp': 1000000},
          rarity: 'legendary'),
      Achievement(
          id: 'm9',
          name: 'Harcama Kralı',
          description: 'Toplam 100,000\$ harca',
          icon: '🛒',
          category: 'money',
          target: 100000,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'rare'),
      Achievement(
          id: 'm10',
          name: 'Yatırımcı',
          description: 'Toplam 1,000,000\$ harca',
          icon: '📊',
          category: 'money',
          target: 1000000,
          reward: {'money': 100000, 'xp': 50000},
          rarity: 'epic'),

      // TIKLAMA BAŞARIMLARI (8)
      Achievement(
          id: 'c1',
          name: 'İlk Tık',
          description: '1 kez tıkla',
          icon: '☝️',
          category: 'clicks',
          target: 1,
          reward: {'money': 10, 'xp': 5},
          rarity: 'common'),
      Achievement(
          id: 'c2',
          name: 'Tıklama Delisi',
          description: '100 kez tıkla',
          icon: '👆',
          category: 'clicks',
          target: 100,
          reward: {'money': 100, 'xp': 50},
          rarity: 'common'),
      Achievement(
          id: 'c3',
          name: 'Tıklama Ustası',
          description: '1,000 kez tıkla',
          icon: '✊',
          category: 'clicks',
          target: 1000,
          reward: {'money': 500, 'xp': 250},
          rarity: 'rare'),
      Achievement(
          id: 'c4',
          name: 'Tıklama Efsanesi',
          description: '10,000 kez tıkla',
          icon: '💪',
          category: 'clicks',
          target: 10000,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'epic'),
      Achievement(
          id: 'c5',
          name: 'Tıklama Tanrısı',
          description: '100,000 kez tıkla',
          icon: '⚡',
          category: 'clicks',
          target: 100000,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'legendary'),
      Achievement(
          id: 'c6',
          name: 'Combo Master',
          description: '50 combo yap',
          icon: '🔥',
          category: 'clicks',
          target: 50,
          reward: {'money': 2000, 'xp': 1000},
          rarity: 'rare'),
      Achievement(
          id: 'c7',
          name: 'Hız Canavarı',
          description: '10 saniyede 50 tıklama',
          icon: '⚡',
          category: 'clicks',
          target: 50,
          reward: {'money': 3000, 'xp': 1500},
          rarity: 'epic'),
      Achievement(
          id: 'c8',
          name: 'Maraton',
          description: 'Tek oturumda 5,000 tıklama',
          icon: '🏃',
          category: 'clicks',
          target: 5000,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),

      // İŞLETME BAŞARIMLARI (12)
      Achievement(
          id: 'b1',
          name: 'İlk İşletme',
          description: 'İlk işletmeni aç',
          icon: '🏪',
          category: 'business',
          target: 1,
          reward: {'money': 100, 'xp': 50},
          rarity: 'common'),
      Achievement(
          id: 'b2',
          name: 'Küçük İşletmeci',
          description: '3 farklı işletme',
          icon: '🏬',
          category: 'business',
          target: 3,
          reward: {'money': 500, 'xp': 250},
          rarity: 'common'),
      Achievement(
          id: 'b3',
          name: 'Büyüyen İmparatorluk',
          description: '5 farklı işletme',
          icon: '🏢',
          category: 'business',
          target: 5,
          reward: {'money': 2000, 'xp': 1000},
          rarity: 'rare'),
      Achievement(
          id: 'b4',
          name: 'İş İmparatorluğu',
          description: 'Tüm işletmeleri aç',
          icon: '🏛️',
          category: 'business',
          target: 12,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'b5',
          name: 'Yükseltme Başlangıcı',
          description: 'Herhangi bir işletmeyi lv5 yap',
          icon: '📈',
          category: 'business',
          target: 5,
          reward: {'money': 1000, 'xp': 500},
          rarity: 'common'),
      Achievement(
          id: 'b6',
          name: 'Yükseltme Ustası',
          description: 'Herhangi bir işletmeyi lv10 yap',
          icon: '📊',
          category: 'business',
          target: 10,
          reward: {'money': 3000, 'xp': 1500},
          rarity: 'rare'),
      Achievement(
          id: 'b7',
          name: 'Yükseltme Efsanesi',
          description: 'Herhangi bir işletmeyi lv25 yap',
          icon: '🚀',
          category: 'business',
          target: 25,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'b8',
          name: 'Maksimum Güç',
          description: 'Herhangi bir işletmeyi lv50 yap',
          icon: '⚡',
          category: 'business',
          target: 50,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'legendary'),
      Achievement(
          id: 'b9',
          name: 'Limonata Baronu',
          description: 'Limonata standını lv20 yap',
          icon: '🍋',
          category: 'business',
          target: 20,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'rare'),
      Achievement(
          id: 'b10',
          name: 'Medya Patronu',
          description: 'Gazete dağıtımını lv15 yap',
          icon: '📰',
          category: 'business',
          target: 15,
          reward: {'money': 4000, 'xp': 2000},
          rarity: 'rare'),
      Achievement(
          id: 'b11',
          name: 'Teknoloji Devi',
          description: 'Yazılım şirketini lv10 yap',
          icon: '💻',
          category: 'business',
          target: 10,
          reward: {'money': 8000, 'xp': 4000},
          rarity: 'epic'),
      Achievement(
          id: 'b12',
          name: 'Uzay Yöneticisi',
          description: 'Uzay madenciliğini lv5 yap',
          icon: '🚀',
          category: 'business',
          target: 5,
          reward: {'money': 15000, 'xp': 7500},
          rarity: 'legendary'),

      // SEVİYE BAŞARIMLARI (10)
      Achievement(
          id: 'l1',
          name: 'Acemi',
          description: 'Seviye 5\'e ulaş',
          icon: '🌱',
          category: 'level',
          target: 5,
          reward: {'money': 500, 'xp': 250},
          rarity: 'common'),
      Achievement(
          id: 'l2',
          name: 'Deneyimli',
          description: 'Seviye 10\'a ulaş',
          icon: '🌿',
          category: 'level',
          target: 10,
          reward: {'money': 1500, 'xp': 750},
          rarity: 'common'),
      Achievement(
          id: 'l3',
          name: 'Usta',
          description: 'Seviye 25\'e ulaş',
          icon: '🌳',
          category: 'level',
          target: 25,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'rare'),
      Achievement(
          id: 'l4',
          name: 'Uzman',
          description: 'Seviye 50\'ye ulaş',
          icon: '🏆',
          category: 'level',
          target: 50,
          reward: {'money': 20000, 'xp': 10000},
          rarity: 'epic'),
      Achievement(
          id: 'l5',
          name: 'Efsane',
          description: 'Seviye 75\'e ulaş',
          icon: '👑',
          category: 'level',
          target: 75,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'epic'),
      Achievement(
          id: 'l6',
          name: 'Tanrı',
          description: 'Seviye 100\'e ulaş',
          icon: '⚡',
          category: 'level',
          target: 100,
          reward: {'money': 100000, 'xp': 50000},
          rarity: 'legendary'),
      Achievement(
          id: 'l7',
          name: 'XP Avcısı',
          description: '10,000 XP kazan',
          icon: '📚',
          category: 'level',
          target: 10000,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'rare'),
      Achievement(
          id: 'l8',
          name: 'XP Ustası',
          description: '50,000 XP kazan',
          icon: '📖',
          category: 'level',
          target: 50000,
          reward: {'money': 15000, 'xp': 7500},
          rarity: 'epic'),
      Achievement(
          id: 'l9',
          name: 'XP Efsanesi',
          description: '100,000 XP kazan',
          icon: '📜',
          category: 'level',
          target: 100000,
          reward: {'money': 30000, 'xp': 15000},
          rarity: 'epic'),
      Achievement(
          id: 'l10',
          name: 'XP Tanrısı',
          description: '500,000 XP kazan',
          icon: '🔮',
          category: 'level',
          target: 500000,
          reward: {'money': 100000, 'xp': 50000},
          rarity: 'legendary'),

      // EŞYA BAŞARIMLARI (10)
      Achievement(
          id: 'i1',
          name: 'İlk Satın Alma',
          description: 'İlk eşyanı al',
          icon: '🛍️',
          category: 'items',
          target: 1,
          reward: {'money': 100, 'xp': 50},
          rarity: 'common'),
      Achievement(
          id: 'i2',
          name: 'Koleksiyoncu',
          description: '5 farklı eşya',
          icon: '🎒',
          category: 'items',
          target: 5,
          reward: {'money': 500, 'xp': 250},
          rarity: 'common'),
      Achievement(
          id: 'i3',
          name: 'Büyük Koleksiyoncu',
          description: '10 farklı eşya',
          icon: '🧳',
          category: 'items',
          target: 10,
          reward: {'money': 1500, 'xp': 750},
          rarity: 'rare'),
      Achievement(
          id: 'i4',
          name: 'Eşya Avcısı',
          description: '25 farklı eşya',
          icon: '🎯',
          category: 'items',
          target: 25,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'epic'),
      Achievement(
          id: 'i5',
          name: 'Tam Koleksiyon',
          description: '50 eşya topla',
          icon: '🏆',
          category: 'items',
          target: 50,
          reward: {'money': 20000, 'xp': 10000},
          rarity: 'legendary'),
      Achievement(
          id: 'i6',
          name: 'Nadir Avcı',
          description: '5 nadir eşya',
          icon: '💎',
          category: 'items',
          target: 5,
          reward: {'money': 2000, 'xp': 1000},
          rarity: 'rare'),
      Achievement(
          id: 'i7',
          name: 'Epik Koleksiyoncu',
          description: '5 epik eşya',
          icon: '💜',
          category: 'items',
          target: 5,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'epic'),
      Achievement(
          id: 'i8',
          name: 'Efsane Avcısı',
          description: '3 efsanevi eşya',
          icon: '🌟',
          category: 'items',
          target: 3,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'i9',
          name: 'Mitik Koleksiyoncu',
          description: '1 mitik eşya',
          icon: '🔥',
          category: 'items',
          target: 1,
          reward: {'money': 15000, 'xp': 7500},
          rarity: 'legendary'),
      Achievement(
          id: 'i10',
          name: 'Tam Mitik',
          description: 'Tüm mitik eşyaları topla',
          icon: '👑',
          category: 'items',
          target: 6,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'legendary'),

      // KATEGORİ UZMANLIĞI (8)
      Achievement(
          id: 'cat1',
          name: 'Güçlendirme Ustası',
          description: 'Tüm güçlendiricileri al',
          icon: '⚡',
          category: 'category',
          target: 15,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'cat2',
          name: 'Otomasyon Kralı',
          description: 'Tüm otomasyon eşyalarını al',
          icon: '⚙️',
          category: 'category',
          target: 13,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'cat3',
          name: 'Öğrenme Tutkusu',
          description: 'Tüm XP pekiştiricileri al',
          icon: '📚',
          category: 'category',
          target: 11,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'cat4',
          name: 'Özel Koleksiyoncu',
          description: 'Tüm özel eşyaları al',
          icon: '⭐',
          category: 'category',
          target: 11,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'cat5',
          name: 'Yaygın Tamamlayıcı',
          description: 'Tüm yaygın eşyaları al',
          icon: '📦',
          category: 'category',
          target: 5,
          reward: {'money': 2000, 'xp': 1000},
          rarity: 'rare'),
      Achievement(
          id: 'cat6',
          name: 'Nadir Tamamlayıcı',
          description: 'Tüm nadir eşyaları al',
          icon: '💎',
          category: 'category',
          target: 15,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'epic'),
      Achievement(
          id: 'cat7',
          name: 'Epik Tamamlayıcı',
          description: 'Tüm epik eşyaları al',
          icon: '💜',
          category: 'category',
          target: 20,
          reward: {'money': 15000, 'xp': 7500},
          rarity: 'epic'),
      Achievement(
          id: 'cat8',
          name: 'Efsane Tamamlayıcı',
          description: 'Tüm efsanevi eşyaları al',
          icon: '🌟',
          category: 'category',
          target: 10,
          reward: {'money': 30000, 'xp': 15000},
          rarity: 'legendary'),

      // HIZ BAŞARIMLARI (6)
      Achievement(
          id: 's1',
          name: 'Hızlı Başlangıç',
          description: 'İlk 1000\$ 5 dakikada',
          icon: '⚡',
          category: 'speed',
          target: 1000,
          reward: {'money': 500, 'xp': 250},
          rarity: 'rare'),
      Achievement(
          id: 's2',
          name: 'Hızlı Büyüme',
          description: '10,000\$ 1 saatte',
          icon: '🚀',
          category: 'speed',
          target: 10000,
          reward: {'money': 3000, 'xp': 1500},
          rarity: 'epic'),
      Achievement(
          id: 's3',
          name: 'Turbo Mod',
          description: '100,000\$ 1 saatte',
          icon: '💨',
          category: 'speed',
          target: 100000,
          reward: {'money': 20000, 'xp': 10000},
          rarity: 'legendary'),
      Achievement(
          id: 's4',
          name: 'Pasif Gelir Pro',
          description: 'İşletmelerden 1 saatte 50,000\$',
          icon: '💰',
          category: 'speed',
          target: 50000,
          reward: {'money': 15000, 'xp': 7500},
          rarity: 'epic'),
      Achievement(
          id: 's5',
          name: 'Saniyede Para',
          description: 'Saniyede 100\$ pasif gelir',
          icon: '💸',
          category: 'speed',
          target: 100,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 's6',
          name: 'Para Makinesi',
          description: 'Saniyede 1,000\$ pasif gelir',
          icon: '🏦',
          category: 'speed',
          target: 1000,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'legendary'),

      // OYUN USTALĞI (4)
      Achievement(
          id: 'g1',
          name: 'Günlük Oyuncu',
          description: '7 gün üst üste giriş',
          icon: '📅',
          category: 'gameplay',
          target: 7,
          reward: {'money': 2000, 'xp': 1000},
          rarity: 'rare'),
      Achievement(
          id: 'g2',
          name: 'Sadık Oyuncu',
          description: '30 gün üst üste giriş',
          icon: '🗓️',
          category: 'gameplay',
          target: 30,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'epic'),
      Achievement(
          id: 'g3',
          name: 'Veteran',
          description: '100 gün üst üste giriş',
          icon: '📆',
          category: 'gameplay',
          target: 100,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'legendary'),
      Achievement(
          id: 'g4',
          name: 'Efsane Oyuncu',
          description: '365 gün üst üste giriş',
          icon: '👑',
          category: 'gameplay',
          target: 365,
          reward: {'money': 200000, 'xp': 100000},
          rarity: 'legendary'),

      // GİZLİ BAŞARIMLAR (5)
      Achievement(
          id: 'sec1',
          name: 'Gece Kuşu',
          description: 'Gece 3\'te oyuna gir',
          icon: '🦉',
          category: 'secret',
          target: 1,
          reward: {'money': 3000, 'xp': 1500},
          rarity: 'rare',
          isSecret: true),
      Achievement(
          id: 'sec2',
          name: 'Şanslı Yedi',
          description: 'Bakiyesi tam 7,777\$ olsun',
          icon: '🎰',
          category: 'secret',
          target: 1,
          reward: {'money': 7777, 'xp': 3000},
          rarity: 'epic',
          isSecret: true),
      Achievement(
          id: 'sec3',
          name: 'Mükemmeliyetçi',
          description: 'Tüm sayıları yuvarlak rakamda tut',
          icon: '🎯',
          category: 'secret',
          target: 1,
          reward: {'money': 5000, 'xp': 2500},
          rarity: 'epic',
          isSecret: true),
      Achievement(
          id: 'sec4',
          name: 'İlk Günün Anısı',
          description: 'İlk gün 10,000\$ kazan',
          icon: '🎉',
          category: 'secret',
          target: 10000,
          reward: {'money': 10000, 'xp': 5000},
          rarity: 'legendary',
          isSecret: true),
      Achievement(
          id: 'sec5',
          name: 'Hızlı Zengin',
          description: 'İlk 1 saatte 100,000\$ kazan',
          icon: '⚡',
          category: 'secret',
          target: 100000,
          reward: {'money': 50000, 'xp': 25000},
          rarity: 'legendary',
          isSecret: true),
    ];
  }
}


