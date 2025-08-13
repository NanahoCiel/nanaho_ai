// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/reset_service.dart';

class GoldColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
}


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('다크 모드'),
              subtitle: const Text('권장: 다크 + 메탈릭 골드'),
              value: AdaptiveTheme.of(context).mode.isDark,
              onChanged: (v) => v ? AdaptiveTheme.of(context).setDark() : AdaptiveTheme.of(context).setLight(),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('디버그 정보 출력'),
              subtitle: const Text('콘솔에 유저 상태 로그'),
              trailing: const Icon(Icons.bug_report),
              onTap: () => user.printDebugInfo(),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('앱 초기화'),
              subtitle: const Text('모든 데이터 초기화 (주의)'),
              trailing: const Icon(Icons.delete_forever),
              onTap: () => ResetService.confirmAndReset(context),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('v1.0 • Made for Ciel', style: TextStyle(color: Colors.white38))),
        ],
      ),
    );
  }
}
