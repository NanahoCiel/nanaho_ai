// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

// === 자산 타입 정의 ===
enum AssetType { stock, coin }

// === 보유 자산 모델 ===
class Holding {
  final String symbol;
  final AssetType type;
  final double quantity;
  final double avgPriceKRW;
  final DateTime purchaseDate;

  Holding({
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.avgPriceKRW,
    required this.purchaseDate,
  });

  // 직렬화/역직렬화
  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'type': type.toString(),
    'quantity': quantity,
    'avgPriceKRW': avgPriceKRW,
    'purchaseDate': purchaseDate.millisecondsSinceEpoch,
  };

  factory Holding.fromMap(Map<String, dynamic> map) => Holding(
    symbol: map['symbol'],
    type: AssetType.values.firstWhere((e) => e.toString() == map['type']),
    quantity: map['quantity'],
    avgPriceKRW: map['avgPriceKRW'],
    purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
  );

  // 현재 평가금액 계산
  double calculateValue(double currentPriceKRW) => quantity * currentPriceKRW;
  
  // 손익 계산
  double calculateProfit(double currentPriceKRW) => 
    calculateValue(currentPriceKRW) - (quantity * avgPriceKRW);
  
  // 수익률 계산
  double calculateProfitRate(double currentPriceKRW) =>
    (calculateProfit(currentPriceKRW) / (quantity * avgPriceKRW)) * 100;
}

class UserProvider extends ChangeNotifier {
  static const double usdKrw = 1300.0; // USD/KRW 환율
  
  // === 유저 속성 ===
  bool premiumNoAds = false; // 광고 제거 여부
  bool zeroFee = false; // 거래 수수료 제거 여부
  double cashKRW = 10000000; // 보유 현금 (KRW) - 초기 1천만원
  List<Holding> holdings = []; // 보유 자산 리스트

  // === 계산된 속성 ===
  double get totalEquityKRW => cashKRW + holdings.fold<double>(
    0, (sum, holding) => sum + (holding.quantity * holding.avgPriceKRW)
  );

  // 총 투자원금
  double get totalInvestedKRW => holdings.fold<double>(
    0, (sum, holding) => sum + (holding.quantity * holding.avgPriceKRW)
  );

  // 보유 종목 개수
  int get holdingCount => holdings.length;

  // === 초기화 (main.dart에서 호출됨) ===
  Future<void> initUser() async {
    try {
      // 여기서 Firebase나 로컬 저장소에서 데이터 로드
      // 현재는 기본값 사용
      debugPrint('UserProvider 초기화 완료');
    } catch (e) {
      debugPrint('UserProvider 초기화 실패: $e');
      // 실패해도 기본값으로 계속 진행
    }
    notifyListeners();
  }

  // === 자본 관리 ===
  void addCapitalKRW(double amount) {
    if (amount <= 0) {
      throw ArgumentError('추가할 금액은 0보다 커야 합니다');
    }
    cashKRW += amount;
    notifyListeners();
  }

  // === 프리미엄 기능 부여 ===
  void grantPremiumNoAds() {
    premiumNoAds = true;
    notifyListeners();
  }

  void grantZeroFee() {
    zeroFee = true;
    notifyListeners();
  }

  // === 거래 실행 ===
  void applyTrade({
    required String symbol,
    required AssetType type,
    required double priceKRW,
    required double quantity,
    required bool isBuy,
  }) {
    if (quantity <= 0) {
      throw ArgumentError('거래 수량은 0보다 커야 합니다');
    }
    if (priceKRW <= 0) {
      throw ArgumentError('가격은 0보다 커야 합니다');
    }

    final totalKRW = priceKRW * quantity;
    final feeRate = zeroFee ? 0.0 : 0.0025; // 0.25% 수수료
    final fee = totalKRW * feeRate;

    if (isBuy) {
      _executeBuy(symbol, type, priceKRW, quantity, fee);
    } else {
      _executeSell(symbol, priceKRW, quantity, fee);
    }

    notifyListeners();
  }

  // === 매수 실행 ===
  void _executeBuy(String symbol, AssetType type, double priceKRW, double quantity, double fee) {
    final totalCost = (priceKRW * quantity) + fee;
    
    if (cashKRW < totalCost) {
      throw Exception('잔액 부족: ${krw(totalCost)} 필요, ${krw(cashKRW)} 보유');
    }

    cashKRW -= totalCost;
    _addToHoldings(symbol, type, quantity, priceKRW);
  }

