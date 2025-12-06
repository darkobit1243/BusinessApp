import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class EarningsAction extends StatefulWidget {
  const EarningsAction({Key? key}) : super(key: key);

  @override
  State<EarningsAction> createState() => _EarningsActionState();
}

class _EarningsActionState extends State<EarningsAction> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 32),

        // Click Value Display (Tıklanabilir ve yeşil renk)
        if (!gameProvider.isMaxClickLevel)
          GestureDetector(
            onTap: () {
              if (gameProvider.balance >= gameProvider.nextLevelCost) {
                gameProvider.upgradeClickValue();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gameProvider.balance >= gameProvider.nextLevelCost
                    ? const LinearGradient(
                        colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFFBEB), Color(0xFFFED7AA)],
                      ),
                border: Border.all(
                  color: gameProvider.balance >= gameProvider.nextLevelCost
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFBBF24),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gameProvider.balance >= gameProvider.nextLevelCost
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                        'Tıklama Değeri',
                        style: TextStyle(
                          color: gameProvider.balance >= gameProvider.nextLevelCost
                              ? const Color(0xFF059669)
                              : const Color(0xFFEA580C),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${gameProvider.currentClickValue}',
                        style: TextStyle(
                          color: gameProvider.balance >= gameProvider.nextLevelCost
                              ? const Color(0xFF047857)
                              : const Color(0xFFC2410C),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sonraki Seviye',
                        style: TextStyle(
                          color: gameProvider.balance >= gameProvider.nextLevelCost
                              ? const Color(0xFF059669)
                              : const Color(0xFFEA580C),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${gameProvider.nextLevelCost.toStringAsFixed(0)} kaldı',
                        style: TextStyle(
                          color: gameProvider.balance >= gameProvider.nextLevelCost
                              ? const Color(0xFF047857)
                              : const Color(0xFFC2410C),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sonra: \$${gameProvider.nextClickValue}/tık',
                        style: TextStyle(
                          color: gameProvider.balance >= gameProvider.nextLevelCost
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF97316),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Click Button
        GestureDetector(
          onTap: () {
            gameProvider.handleClick();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFCA5A5).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Hand Icon
                Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  '+\$${gameProvider.currentClickValue} Kazanmak İçin Tıkla!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Her tıklama \$${gameProvider.currentClickValue} kazandırır',
                  style: const TextStyle(
                    color: Color(0xFFFECDD3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Stats
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${gameProvider.totalClicks}',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bugün',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${gameProvider.totalClicks}',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bu Hafta',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${((gameProvider.totalClicks / 100).floor() / 10).toStringAsFixed(1)}K',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toplam',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}