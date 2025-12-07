import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/game_provider.dart';

enum _CategoryFilter {
  all,
  boost, // Güçlendirici
  automation,
  xpBoost,
  special,
}

enum _RarityFilter {
  all,
  common,
  rare,
  epic,
  legendary,
  mythic,
}

enum _SortOption {
  defaultOption,
  priceAsc,
  priceDesc,
  rarity,
}

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  static const int _maxInventorySize = 50;

  _CategoryFilter _selectedCategory = _CategoryFilter.all;
  _RarityFilter _selectedRarity = _RarityFilter.all;
  _SortOption _selectedSort = _SortOption.defaultOption;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final items = game.items;
    final ownedItems = game.ownedItems;

    // Filtre + sıralama uygulanmış liste
    final filteredItems = _applyFiltersAndSorting(items);

    final ownedCount = ownedItems.length;
    final itemCount = filteredItems.length;

    final hasActiveFilters = _selectedCategory != _CategoryFilter.all ||
        _selectedRarity != _RarityFilter.all ||
        _selectedSort != _SortOption.defaultOption;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          _buildHeader(balance: game.balance, ownedCount: ownedCount),
          const SizedBox(height: 16),

          // KATEGORİ CHIPS
          _buildCategoryChips(),
          const SizedBox(height: 16),

          // DROPDOWN ROW
          _buildFilterDropdownRow(),
          const SizedBox(height: 12),

          // SONUÇ ÖZETİ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount eşya bulundu',
                style: const TextStyle(
                  fontFamily: 'Titillium Web',
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              if (hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = _CategoryFilter.all;
                      _selectedRarity = _RarityFilter.all;
                      _selectedSort = _SortOption.defaultOption;
                    });
                  },
                  child: const Text(
                    '✕ Filtreleri Temizle',
                    style: TextStyle(
                      fontFamily: 'Titillium Web',
                      fontSize: 13,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // EŞYA LİSTESİ / EMPTY STATE
          if (filteredItems.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final price = game.getItemCurrentPrice(item);
                final canBuy = game.balance >= price;

                return _ItemCard(
                  item: item,
                  price: price,
                  canBuy: canBuy,
                  onBuy: () => game.buyItem(item),
                );
              },
            ),

          const SizedBox(height: 24),

          // ENVANTER BÖLÜMÜ
          const Text(
            'Envanterim',
            style: TextStyle(
              fontFamily: 'Titillium Web',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (ownedItems.isEmpty)
            const Text(
              'Henüz eşya satın almadın. Güçlendiricileri yukarıdan satın alabilirsin.',
              style: TextStyle(
                fontFamily: 'Titillium Web',
                fontSize: 14,
                color: Colors.white70,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ownedItems
                  .map((item) => _InventoryChip(item: item))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader({
    required double balance,
    required int ownedCount,
  }) {
    final ownedText = '$ownedCount/$_maxInventorySize Eşya';
    final balanceText = '\$${balance.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Envanter',
                  style: TextStyle(
                    fontFamily: 'Titillium Web',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ownedText,
                  style: const TextStyle(
                    fontFamily: 'Titillium Web',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Bakiye',
                style: TextStyle(
                  fontFamily: 'Titillium Web',
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                balanceText,
                style: const TextStyle(
                  fontFamily: 'Titillium Web',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // KATEGORİ CHIPS
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(
            icon: '📦',
            label: 'Tümü',
            filter: _CategoryFilter.all,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            icon: '⚡',
            label: 'Güçlendirici',
            filter: _CategoryFilter.boost,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            icon: '⚙️',
            label: 'Otomasyon',
            filter: _CategoryFilter.automation,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            icon: '📚',
            label: 'XP Pekiştirici',
            filter: _CategoryFilter.xpBoost,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            icon: '⭐',
            label: 'Özel',
            filter: _CategoryFilter.special,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String icon,
    required String label,
    required _CategoryFilter filter,
  }) {
    final bool isActive = _selectedCategory == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = filter;
        });
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? null
              : Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Titillium Web',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DROPDOWN SATIRI
  Widget _buildFilterDropdownRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown<_RarityFilter>(
            label: 'Nadirlik',
            value: _selectedRarity,
            items: const {
              _RarityFilter.all: 'Tümü',
              _RarityFilter.common: 'Yaygın',
              _RarityFilter.rare: 'Nadir',
              _RarityFilter.epic: 'Epik',
              _RarityFilter.legendary: 'Efsanevi',
              _RarityFilter.mythic: 'Mitik',
            },
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedRarity = val;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown<_SortOption>(
            label: 'Sırala',
            value: _selectedSort,
            items: const {
              _SortOption.defaultOption: 'Varsayılan',
              _SortOption.priceAsc: 'Ucuz → Pahalı',
              _SortOption.priceDesc: 'Pahalı → Ucuz',
              _SortOption.rarity: 'Nadirlik',
            },
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedSort = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF7C3AED),
          ),
          style: const TextStyle(
            fontFamily: 'Titillium Web',
            fontSize: 13,
            color: Color(0xFF374151),
          ),
          onChanged: onChanged,
          items: items.entries
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e.key,
                  child: Text(e.value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.search_rounded,
            size: 40,
            color: Colors.white54,
          ),
          SizedBox(height: 10),
          Text(
            'Eşya Bulunamadı',
            style: TextStyle(
              fontFamily: 'Titillium Web',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Farklı filtreler deneyin',
            style: TextStyle(
              fontFamily: 'Titillium Web',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  List<Item> _applyFiltersAndSorting(List<Item> items) {
    var result = items.where((item) {
      // Kategori filtresi
      if (!_matchesCategory(item)) return false;

      // Nadirlik filtresi
      if (!_matchesRarity(item)) return false;

      return true;
    }).toList();

    // Sıralama
    switch (_selectedSort) {
      case _SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _SortOption.rarity:
        result.sort(
          (a, b) => _rarityOrder(a.rarity).compareTo(_rarityOrder(b.rarity)),
        );
        break;
      case _SortOption.defaultOption:
        // Varsayılan: orijinal sıralamayı koru
        break;
    }

    return result;
  }

  bool _matchesCategory(Item item) {
    switch (_selectedCategory) {
      case _CategoryFilter.all:
        return true;
      case _CategoryFilter.boost:
        return item.category == ItemCategory.boost;
      case _CategoryFilter.automation:
        return item.category == ItemCategory.automation;
      case _CategoryFilter.xpBoost:
        return item.category == ItemCategory.xpBoost;
      case _CategoryFilter.special:
        return item.category == ItemCategory.special;
    }
  }

  bool _matchesRarity(Item item) {
    switch (_selectedRarity) {
      case _RarityFilter.all:
        return true;
      case _RarityFilter.common:
        return item.rarity == ItemRarity.common;
      case _RarityFilter.rare:
        return item.rarity == ItemRarity.rare;
      case _RarityFilter.epic:
        return item.rarity == ItemRarity.epic;
      case _RarityFilter.legendary:
        return item.rarity == ItemRarity.legendary;
      case _RarityFilter.mythic:
        return false; // Şimdilik mitik eşya yok
    }
  }

  int _rarityOrder(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return 0;
      case ItemRarity.rare:
        return 1;
      case ItemRarity.epic:
        return 2;
      case ItemRarity.legendary:
        return 3;
      case ItemRarity.mythic:
        return 4;
    }
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final double price;
  final bool canBuy;
  final VoidCallback onBuy;

  const _ItemCard({
    required this.item,
    required this.price,
    required this.canBuy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = '\$${price.toStringAsFixed(0)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: _rarityGradient(item.rarity),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _rarityBorderColor(item.rarity),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Titillium Web',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _rarityBorderColor(item.rarity).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.rarity.name.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Titillium Web',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _rarityBorderColor(item.rarity),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Titillium Web',
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.effect,
              style: const TextStyle(
                fontFamily: 'Titillium Web',
                fontSize: 12,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1.3,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        size: 16,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        priceText,
                        style: const TextStyle(
                          fontFamily: 'Titillium Web',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: canBuy ? onBuy : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: canBuy ? 4 : 0,
                      backgroundColor: canBuy
                          ? null
                          : Colors.grey.shade500, // override when disabled
                    ).copyWith(
                      backgroundColor: canBuy
                          ? MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                return const Color(0xFF10B981);
                              },
                            )
                          : MaterialStateProperty.all(Colors.grey.shade500),
                    ),
                    child: const Text(
                      'Satın Al',
                      style: TextStyle(
                        fontFamily: 'Titillium Web',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildProgressBar(item),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Item item) {
    final progress =
        item.maxStack == 0 ? 0.0 : (item.owned / item.maxStack).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _rarityBorderColor(item.rarity),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.owned}/${item.maxStack}',
          style: const TextStyle(
            fontFamily: 'Titillium Web',
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _InventoryChip extends StatelessWidget {
  final Item item;

  const _InventoryChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'Titillium Web',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${item.owned}x',
                style: const TextStyle(
                  fontFamily: 'Titillium Web',
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _rarityColor(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return const Color(0xFF6B7280);
    case ItemRarity.rare:
      return const Color(0xFF3B82F6);
    case ItemRarity.epic:
      return const Color(0xFF9333EA);
    case ItemRarity.legendary:
      return const Color(0xFFF59E0B);
    case ItemRarity.mythic:
      return const Color(0xFFDC2626);
  }
}

LinearGradient _rarityGradient(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return const LinearGradient(
        colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case ItemRarity.rare:
      return const LinearGradient(
        colors: [Color(0xFFDCEEFF), Color(0xFFBAE6FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case ItemRarity.epic:
      return const LinearGradient(
        colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case ItemRarity.legendary:
      return const LinearGradient(
        colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case ItemRarity.mythic:
      return const LinearGradient(
        colors: [Color(0xFFFEE2E2), Color(0xFFFECDD3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

Color _rarityBorderColor(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return const Color(0xFF6B7280);
    case ItemRarity.rare:
      return const Color(0xFF3B82F6);
    case ItemRarity.epic:
      return const Color(0xFF9333EA);
    case ItemRarity.legendary:
      return const Color(0xFFF59E0B);
    case ItemRarity.mythic:
      return const Color(0xFFDC2626);
  }
}