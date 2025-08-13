// lib/services/market_service.dart
// 간단한 가격 헬퍼 (실시간 API 없이 동작하도록 안전 설계)
import 'dart:math';

class MarketService {
  static double mockPriceKRW(String symbol) {
    // 심볼 기반 의사 난수로 가격 생성 (디버그용)
    final seed = symbol.codeUnits.fold<int>(0, (s, c) => s + c);
    final rnd = Random(seed);
    final base = 10000 + rnd.nextInt(500000);
    return base.toDouble();
  }
}
