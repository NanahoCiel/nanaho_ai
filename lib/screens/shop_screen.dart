// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/iap_service.dart';
import '../services/ad_service.dart';
import '../theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final options = [
      {'price': 1000, 'reward': 10000000},
      {'price': 2000, 'reward': 20000000},
      {'price': 5000, 'reward': 50000000},
      {'price': 10000, 'reward': 100000000},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('상점')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: const Text('광고 시청'),
              subtitle: const Text('시청 시 200,000원 지급'),
              trailing: ElevatedButton(
                onPressed: () => AdService.showRewarded(context, onReward: () {
                  context.read<UserProvider>().addCapitalKRW(200000);
                }),
                child: const Text('보기'),
              ),
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('자본 충전', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                for (final o in options)
                  ListTile(
                    title: Text('${krw((o['price'] as int).toDouble())} → ${krw((o['reward'] as int).toDouble())}'),
                    trailing: ElevatedButton(
                      onPressed: () => IapService.buyCapital(context, (o['reward'] as int).toDouble()),
                      child: const Text('구매'),
                    ),
                  ),
              ],
            ),
          ),
          _PremiumTile(
            title: '광고 제거',
            active: user.premiumNoAds,
            onBuy: () => IapService.buyPremiumNoAds(context),
          ),
        ],
      ),
    );
  }
}

class _PremiumTile extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onBuy;
  const _PremiumTile({required this.title, required this.active, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(active ? '활성화됨' : '미구매'),
        trailing: active
            ? const Icon(Icons.check_circle, color: GoldColors.gold)
            : ElevatedButton(
                onPressed: onBuy,
                child: const Text('구매'),
              ),
      ),
    );
  }
}

