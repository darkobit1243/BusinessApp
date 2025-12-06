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
    final canUpgrade = !gameProvider.isMaxClickLevel &&
        gameProvider.balance >= gameProvider.nextLevelCost;

    return Column(
      children: [
        const SizedBox(height: 32),

        // Click Value Display - MODERN TASARIM + YEŞİİL ANİMASYON
        if (!gameProvider.isMaxClickLevel)
          GestureDetector(
            onTap: () {
              if (canUpgrade) {
                gameProvider.upgradeClickValue();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: canUpgrade
                    ? const Color(0xFF16A34A) // YEŞİL (yeterli para)
                    : const Color(0xFF808080), // Varsayılan GRİ
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: canUpgrade
                        ? Colors.green.withOpacity(0.35)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: canUpgrade ? 18 : 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tıklama Değeri',
                        style: TextStyle(
                          color: canUpgrade ? Colors.white : Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${gameProvider.currentClickValue}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  // RIGHT
                  if (!gameProvider.isMaxClickLevel)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Sonraki Seviye',
                          style: TextStyle(
                            color: canUpgrade ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${gameProvider.nextLevelCost.toStringAsFixed(0)} kaldı',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sonra: \$${gameProvider.nextClickValue}/tık',
                          style: const TextStyle(
                            color: Color(0xFFFFE0B2),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),

        // CLICK BUTTON - MODERN PREMIUM TASARIM
        GestureDetector(
          onTap: () => gameProvider.handleClick(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 34),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF5F6D),
                  Color(0xFFFF1E41),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.35),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 90,
                ),
                const SizedBox(height: 16),
                Text(
                  '+\$${gameProvider.currentClickValue} Kazanmak İçin Tıkla!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Her tıklama \$${gameProvider.currentClickValue} kazandırır',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // STATS - MODERN TASARIM
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '${gameProvider.totalClicks}',
                label: 'Bugün',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '${gameProvider.totalClicks}',
                label: 'Bu Hafta',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value:
                '${((gameProvider.totalClicks / 100).floor() / 10).toStringAsFixed(1)}K',
                label: 'Toplam',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✔️ Modern Stat Card Component
  Widget _buildStatCard({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF808080), // 🔥 YENİ GRİ
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
