// lib/services/auth_service.dart
// 선택 사항: Firebase Auth 연결 (지금은 더미)
import 'package:flutter/material.dart';

class AuthService {
  static Future<void> signInAnonymously(BuildContext context) async {
    // Firebase Auth 붙일 경우 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게스트 로그인 완료')),
    );
  }
}
