import 'package:flutter/material.dart';
import '../widgets/balance_card.dart';
import '../widgets/earnings_action.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          BalanceCard(),
          EarningsAction(),
        ],
      ),
    );
  }
}