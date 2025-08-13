// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class GoldColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [GoldColors.card, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _TotalCard(cash: user.cashKRW, equity: user.totalEquityKRW),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: _ActionButton(label: '거래', icon: Icons.swap_vert, route: '/trade')),
              SizedBox(width: 12),
              Expanded(child: _ActionButton(label: '포트폴리오', icon: Icons.pie_chart, route: '/portfolio')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _ActionButton(label: '상점', icon: Icons.store, route: '/shop')),
              SizedBox(width: 12),
              Expanded(child: _ActionButton(label: '설정', icon: Icons.settings, route: '/settings')),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('프리미엄 (광고 제거)'), 
              subtitle: Text(user.premiumNoAds ? '활성화됨' : '미구매'),
              trailing: Icon(user.premiumNoAds ? Icons.check_circle : Icons.workspace_premium,
                  color: GoldColors.gold),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('거래 수수료'), 
              subtitle: Text(user.zeroFee ? '0%' : '0.25% 기본'),
              trailing: Icon(user.zeroFee ? Icons.check_circle : Icons.percent, color: GoldColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double cash;
  final double equity;
  const _TotalCard({required this.cash, required this.equity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('총자산', style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 6),
            Text(krw(equity), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: GoldColors.gold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(label: '현금', value: krw(cash)),
                const SizedBox(width: 8),
                _StatChip(label: '보유종목', value: '${context.read<UserProvider>().holdingCount}개'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GoldColors.goldDark.withOpacity(0.4)),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Colors.white)),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  const _ActionButton({required this.label, required this.icon, required this.route});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
