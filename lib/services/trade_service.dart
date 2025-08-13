// lib/services/trade_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import './ad_service.dart';
import './error_handler.dart';

class TradeService {
  static const double usdKrw = UserProvider.usdKrw;

  /// 심볼에 따라 가격을 KRW로 환산
  static double toKrw({
    required String symbol,
    required double price,
  }) {
    final s = symbol.toUpperCase();
    final isKrwEquity = s.endsWith('.KS') || s.endsWith('.KQ') || s.endsWith('.KR');
    final isKrwPair = s.contains('-KRW'); // 코인 KRW 페어
    if (isKrwEquity || isKrwPair) return price;
    return price * usdKrw; // 그 외는 USD 기준으로 가정
  }

  /// 매수/매도 실행
  static Future<void> executeTrade({
    required BuildContext context,
    required String symbol,
    required AssetType type,
    required double price,
    required double quantity,
    required bool isBuy,
  }) async {
    final user = context.read<UserProvider>();
    final priceKRW = toKrw(symbol: symbol, price: price);

    try {
      user.applyTrade(
        symbol: symbol,
        type: type,
        priceKRW: priceKRW,
        quantity: quantity,
        isBuy: isBuy,
      );

      if (!user.premiumNoAds && !kIsWeb) {
        await AdService.showInterstitial();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isBuy ? "매수" : "매도"} 완료: $symbol x ${quantity.toStringAsFixed(4)}')),
      );
    } catch (e) {
      showFriendlyError(context, e);
    }
  }
}

