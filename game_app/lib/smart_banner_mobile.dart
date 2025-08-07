
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SmartBanner extends StatefulWidget {
  const SmartBanner({super.key});

  @override
  State<SmartBanner> createState() => _SmartBannerState();
}

class _SmartBannerState extends State<SmartBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _triedFallback = false;


  @override
  void initState() {
    debugPrint('[SmartBanner] initState called');
    super.initState();
    _loadBanner(adSize: AdSize.smartBanner);
  }

  void _loadBanner({required AdSize adSize}) {
    debugPrint('[SmartBanner] _loadBanner called with adSize: $adSize, _triedFallback: $_triedFallback');
    _bannerAd?.dispose();
    const adUnitId = 'ca-app-pub-9458331875641856/4822531524'; // Real AdMob banner ID
    debugPrint('[SmartBanner] Initializing BannerAd with adUnitId: $adUnitId, size: $adSize');
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[SmartBanner] onAdLoaded called');
          debugPrint('[SmartBanner] BannerAd loaded successfully.');
          final loadedSize = (ad as BannerAd).size;
          debugPrint('[SmartBanner] Loaded ad size: ${loadedSize.width} x ${loadedSize.height}');
          if ((loadedSize.height.isNaN || loadedSize.height <= 0) && !_triedFallback && adSize == AdSize.smartBanner) {
            debugPrint('[SmartBanner] Invalid SmartBanner size: ${loadedSize.height}, falling back to standard banner.');
            setState(() {
              _triedFallback = true;
              _isAdLoaded = false;
            });
            _loadBanner(adSize: AdSize.banner);
            return;
          }
          setState(() {
            _isAdLoaded = true;
          });
          debugPrint('[SmartBanner] _isAdLoaded set to true');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[SmartBanner] onAdFailedToLoad called');
          debugPrint('[SmartBanner] Failed to load BannerAd: ${error.code} - ${error.message}');
          ad.dispose();
          if (!_triedFallback && adSize == AdSize.smartBanner) {
            debugPrint('[SmartBanner] SmartBanner failed, falling back to standard banner.');
            setState(() {
              _triedFallback = true;
              _isAdLoaded = false;
            });
            _loadBanner(adSize: AdSize.banner);
            return;
          }
          setState(() {
            _isAdLoaded = false;
          });
          debugPrint('[SmartBanner] _isAdLoaded set to false');
        },
      ),
    )..load();
    debugPrint('[SmartBanner] BannerAd load() called');
  }

  @override
  void dispose() {
    debugPrint('[SmartBanner] dispose called');
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[SmartBanner] build called, _isAdLoaded: $_isAdLoaded, _bannerAd: ${_bannerAd != null}');
    if (!_isAdLoaded || _bannerAd == null) {
      debugPrint('[SmartBanner] build: No ad loaded, returning SizedBox.shrink()');
      return const SizedBox.shrink();
    }
    final adSize = _bannerAd!.size;
    debugPrint('[SmartBanner] build: adSize: ${adSize.width} x ${adSize.height}');
    if (adSize.height.isNaN || adSize.height <= 0) {
      debugPrint('[SmartBanner] Invalid ad size after fallback: ${adSize.height}');
      return const SizedBox.shrink();
    }
    debugPrint('[SmartBanner] build: Showing banner');
    return SizedBox(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}