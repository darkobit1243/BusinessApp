import 'package:flutter/material.dart';

class InvestmentTab extends StatefulWidget {
  const InvestmentTab({super.key});

  @override
  State<InvestmentTab> createState() => _InvestmentTabState();
}

class _InvestmentTabState extends State<InvestmentTab> {
  // Hangi kategori seçili
  String selectedCategory = 'stocks'; // 'stocks', 'real-estate', 'crypto'

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yatırım Portföyü',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryTabs(),
          const SizedBox(height: 16),
          _buildInvestmentList(),
        ],
      ),
    );
  }

  // ============================================
  // 📊 KATEGORİ BUTONLARI (TIKLANAB İLİR!)
  // ============================================
  Widget _buildCategoryTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryButton(
            'Hisse Senetleri',
            'stocks',
            selectedCategory == 'stocks',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryButton(
            'Gayrimenkul',
            'real-estate',
            selectedCategory == 'real-estate',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryButton(
            'Kripto',
            'crypto',
            selectedCategory == 'crypto',
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String label, String category, bool isActive) {
    return GestureDetector(
      // 🎯 TIKLANMA OLAYINI EKLE
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ============================================
  // 📋 YATIRIM LİSTESİ (KATEGORİYE GÖRE)
  // ============================================
  Widget _buildInvestmentList() {
    List<Map<String, String>> investments = [];

    // Seçili kategoriye göre veri getir
    switch (selectedCategory) {
      case 'stocks':
        investments = [
          {'name': 'Apple Inc.', 'symbol': 'AAPL', 'price': '\$175.43', 'change': '+2.4%', 'icon': '🍎'},
          {'name': 'Tesla Inc.', 'symbol': 'TSLA', 'price': '\$242.84', 'change': '+5.2%', 'icon': '🚗'},
          {'name': 'Microsoft', 'symbol': 'MSFT', 'price': '\$378.91', 'change': '+1.8%', 'icon': '💻'},
          {'name': 'Amazon', 'symbol': 'AMZN', 'price': '\$146.57', 'change': '+3.1%', 'icon': '📦'},
          {'name': 'Google', 'symbol': 'GOOGL', 'price': '\$139.93', 'change': '+1.5%', 'icon': '🔍'},
        ];
        break;
      case 'real-estate':
        investments = [
          {'name': 'İstanbul Daire', 'symbol': 'BESIKTAS', 'price': '\$250,000', 'change': '+8.5%', 'icon': '🏢'},
          {'name': 'Antalya Villa', 'symbol': 'LARA', 'price': '\$450,000', 'change': '+12.3%', 'icon': '🏡'},
          {'name': 'İzmir Rezidans', 'symbol': 'KONAK', 'price': '\$180,000', 'change': '+6.7%', 'icon': '🏘️'},
          {'name': 'Bodrum Arsa', 'symbol': 'YALIKAVAK', 'price': '\$320,000', 'change': '+15.2%', 'icon': '🌴'},
          {'name': 'Ankara Ofis', 'symbol': 'CANKAYA', 'price': '\$420,000', 'change': '+9.1%', 'icon': '🏬'},
        ];
        break;
      case 'crypto':
        investments = [
          {'name': 'Bitcoin', 'symbol': 'BTC', 'price': '\$43,250', 'change': '+3.8%', 'icon': '₿'},
          {'name': 'Ethereum', 'symbol': 'ETH', 'price': '\$2,340', 'change': '+5.2%', 'icon': '⟠'},
          {'name': 'Binance Coin', 'symbol': 'BNB', 'price': '\$312', 'change': '+2.4%', 'icon': '💰'},
          {'name': 'Cardano', 'symbol': 'ADA', 'price': '\$0.58', 'change': '+4.1%', 'icon': '🔷'},
          {'name': 'Solana', 'symbol': 'SOL', 'price': '\$98', 'change': '+7.6%', 'icon': '◎'},
        ];
        break;
    }

    // Liste boşsa
    if (investments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Bu kategoride henüz yatırım yok',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: investments.map((investment) {
        // + veya - değişim rengi
        final isPositive = investment['change']!.startsWith('+');
        final changeColor = isPositive ? Colors.green : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Koyu kart rengi (kazançlar/eşyalar ile uyumlu)
            color: const Color(0xFF2D3436),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // İkon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    investment['icon']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // İsim ve sembol
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investment['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      investment['symbol']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Fiyat ve değişim
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    investment['price']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    investment['change']!,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}