  // === 매도 실행 ===
  void _executeSell(String symbol, double priceKRW, double quantity, double fee) {
    final holdingIndex = holdings.indexWhere((h) => h.symbol == symbol);
    
    if (holdingIndex == -1) {
      throw Exception('보유하지 않은 종목: $symbol');
    }

    final holding = holdings[holdingIndex];
    if (holding.quantity < quantity) {
      throw Exception('보유 수량 부족: ${holding.quantity} 보유, $quantity 매도 시도');
    }

    final totalRevenue = (priceKRW * quantity) - fee;
    cashKRW += totalRevenue;
    _removeFromHoldings(holdingIndex, quantity);
  }

  // === 포트폴리오에 추가 ===
  void _addToHoldings(String symbol, AssetType type, double quantity, double priceKRW) {
    final existingIndex = holdings.indexWhere((h) => h.symbol == symbol);
    
    if (existingIndex >= 0) {
      // 기존 보유 종목 - 평단가 재계산
      final existing = holdings[existingIndex];
      final totalQuantity = existing.quantity + quantity;
      final weightedAvgPrice = ((existing.avgPriceKRW * existing.quantity) + 
                               (priceKRW * quantity)) / totalQuantity;
      
      holdings[existingIndex] = Holding(
        symbol: symbol,
        type: type,
        quantity: totalQuantity,
        avgPriceKRW: weightedAvgPrice,
        purchaseDate: existing.purchaseDate, // 최초 매수일 유지
      );
    } else {
      // 신규 종목 추가
      holdings.add(Holding(
        symbol: symbol,
        type: type,
        quantity: quantity,
        avgPriceKRW: priceKRW,
        purchaseDate: DateTime.now(),
      ));
    }
  }

  // === 포트폴리오에서 제거 ===
  void _removeFromHoldings(int index, double quantity) {
    final holding = holdings[index];
    final remainingQuantity = holding.quantity - quantity;
    
    if (remainingQuantity <= 0.0001) { // 부동소수점 오차 고려
      holdings.removeAt(index);
    } else {
      holdings[index] = Holding(
        symbol: holding.symbol,
        type: holding.type,
        quantity: remainingQuantity,
        avgPriceKRW: holding.avgPriceKRW,
        purchaseDate: holding.purchaseDate,
      );
    }
  }

  // === 특정 종목 보유량 조회 ===
  Holding? getHolding(String symbol) {
    try {
      return holdings.firstWhere((h) => h.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  // === 전체 리셋 ===
  Future<void> resetAll() async {
    premiumNoAds = false;
    zeroFee = false;
    cashKRW = 10000000; // 초기 자본으로 리셋
    holdings.clear();
    notifyListeners();
  }

  // === 디버그 정보 ===
  void printDebugInfo() {
    debugPrint('=== UserProvider Debug Info ===');
    debugPrint('Cash: ${krw(cashKRW)}');
    debugPrint('Total Equity: ${krw(totalEquityKRW)}');
    debugPrint('Holdings Count: ${holdings.length}');
    for (final holding in holdings) {
      debugPrint('${holding.symbol}: ${holding.quantity} @ ${krw(holding.avgPriceKRW)}');
    }
    debugPrint('Premium: $premiumNoAds, Zero Fee: $zeroFee');
  }
}

// === 유틸리티 함수 ===
String krw(double amount) {
  final formatted = amount.toStringAsFixed(0);
  final buffer = StringBuffer();
  int count = 0;
  
  for (int i = formatted.length - 1; i >= 0; i--) {
    buffer.write(formatted[i]);
    count++;
    if (count == 3 && i != 0) {
      buffer.write(',');
      count = 0;
    }
  }
  
  return '₩${buffer.toString().split('').reversed.join()}';
}

// 간단한 숫자 포맷팅 (소수점 포함)
String formatNumber(double number, {int decimals = 2}) {
  return number.toStringAsFixed(decimals);
}

// 퍼센트 포맷팅
String formatPercent(double percent) {
  final sign = percent >= 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(2)}%';
}
