import 'dart:async'; // Timer için gerekli
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/game_provider.dart';

class ItemsTab extends StatefulWidget {
  const ItemsTab({Key? key}) : super(key: key);

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  // --- STATE DEĞİŞKENLERİ ---
  String selectedCategory = 'all';
  String selectedRarity = 'all';
  String sortBy = 'default';

  // UI'daki geri sayımı yenilemek için genel bir ticker
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // --- LOGIC (MANTIK) ---
  @override
  void initState() {
    super.initState();
    // Her saniye rebuild ederek geri sayımın güncel kalmasını sağla
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // Süresi dolan varsa GameProvider üzerinden tüket
      final game = context.read<GameProvider>();
      final now = DateTime.now();
      for (final item in game.items) {
        final endTime = game.itemUseEndTimes[item.id];
        if (endTime != null && !endTime.isAfter(now)) {
          game.consumeTimedItem(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} süresi doldu!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      setState(() {});
    });
  }

  Map<String, int> _categoryCount(List<Item> items) {
    return {
      'all': items.length,
      'enhancer': items.where((i) => i.category == ItemCategory.boost).length,
      'automation': items.where((i) => i.category == ItemCategory.automation).length,
      'xp_booster': items.where((i) => i.category == ItemCategory.xpBoost).length,
      'special': items.where((i) => i.category == ItemCategory.special).length,
    };
  }

  int _ownedCount(List<Item> items) => items.where((i) => i.owned > 0).length;

  List<Item> _filteredItems(List<Item> items, GameProvider game) {
    var filtered = items.where((item) {
      bool categoryMatch;
      switch (selectedCategory) {
        case 'enhancer': categoryMatch = item.category == ItemCategory.boost; break;
        case 'automation': categoryMatch = item.category == ItemCategory.automation; break;
        case 'xp_booster': categoryMatch = item.category == ItemCategory.xpBoost; break;
        case 'special': categoryMatch = item.category == ItemCategory.special; break;
        case 'all': default: categoryMatch = true;
      }
      final rarityMatch = selectedRarity == 'all' || item.rarity.name == selectedRarity;
      return categoryMatch && rarityMatch;
    }).toList();

    switch (sortBy) {
      case 'price_low':
        filtered.sort((a, b) => game.getItemCurrentPrice(a).compareTo(game.getItemCurrentPrice(b)));
        break;
      case 'price_high':
        filtered.sort((a, b) => game.getItemCurrentPrice(b).compareTo(game.getItemCurrentPrice(a)));
        break;
      case 'rarity':
        final order = {'common': 0, 'rare': 1, 'epic': 2, 'legendary': 3, 'mythic': 4};
        filtered.sort((a, b) => (order[b.rarity.name] ?? 0).compareTo(order[a.rarity.name] ?? 0));
        break;
      case 'default': default: break;
    }
    return filtered;
  }

  void clearFilters() {
    setState(() {
      selectedCategory = 'all';
      selectedRarity = 'all';
      sortBy = 'default';
    });
  }

  // 5 DAKİKA KURALI MANTIĞI
  void _handleUseItem(Item item, GameProvider game) {
    if (item.owned <= 0) return;
    final endTime = game.itemUseEndTimes[item.id];
    if (endTime != null && endTime.isAfter(DateTime.now())) {
      // Zaten aktifse yeniden başlatma
      return;
    }

    // 5 Dakikalık süreyi GameProvider üzerinden başlat
    game.startItemUseTimer(item, const Duration(minutes: 5));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} aktif edildi! (5 dk)'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBuyItem(Item item, GameProvider game) {
    final success = game.buyItem(item);
    String message;
    Color color;

    if (!success) {
      final currentPrice = game.getItemCurrentPrice(item);
      if (item.owned >= item.maxStack) {
        message = 'Maksimum!';
        color = Colors.redAccent;
      } else if (game.balance < currentPrice) {
        message = 'Yetersiz Bakiye!';
        color = Colors.orangeAccent;
      } else {
        message = 'Hata.';
        color = Colors.red;
      }
    } else {
      message = 'Satın alındı!';
      color = const Color(0xFF00C853);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12), // Margin küçültüldü
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding küçültüldü
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final items = game.items;
    final categoryCount = _categoryCount(items);
    final filtered = _filteredItems(items, game);

