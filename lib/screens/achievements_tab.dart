// flutter/screens/achievements_tab.dart

import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementsTab extends StatefulWidget {
  final List<Achievement> achievements;
  final Function(Achievement) onClaimReward;

  const AchievementsTab({
    Key? key,
    required this.achievements,
    required this.onClaimReward,
  }) : super(key: key);

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  String selectedCategory = 'all';
  String filterType = 'all'; // all, completed, uncompleted

  Map<String, int> get categoryCount {
    return {
      'all': widget.achievements.length,
      'money': widget.achievements.where((a) => a.category == 'money').length,
      'clicks': widget.achievements.where((a) => a.category == 'clicks').length,
      'business':
          widget.achievements.where((a) => a.category == 'business').length,
      'level': widget.achievements.where((a) => a.category == 'level').length,
      'items': widget.achievements.where((a) => a.category == 'items').length,
      'category':
          widget.achievements.where((a) => a.category == 'category').length,
      'speed': widget.achievements.where((a) => a.category == 'speed').length,
      'gameplay':
          widget.achievements.where((a) => a.category == 'gameplay').length,
      'secret':
          widget.achievements.where((a) => a.category == 'secret').length,
    };
  }

  int get completedCount =>
      widget.achievements.where((a) => a.isCompleted).length;
  int get canClaimCount =>
      widget.achievements.where((a) => a.canClaim).length;

  List<Achievement> get filteredAchievements {
    var filtered = widget.achievements.where((achievement) {
      final categoryMatch =
          selectedCategory == 'all' || achievement.category == selectedCategory;

      if (!categoryMatch) return false;

      switch (filterType) {
        case 'completed':
          return achievement.isCompleted;
        case 'uncompleted':
          return !achievement.isCompleted;
        default:
          return true;
      }
    }).toList();

    // Önce tamamlanabilir olanlar
    filtered.sort((a, b) {
      if (a.canClaim && !b.canClaim) return -1;
      if (!a.canClaim && b.canClaim) return 1;
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return b.progressPercentage.compareTo(a.progressPercentage);
    });

    return filtered;
  }

  void handleClaimReward(Achievement achievement) {
    if (achievement.canClaim) {
      widget.onClaimReward(achievement);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${achievement.icon} ${achievement.name} tamamlandı!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredAchievements;
    final totalProgress =
        (completedCount / widget.achievements.length * 100).toInt();

    return Column(
      children: [
        // HEADER - İstatistikler
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emoji_events,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Başarımlar',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedCount / ${widget.achievements.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '%$totalProgress',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      if (canClaimCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$canClaimCount Ödül!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completedCount / widget.achievements.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        // FİLTRE BUTONLARI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterButton('Tümü', 'all'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton('Tamamlanan', 'completed'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton('Devam Eden', 'uncompleted'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // KATEGORİ CHIPS
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildCategoryChip('all', 'Tümü', '🏆', categoryCount['all']!),
              _buildCategoryChip(
                  'money', 'Para', '💰', categoryCount['money']!),
              _buildCategoryChip(
                  'clicks', 'Tıklama', '👆', categoryCount['clicks']!),
              _buildCategoryChip('business', 'İşletme', '🏢',
                  categoryCount['business']!),
              _buildCategoryChip(
                  'level', 'Seviye', '⭐', categoryCount['level']!),
              _buildCategoryChip(
                  'items', 'Eşya', '🎒', categoryCount['items']!),
              _buildCategoryChip('category', 'Kategori', '⚡',
                  categoryCount['category']!),
              _buildCategoryChip('speed', 'Hız', '⏱️', categoryCount['speed']!),
              _buildCategoryChip(
                  'gameplay', 'Oyun', '🎮', categoryCount['gameplay']!),
              _buildCategoryChip(
                  'secret', 'Gizli', '🎁', categoryCount['secret']!),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // SONUÇ SAYACI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                '${filtered.length} başarım',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              if (selectedCategory != 'all' || filterType != 'all')
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = 'all';
                      filterType = 'all';
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.clear, size: 12),
                      SizedBox(width: 4),
                      Text('Temizle',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // BAŞARIM LİSTESİ
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = filterType == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filterType = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFFF59E0B) : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : const Color(0xFF6B7280),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCategoryChip(
      String value, String label, String icon, int count) {
    final isSelected = selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            selectedCategory = value;
          });
        },
        selectedColor: const Color(0xFFF59E0B),
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        side: BorderSide(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE5E7EB)),
        labelStyle: TextStyle(
            color:
                isSelected ? Colors.white : const Color(0xFF374151)),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined,
                size: 32, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 12),
          const Text('Başarım Bulunamadı',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Farklı filtreler deneyin',
              style:
                  TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  // ... PART 2'DEN DEVAM

  Widget _buildAchievementCard(Achievement achievement) {
    final gradient = Achievement.getRarityGradient(achievement.rarity);
    final rarityColor = Achievement.getRarityColor(achievement.rarity);
    final isLocked = achievement.isSecret && achievement.progress == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: rarityColor, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Tamamlandı rozeti
          if (achievement.isCompleted)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isLocked ? '🔒' : achievement.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isLocked ? '???' : achievement.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rarityColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              achievement.rarity.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isLocked
                                ? 'Gizli başarım - Keşfedilmedi'
                                : achievement.description,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isLocked) ...[
                            const SizedBox(height: 8),
                            // Progress text
                            Row(
                              children: [
                                Text(
                                  '${achievement.progress.toInt()} / ${achievement.target.toInt()}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: rarityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${achievement.progressPercentage.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: rarityColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // FOOTER
              if (!isLocked)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: achievement.progressPercentage / 100,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(rarityColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Ödül ve Buton
                      Row(
                        children: [
                          // Ödüller
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (achievement.reward['money'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFEF3C7),
                                          Color(0xFFFDE68A)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFF59E0B)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.monetization_on,
                                            size: 12,
                                            color: Color(0xFFD97706)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '\$${achievement.reward['money']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF92400E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (achievement.reward['xp'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFDCEEFF),
                                          Color(0xFFBAE6FF)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF3B82F6)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            size: 12,
                                            color: Color(0xFF2563EB)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${achievement.reward['xp']} XP',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Claim Button
                          if (!achievement.isCompleted)
                            ElevatedButton(
                              onPressed: achievement.canClaim
                                  ? () => handleClaimReward(achievement)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: achievement.canClaim
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFE5E7EB),
                                foregroundColor: achievement.canClaim
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: achievement.canClaim ? 3 : 0,
                                minimumSize: Size.zero,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    achievement.canClaim
                                        ? Icons.card_giftcard
                                        : Icons.lock_clock,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Al',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          if (achievement.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tamamlandı',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
}


