import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RAdBanner extends StatefulWidget {
  const RAdBanner({super.key});

  @override
  State<RAdBanner> createState() => _RAdBannerState();
}

class _RAdBannerState extends State<RAdBanner> {
  late BannerAd _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId, // 替換為你的廣告單元 ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          log('Ad failed to load: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  String get getBannerAdUnitId {
    bool isDev = kDebugMode; // or use your own env flag
    if (isDev) {
      return 'ca-app-pub-3940256099942544/6300978111'; // 測試 ID
    } else {
      return 'ca-app-pub-3770234564897287/8430193701';
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    );
  }
}
