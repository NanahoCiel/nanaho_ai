// lib/services/iap_service.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class IapService {
  static Future<void> buyPremiumNoAds(BuildContext context) async {
    final user = context.read<UserProvider>();
    user.grantPremiumNoAds();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프리미엄(광고 제거) 활성화됨')),
    );
  }

  static Future<void> buyZeroFee(BuildContext context) async {
    final user = context.read<UserProvider>();
    user.grantZeroFee();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('거래 수수료 0% 활성화됨')),
    );
  }

  static Future<void> buyCapital(BuildContext context, double amount) async {
    final user = context.read<UserProvider>();
    user.addCapitalKRW(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${krw(amount)} 충전 완료')),
    );
  }
}
