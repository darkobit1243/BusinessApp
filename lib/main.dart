import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/earnings_tab.dart';
import 'screens/investment_tab.dart';
import 'screens/business_tab.dart';
import 'screens/items_tab.dart';
import 'screens/profile_tab.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/google_connect_modal.dart';
import 'widgets/notification_panel.dart';
,,,,,,
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return MaterialApp(
          title: 'Kazanç Oyunu',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFAF9F6),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          ),
          themeMode: gameProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Başlangıç: Kazançlar sekmesi
  bool _showGoogleModal = false;

  final List<String> _tabTitles = [
    'Yatırımlarım',
    'İşletmelerim',
    'Kazançlarım',
    'Envanter',
    'Profilim',
  ];

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isDark = gameProvider.darkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAF9F6),

      // === APP BAR ===
      appBar: AppBar(
        title: Text(
          _tabTitles[_currentIndex],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.red[400] : Colors.red[700],
          ),
        ),
        actions: [
          // Bildirim ikonu
          Stack(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
              // Bildirim sayısı badge
              if (gameProvider.notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${gameProvider.notificationCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),

          // Profil ikonu
          GestureDetector(
            onTap: () {
              setState(() {
                _showGoogleModal = true;
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '👤',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // === BİLDİRİM PANELİ (Sağdan açılan drawer) ===
      endDrawer: NotificationPanel(
        onClose: () {
          Navigator.of(context).pop();
        },
      ),

      // === ANA İÇERİK ===
      body: SafeArea(
        child: Stack(
          children: [
            _buildCurrentTab(),

            // Google Connect Modal
            if (_showGoogleModal)
              GoogleConnectModal(
                onClose: () {
                  setState(() {
                    _showGoogleModal = false;
                  });
                },
              ),
          ],
        ),
      ),

      // === ALT NAVİGASYON ===
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // === SEKME SEÇİCİ ===
  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return const InvestmentTab();
      case 1:
        return const BusinessTab();
      case 2:
        return const EarningsTab();
      case 3:
        return const ItemsTab();
      case 4:
        return const ProfileTab();
      default:
        return const EarningsTab();
    }
  }
}