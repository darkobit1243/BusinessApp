// Modern, genişletilmiş, animasyonlu, Google Play profile destekli ProfileTab

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/achievement.dart';
import 'achievements_tab.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  late AnimationController xpController;

  @override
  void initState() {
    super.initState();
    xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    xpController.dispose();
    super.dispose();
  }

  String formatNumber(double value) {
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final gp = Provider.of<GameProvider>(context);
    final isDark = gp.darkMode;

    // XP animasyonu
    xpController.forward(from: 0);
    final xpPercent =
        gp.requiredXP == 0 ? 0.0 : gp.currentXP / gp.requiredXP.toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(gp, isDark, xpPercent),
          const SizedBox(height: 26),
          _buildStatsGrid(gp, isDark),
          const SizedBox(height: 26),
          _buildAchievements(gp, isDark),
        ],
      ),
    );
  }

  // -------------------- PROFILE HEADER (YATAY GENİŞ, GOOGLE PLAY DESTEKLİ) --------------------
  Widget _buildProfileHeader(GameProvider gp, bool isDark, double xpPercent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profil fotoğrafı (Google Play Games destekli)
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: gp.googlePlayProfileUrl != null
                  ? DecorationImage(
                      image: NetworkImage(gp.googlePlayProfileUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: gp.googlePlayProfileUrl == null
                ? const Center(
                    child: Text(
                      '👤',
                      style: TextStyle(fontSize: 40),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gp.googlePlayName ?? 'Oyuncu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Seviye ${gp.currentLevel}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: xpPercent.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${gp.currentXP} / ${gp.requiredXP} XP',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // -------------------- STATS GRID --------------------
  Widget _buildStatsGrid(GameProvider gp, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.45,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _statCard(
          'Toplam Kazanç',
          '\$${formatNumber(gp.totalEarnings)}',
          Icons.attach_money_rounded,
          Colors.greenAccent.shade700,
          isDark,
        ),
        _statCard(
          'Toplam Tıklama',
          formatNumber(gp.totalClicks.toDouble()),
          Icons.touch_app_rounded,
          Colors.lightBlueAccent.shade700,
          isDark,
        ),
        _statCard(
          'Deneyim',
          '${gp.totalExperience} XP',
          Icons.auto_awesome_rounded,
          Colors.amber.shade700,
          isDark,
        ),
        _statCard(
          'Seviye',
          '${gp.currentLevel}',
          Icons.military_tech_rounded,
          Colors.purpleAccent.shade400,
          isDark,
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- ACHIEVEMENTS --------------------
  Widget _buildAchievements(GameProvider gp, bool isDark) {
    // Basit bir eşleme ile oyuncu durumuna göre başarımların progress'ini doldur
    final achievements = Achievement.getInitialAchievements();
    for (final a in achievements) {
      switch (a.category) {
        case 'money':
          // Toplam kazanç üzerinden dolar başarımları
          a.progress = gp.totalEarnings;
          break;
        case 'clicks':
          a.progress = gp.totalClicks.toDouble();
          break;
        case 'level':
          // Seviye / XP başarımları için mevcut seviye
          a.progress = gp.currentLevel.toDouble();
          break;
        default:
          // Diğer kategoriler şimdilik 0'da kalsın
          break;
      }
    }

    // Profil sekmesinde başarımlar sekmesini gömmek için sabit yükseklikte kullanıyoruz
    return SizedBox(
      height: 420,
      child: AchievementsTab(
        achievements: achievements,
        onClaimReward: (_) {
          // İleride GameProvider ödül mantığı buraya bağlanabilir
        },
      ),
    );
  }
}
