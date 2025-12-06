import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;

  const NotificationPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  // Basit local bildirim modeli
  final List<_LocalNotification> _notifications = [
    _LocalNotification(
      icon: '🎉',
      title: 'Hoş geldiniz!',
      message: 'Kazanç oyununa başladınız',
      time: '1 saat önce',
    ),
    _LocalNotification(
      icon: '⭐',
      title: 'Seviye Atlama',
      message: 'Seviye 1 oldunuz!',
      time: '2 saat önce',
    ),
    _LocalNotification(
      icon: '💰',
      title: 'Pasif Gelir',
      message: 'İşletmeleriniz para kazandırıyor',
      time: '3 saat önce',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isDark = gameProvider.darkMode;

    return Drawer(
      child: Container(
        color: isDark ? Colors.grey[900] : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header + aksiyon butonları
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bildirimler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _markAllAsRead,
                                child: const Text(
                                  'Tümünü okundu yap',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _clearAll,
                                child: const Text(
                                  'Tümünü temizle',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Bildirimler listesi
              Expanded(
                child: _notifications.isEmpty
                    ? Center(
                        child: Text(
                          'Bildirim yok',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return _buildNotificationItem(
                            notification: n,
                            isDark: isDark,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  Widget _buildNotificationItem({
    required _LocalNotification notification,
    required bool isDark,
  }) {
    final bgColor = notification.isRead
        ? (isDark ? Colors.grey[850] : Colors.grey[100])
        : (isDark ? Colors.grey[800] : Colors.blue.shade50);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(notification.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalNotification {
  _LocalNotification({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  final String icon;
  final String title;
  final String message;
  final String time;
  bool isRead;
}