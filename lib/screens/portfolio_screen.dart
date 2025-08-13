// lib/screens/portfolio_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('포트폴리오')),
      body: user.holdings.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: user.holdings.length,
              itemBuilder: (context, i) {
                final h = user.holdings[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: GoldColors.gold.withOpacity(0.15),
                      child: const Icon(Icons.trending_up, color: GoldColors.gold),
                    ),
                    title: Text(h.symbol),
                    subtitle: Text('평단가: ${krw(h.avgPriceKRW)}  ·  수량: ${formatNumber(h.quantity, decimals: 4)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(krw(h.quantity * h.avgPriceKRW),
                            style: const TextStyle(color: GoldColors.gold, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(h.type == AssetType.stock ? '주식' : '코인',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 56, color: GoldColors.gold),
            const SizedBox(height: 12),
            const Text('아직 보유 자산이 없어요', style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/trade'),
              icon: const Icon(Icons.swap_vert),
              label: const Text('거래하러 가기'),
            )
          ],
        ),
      ),
    );
  }
}

String formatNumber(double value, {int decimals = 2}) {
  return value.toStringAsFixed(decimals);
}