    return Container(
      // Arka plan rengi temaya göre değişsin (ışık / karanlık)
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // 1. KOMPAKT HEADER
          _buildCompactHeader(game, items),

          const SizedBox(height: 12),

          // 2. KATEGORİ SEÇİCİ (Daha ince)
          SizedBox(
            height: 36, // Yükseklik 50'den 36'ya düşürüldü
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCompactTab('all', 'Tümü', categoryCount['all'] ?? 0),
                _buildCompactTab('enhancer', 'Güç', categoryCount['enhancer'] ?? 0),
                _buildCompactTab('automation', 'Oto', categoryCount['automation'] ?? 0),
                _buildCompactTab('xp_booster', 'XP', categoryCount['xp_booster'] ?? 0),
                _buildCompactTab('special', 'Özel', categoryCount['special'] ?? 0),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. FİLTRE KONTROLLERİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Market',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _buildMiniFilterButton(
                  icon: Icons.filter_list,
                  label: selectedRarity == 'all' ? 'Tüm Nadirlikler' : _rarityName(ItemRarity.values.firstWhere((e) => e.name == selectedRarity)),
                  onTap: () => _showRaritySheet(context),
                  isActive: selectedRarity != 'all',
                ),
                const SizedBox(width: 8),
                _buildMiniFilterButton(
                  icon: Icons.sort,
                  label: 'Sırala',
                  onTap: () => _showSortSheet(context),
                  isActive: sortBy != 'default',
                ),
                if (selectedCategory != 'all' || selectedRarity != 'all' || sortBy != 'default') ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: clearFilters,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.red),
                    ),
                  )
                ]
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 4. LİSTE
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildCompactItemCard(filtered[index], game);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPACT COMPONENTS ---

  Widget _buildCompactHeader(GameProvider game, List<Item> items) {
    final ownedCount = _ownedCount(items);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), // Paddingler küçültüldü
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Envanter',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$ownedCount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '/${items.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bakiye (Küçültülmüş)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336C5CE7),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  '\$${game.balance.toInt()}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Monospace'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTab(String id, String label, int count) {
    final isSelected = selectedCategory == id;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D3436) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 0.5
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 11, // Font küçültüldü
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF00BCD4) : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? const Color(0xFF0097A7) : Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF0097A7) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactItemCard(Item item, GameProvider game) {
    final currentPrice = game.getItemCurrentPrice(item);
    final canAfford = game.balance >= currentPrice;
    final accentColor = _rarityColor(item.rarity);

    // Timer Durumu
    final DateTime? endTime = game.itemUseEndTimes[item.id];
    bool isActive = false;
    int remaining = 0;
    if (endTime != null) {
      final diff = endTime.difference(DateTime.now()).inSeconds;
      if (diff > 0) {
        isActive = true;
        remaining = diff;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Margin azaltıldı
      padding: const EdgeInsets.all(10), // Padding azaltıldı
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // İKON (Küçültüldü)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),

          const SizedBox(width: 12),

          // BİLGİLER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14, // Font küçültüldü
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    // Nadirlik Noktası
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                // Fiyat
                Text(
                  '\$${currentPrice.toInt()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: canAfford ? Colors.black87 : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // AKSİYON BUTONLARI
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. SATIN AL BUTONU (Kompakt)
              InkWell(
                onTap: () => _handleBuyItem(item, game),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford ? const Color(0xFFF1F2F6) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canAfford ? Colors.grey.shade300 : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'SATIN AL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.black87 : Colors.red,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // 2. KULLAN BUTONU (Eğer sahipse ve aktif değilse)
              if (item.owned > 0 && !isActive)
                InkWell(
                  onTap: () => _handleUseItem(item, game),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00B894), Color(0xFF00CEC9)]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00B894).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          'KULLAN (${item.owned})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. AKTİF DURUM (Geri Sayım)
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 8, height: 8,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(remaining ~/ 60)}:${(remaining % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ACTIONSHEET MENÜLERİ ---

  void _showRaritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nadirlik Filtresi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // DÜZELTME BURADA YAPILDI: "Tüm Nadirlikler"
                  _buildSheetOption('all', 'Tüm Nadirlikler', selectedRarity == 'all', (val) {
                    setState(() => selectedRarity = val);
                    Navigator.pop(ctx);
                  }),
                  ...ItemRarity.values.map((r) => _buildSheetOption(
                      r.name,
                      _rarityName(r),
                      selectedRarity == r.name,
                          (val) {
                        setState(() => selectedRarity = val);
                        Navigator.pop(ctx);
                      }
                  )).toList(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sıralama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                leading: const Icon(Icons.sort, size: 20),
                title: const Text('Varsayılan', style: TextStyle(fontSize: 14)),
                selected: sortBy == 'default',
                onTap: () { setState(() => sortBy = 'default'); Navigator.pop(ctx); },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                title: const Text('Fiyat: Düşükten Yükseğe', style: TextStyle(fontSize: 14)),
                selected: sortBy == 'price_low',
                onTap: () { setState(() => sortBy = 'price_low'); Navigator.pop(ctx); },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                title: const Text('Fiyat: Yüksekten Düşüğe', style: TextStyle(fontSize: 14)),
                selected: sortBy == 'price_high',
                onTap: () { setState(() => sortBy = 'price_high'); Navigator.pop(ctx); },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetOption(String value, String label, bool isSelected, Function(String) onSelect) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
      selected: isSelected,
      onSelected: (bool selected) {
        if(selected) onSelect(value);
      },
      selectedColor: const Color(0xFF6C5CE7),
      backgroundColor: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Eşya Bulunamadı',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// --- YARDIMCI RENK VE METİN FONKSİYONLARI ---

Color _rarityColor(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common: return const Color(0xFFB2BEC3);
    case ItemRarity.rare: return const Color(0xFF0984E3);
    case ItemRarity.epic: return const Color(0xFF6C5CE7);
    case ItemRarity.legendary: return const Color(0xFFFDCB6E);
    case ItemRarity.mythic: return const Color(0xFFFF7675);
  }
}

String _rarityName(ItemRarity? rarity) {
  if (rarity == null) return 'Tüm Nadirlikler';
  switch (rarity) {
    case ItemRarity.common: return 'Yaygın';
    case ItemRarity.rare: return 'Nadir';
    case ItemRarity.epic: return 'Epik';
    case ItemRarity.legendary: return 'Efsanevi';
    case ItemRarity.mythic: return 'Mitik';
  }
}