import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../data/services/admob_config.dart';

/// AdMob banner shown on the home screen, after the search card.
///
/// Renders nothing (not even a placeholder) on iOS, when no unit id is
/// configured, or while/if the ad fails to load — see
/// [AdMobConfig.isHomeBannerEnabled].
class HomeAdBanner extends StatefulWidget {
  const HomeAdBanner({super.key});

  @override
  State<HomeAdBanner> createState() => _HomeAdBannerState();
}

class _HomeAdBannerState extends State<HomeAdBanner> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    if (AdMobConfig.isHomeBannerEnabled) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    final bannerAd = BannerAd(
      adUnitId: AdMobConfig.effectiveHomeBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (bannerAd == null) return const SizedBox.shrink();

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AdWidget(ad: bannerAd),
    );
  }
}
