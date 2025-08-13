// lib/services/reset_service.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ResetService {
  static Future<void> confirmAndReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('초기화'),
        content: const Text('모든 데이터를 초기화할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('초기화')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<UserProvider>().resetAll();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초기화 완료')),
      );
    }
  }
}
