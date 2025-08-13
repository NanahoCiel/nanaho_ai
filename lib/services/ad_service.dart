// lib/services/ad_service.dart
// Google Mobile Ads: 전면/배너/보상형 + 프리미엄/플랫폼/웹 체크 포함
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AdService {
  AdService._();

  // --- 상태 ---
  static bool _initialized = false;

  // --- Google 테스트 광고 단위 ID (실서버는 교체 필요) ---
  static const String bannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // --- 초기화 ---
  static Future<void> initialize() async {
    if (_initialized) return;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await MobileAds.instance.initialize();
      } catch (e) {
        debugPrint('Ad initialization failed: $e');
      }
    }
    _initialized = true;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 전면 광고 (Interstitial)
  // ─────────────────────────────────────────────────────────────────────────────

  /// 기존 코드 호환용: context 받는 버전
  static Future<void> showInterstitialIfReady(BuildContext context) async {
    await showInterstitial(context);
  }

  /// 선택 인자 버전: context 없어도 호출 가능 (가능하면 context 넘겨서 프리미엄 체크 권장)
  static Future<void> showInterstitial([BuildContext? context]) async {
    bool isPremium = false;
    if (context != null) {
      try {
        isPremium = context.read<UserProvider>().premiumNoAds;
      } catch (_) {}
    }

    // 웹 / Android 아님 / 프리미엄이면 스킵
    if (kIsWeb || !Platform.isAndroid || isPremium) return;

    await initialize();

    try {
      await InterstitialAd.load(
        adUnitId: interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial load failed: ${error.message}');
          },
        ),
      );
    } catch (e) {
      debugPrint('Interstitial show error: $e');
    }
  }

  /// 일부 코드에서 사용하던 이름 호환 (존재하면 그대로 사용됨)
  static Future<void> tryShowInterstitialIfNeeded(BuildContext context) async {
    await showInterstitial(context);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 보상형 광고 (Rewarded)
  // ─────────────────────────────────────────────────────────────────────────────
  static Future<void> showRewarded([BuildContext? context, VoidCallback? onReward]) async {
    bool isPremium = false;
    if (context != null) {
      try {
        isPremium = context.read<UserProvider>().premiumNoAds;
      } catch (_) {}
    }
    if (kIsWeb || !Platform.isAndroid || isPremium) return;

    await initialize();

    try {
      await RewardedAd.load(
        adUnitId: rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
            ad.show(
              onUserEarnedReward: (ad, reward) {
                try {
                  onReward?.call();
                } catch (_) {}
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded load failed: ${error.message}');
          },
        ),
      );
    } catch (e) {
      debugPrint('Rewarded show error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 배너 광고 (위젯 빌더)
  // ─────────────────────────────────────────────────────────────────────────────
  static BannerAd? _banner;
  static bool _bannerRequested = false;
  static bool _bannerReady = false;

  static void _ensureBannerLoaded() {
    if (_bannerRequested) return;
    _bannerRequested = true;

    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          _bannerReady = false;
          ad.dispose();
          debugPrint('Banner load failed: ${error.message}');
        },
      ),
    )..load();
  }

  /// 화면 하단 등에 배치 가능한 배너 위젯
  static Widget banner(BuildContext context) {
    // 프리미엄/웹/iOS 에서는 광고 숨김
    final user = context.watch<UserProvider>();
    if (user.premiumNoAds || kIsWeb || !Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    _ensureBannerLoaded();
    if (!_bannerReady || _banner == null) {
      return const SizedBox(height: 0);
    }

    return SizedBox(
      height: _banner!.size.height.toDouble(),
      width: _banner!.size.width.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
