import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SmartBanner extends StatefulWidget {
  const SmartBanner({super.key});
  @override
  State<SmartBanner> createState() => _SmartBannerState();
}

class _SmartBannerState extends State<SmartBanner> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.smartBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      return const SizedBox(height: 60);
    }
    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}