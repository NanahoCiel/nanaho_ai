// lib/services/error_handler.dart
import 'package:flutter/material.dart';

void showFriendlyError(BuildContext context, Object error) {
  final msg = _humanize(error.toString());
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

String _humanize(String raw) {
  if (raw.contains('잔액 부족')) return '잔액이 부족합니다. 수량을 줄이거나 자본을 충전해주세요.';
  if (raw.contains('보유하지 않은 종목')) return '보유하지 않은 종목입니다.';
  if (raw.contains('보유 수량 부족')) return '보유 수량이 부족합니다.';
  if (raw.contains('0보다 커야')) return '입력값을 다시 확인해주세요.';
  return raw.replaceAll('Exception: ', '');
}
