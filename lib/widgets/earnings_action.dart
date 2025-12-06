import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class EarningsAction extends StatefulWidget {
  const EarningsAction({Key? key}) : super(key: key);

  @override
  State<EarningsAction> createState() => _EarningsActionState();
}

class _EarningsActionState extends State<EarningsAction>
    with TickerProviderStateMixin {
  final List<_FloatingDollar> _floatingDollars = [];

  void _addFloatingDollar(Offset position) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final effect = _FloatingDollar(
      position: position,
      controller: controller,
    );

    setState(() {
      _floatingDollars.add(effect);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        setState(() {
          _floatingDollars.remove(effect);
        });
      }
    });

    controller.forward();
  }

  List<Widget> _buildFloatingDollars() {
    return _floatingDollars.map((effect) {
      return AnimatedBuilder(
        animation: effect.controller,
        builder: (context, child) {
          final t = effect.controller.value; // 0 → 1
          final dy = effect.position.dy - 24 * t; // hafif yukarı süzülme
          final dx = effect.position.dx;

          return Positioned(
            left: dx - 8,
            top: dy - 8,
            child: Opacity(
              opacity: 1.0 - t, // yavaşça transparanlaş
              child: Transform.scale(
                scale: 0.9 + 0.1 * (1 - t),
                child: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final canUpgrade = !gameProvider.isMaxClickLevel &&
        gameProvider.balance >= gameProvider.nextLevelCost;
    final double xpPercent = gameProvider.requiredXP == 0
        ? 0.0
        : gameProvider.currentXP / gameProvider.requiredXP.toDouble();

    return Column(
      children: [
        const SizedBox(height: 32),

        // Click Value + XP widget yan yana
        if (!gameProvider.isMaxClickLevel)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOL: Click Value kartı (içerik aynı, sadece Expanded ile sola oturtuldu)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (canUpgrade) {
                      gameProvider.upgradeClickValue();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: canUpgrade
                          ? const Color(0xFF16A34A) // YEŞİL (yeterli para)
                          : const Color(0xFF808080), // Varsayılan GRİ
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: canUpgrade
                              ? Colors.green.withOpacity(0.35)
                              : Colors.black.withOpacity(0.15),
                          blurRadius: canUpgrade ? 14 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // LEFT
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tıklama Değeri',
                              style: TextStyle(
                                color:
                                    canUpgrade ? Colors.white : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${gameProvider.currentClickValue}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        // RIGHT (sadece maliyet ve sonraki seviye değeri)
                        if (!gameProvider.isMaxClickLevel)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${gameProvider.nextLevelCost.toStringAsFixed(0)} kaldı',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sonra: \$${gameProvider.nextClickValue}/tık',
                                style: const TextStyle(
                                  color: Color(0xFFFFE0B2),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // SAĞ: Profildeki XP widget'ının kompakt hali
              Expanded(
                child: _buildCompactXpWidget(
                  context,
                  currentLevel: gameProvider.currentLevel,
                  currentXP: gameProvider.currentXP,
                  requiredXP: gameProvider.requiredXP,
                  xpPercent: xpPercent,
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // CLICK BUTTON - MODERN PREMIUM TASARIM + yeşil dolar animasyonları
        GestureDetector(
          onTap: () => gameProvider.handleClick(),
          onTapDown: (details) {
            // Dokunulan noktadan küçük yeşil dolar ikonu üret
            _addFloatingDollar(details.localPosition);
          },
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Butonun kendisi
                Container(
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

                // Yüzen yeşil dolar ikonları
                ..._buildFloatingDollars(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

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

  // ✔️ Profildeki XP widget'ının, Earnings ekranına uygun kompakt versiyonu
  Widget _buildCompactXpWidget(
    BuildContext context, {
    required int currentLevel,
    required int currentXP,
    required int requiredXP,
    required double xpPercent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Arka plan rengi Click Value widget'ıyla aynı gri ton
        color: const Color(0xFF808080),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Seviye $currentLevel',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: xpPercent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white24,
              // XP barı yeşil
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currentXP / $requiredXP XP',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ✔️ Modern Stat Card Component
  Widget _buildStatCard({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF808080), // 🔥 YENİ GRİ
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDollar {
  final Offset position;
  final AnimationController controller;

  _FloatingDollar({
    required this.position,
    required this.controller,
  });
}
