// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/iap_service.dart';

class GoldColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
}


class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('상점')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _PremiumTile(
            title: '광고 제거 (Premium)',
            active: user.premiumNoAds,
            onBuy: () => IapService.buyPremiumNoAds(context),
          ),
          _PremiumTile(
            title: '거래 수수료 0%',
            active: user.zeroFee,
            onBuy: () => IapService.buyZeroFee(context),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('자본 추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final amt in [100000, 500000, 1000000, 5000000])
                        OutlinedButton(
                          onPressed: () => IapService.buyCapital(context, amt.toDouble()),
                          child: Text(krw(amt.toDouble())),
                        ),
                    ],
                  )
                ],
              ),
            ),
          )
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
