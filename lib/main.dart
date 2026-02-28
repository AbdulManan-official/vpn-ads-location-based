import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yandex_mobileads/mobile_ads.dart' as yandex;

// CONFIG
const kGeoApiKey          = 'e57aa2f323724bc2bd16b7f5d8ca8022';
const kYandexBanner       = 'demo-banner-yandex';        // real: R-M-18805402-1
const kYandexInterstitial = 'demo-interstitial-yandex';  // real: R-M-18805402-2
const kAdmobBanner        = 'ca-app-pub-3940256099942544/6300978111';
const kAdmobInterstitial  = 'ca-app-pub-3940256099942544/1033173712';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await yandex.MobileAds.initialize();
  await MobileAds.instance.initialize();
  debugPrint('Both ad SDKs initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ads Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _isRussia = false;
  Map<String, dynamic> _locationData = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  yandex.BannerAd? _yBanner;
  bool _yBannerReady = false;
  bool _bannerInit = false;
  late final Future<yandex.InterstitialAdLoader> _yLoader;
  yandex.InterstitialAd? _yInterstitial;

  BannerAd? _aBanner;
  bool _aBannerReady = false;
  InterstitialAd? _aInterstitial;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _init();
  }

  Future<void> _init() async {
    try {
      debugPrint('Fetching user location...');
      final res = await http
          .get(Uri.parse(
          'https://api.ipgeolocation.io/ipgeo?apiKey=$kGeoApiKey'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        _locationData = jsonDecode(res.body);
        final country =
        _locationData['country_code2']?.toString().toUpperCase();
        _isRussia = country == 'RU';
        debugPrint('Country: $country | Using: ${_isRussia ? "Yandex" : "AdMob"}');
      } else {
        debugPrint('Geo API error — defaulting to AdMob');
      }
    } catch (e) {
      debugPrint('Location failed: $e — defaulting to AdMob');
    }

    setState(() => _loading = false);
    _animController.forward();

    if (_isRussia) {
      _yLoader = yandex.InterstitialAdLoader.create(
        onAdLoaded: (ad) {
          _yInterstitial = ad;
          debugPrint('Yandex Interstitial ready');
        },
        onAdFailedToLoad: (e) => debugPrint('Yandex Interstitial failed: $e'),
      );
      _loadYandexInterstitial();
    } else {
      _yLoader = yandex.InterstitialAdLoader.create(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (_) {},
      );
      _loadAdmobInterstitial();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_bannerInit && mounted) {
        _bannerInit = true;
        _isRussia ? _loadYandexBanner() : _loadAdmobBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _loading
          ? _buildShimmer()
          : SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildBadge(),
                  const SizedBox(height: 20),
                  _buildInfoGrid(),
                  const Spacer(),
                  _buildBannerArea(),
                  const SizedBox(height: 20),
                  _buildButton(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SHIMMER LOADER
  Widget _buildShimmer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF1A1A2E),
          highlightColor: const Color(0xFF2E2E4E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  _sBox(w: 44, h: 44, r: 8),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sBox(w: 160, h: 18, r: 6),
                      const SizedBox(height: 6),
                      _sBox(w: 100, h: 12, r: 6),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Badge
              _sBox(w: 160, h: 30, r: 30),
              const SizedBox(height: 20),
              // Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: List.generate(
                  4,
                      (_) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Banner
              _sBox(w: double.infinity, h: 100, r: 14),
              const SizedBox(height: 20),
              // Button
              _sBox(w: double.infinity, h: 50, r: 14),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sBox({required double w, required double h, required double r}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r),
        ),
      );

  // HEADER
  Widget _buildHeader() {
    final flag = _locationData['country_flag'] as String? ?? '';
    final country = _locationData['country_name'] as String? ?? 'Unknown';
    final city = _locationData['city'] as String? ?? '';
    final region = _locationData['state_prov'] as String? ?? '';
    final loc = [city, region].where((s) => s.isNotEmpty).join(', ');

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: flag.isNotEmpty
              ? Image.network(flag,
              width: 44, height: 44, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _flagFallback())
              : _flagFallback(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(country,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              if (loc.isNotEmpty)
                Text(loc,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _flagFallback() => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.flag_rounded, color: Colors.white38, size: 20),
  );

  // BADGE
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isRussia
              ? [const Color(0xFFB71C1C), const Color(0xFFE53935)]
              : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isRussia ? Icons.ads_click_rounded : Icons.campaign_rounded,
            color: Colors.white, size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            _isRussia ? 'Serving Yandex Ads' : 'Serving AdMob Ads',
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // INFO GRID
  Widget _buildInfoGrid() {
    final ip = _locationData['ip'] as String? ?? 'N/A';
    final isp = _locationData['isp'] as String? ?? 'N/A';
    final tz = (_locationData['time_zone'] as Map?)?['name'] as String? ?? 'N/A';
    final currency =
        (_locationData['currency'] as Map?)?['code'] as String? ?? 'N/A';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _gridTile(Icons.wifi_rounded, 'IP Address', ip, const Color(0xFF7C4DFF)),
        _gridTile(Icons.business_rounded, 'ISP', isp, const Color(0xFF00BCD4)),
        _gridTile(Icons.schedule_rounded, 'Timezone', tz, const Color(0xFF4CAF50)),
        _gridTile(Icons.monetization_on_rounded, 'Currency', currency, const Color(0xFFFF9800)),
      ],
    );
  }

  Widget _gridTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10, letterSpacing: 0.4)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  // BANNER
  Widget _buildBannerArea() {
    final ready =
        (_isRussia && _yBannerReady) || (!_isRussia && _aBannerReady);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: ready
          ? _bannerWidget()
          : Shimmer.fromColors(
        baseColor: const Color(0xFF1A1A2E),
        highlightColor: const Color(0xFF2E2E4E),
        child: Container(color: Colors.white),
      ),
    );
  }

  Widget _bannerWidget() {
    if (_isRussia && _yBanner != null) {
      return yandex.AdWidget(bannerAd: _yBanner!);
    }
    if (!_isRussia && _aBanner != null) {
      return AdWidget(ad: _aBanner!);
    }
    return const SizedBox();
  }

  // BUTTON
  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showInterstitial,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded, size: 18),
            SizedBox(width: 8),
            Text('Show Interstitial Ad',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // YANDEX
  void _loadYandexBanner() {
    final w = MediaQuery.of(context).size.width.round();
    debugPrint('Loading Yandex Banner (width: $w)...');
    _yBanner = yandex.BannerAd(
      adUnitId: kYandexBanner,
      adSize: yandex.BannerAdSize.inline(width: w, maxHeight: 100),
      onAdLoaded: () {
        debugPrint('Yandex Banner loaded');
        setState(() => _yBannerReady = true);
      },
      onAdFailedToLoad: (e) => debugPrint('Yandex Banner failed: $e'),
      onAdClicked: () => debugPrint('Yandex Banner clicked'),
      onImpression: (_) => debugPrint('Yandex Banner impression'),
    );
    _yBanner!.loadAd();
  }

  Future<void> _loadYandexInterstitial() async {
    final loader = await _yLoader;
    await loader.loadAd(
      adRequestConfiguration:
      yandex.AdRequestConfiguration(adUnitId: kYandexInterstitial),
    );
  }

  void _showYandexInterstitial() {
    if (_yInterstitial == null) {
      debugPrint('Yandex Interstitial not ready yet');
      return;
    }
    _yInterstitial!.show();
    _yInterstitial = null;
    _loadYandexInterstitial();
    Future.delayed(
        const Duration(milliseconds: 500), _showDetailsSheet);
  }

  // ADMOB
  void _loadAdmobBanner() {
    debugPrint('Loading AdMob Banner...');
    _aBanner = BannerAd(
      adUnitId: kAdmobBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('AdMob Banner loaded');
          setState(() => _aBannerReady = true);
        },
        onAdFailedToLoad: (ad, e) {
          debugPrint('AdMob Banner failed: $e');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadAdmobInterstitial() {
    InterstitialAd.load(
      adUnitId: kAdmobInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _aInterstitial = ad;
          debugPrint('AdMob Interstitial ready');
        },
        onAdFailedToLoad: (e) => debugPrint('AdMob Interstitial failed: $e'),
      ),
    );
  }

  void _showAdmobInterstitial() {
    if (_aInterstitial == null) {
      debugPrint('AdMob Interstitial not ready yet');
      return;
    }
    _aInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadAdmobInterstitial();
        _showDetailsSheet();
      },
      onAdFailedToShowFullScreenContent: (ad, e) => ad.dispose(),
    );
    _aInterstitial!.show();
    _aInterstitial = null;
  }

  void _showInterstitial() =>
      _isRussia ? _showYandexInterstitial() : _showAdmobInterstitial();

  // DETAILS BOTTOM SHEET
  void _showDetailsSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Full Location Details',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _sheetRow(Icons.public_rounded, 'Country',
                '${_locationData['country_name'] ?? 'N/A'} (${_locationData['country_code2'] ?? ''})'),
            _sheetRow(Icons.location_city_rounded, 'City',
                _locationData['city'] ?? 'N/A'),
            _sheetRow(Icons.map_rounded, 'Region',
                _locationData['state_prov'] ?? 'N/A'),
            _sheetRow(Icons.wifi_rounded, 'IP Address',
                _locationData['ip'] ?? 'N/A'),
            _sheetRow(Icons.business_rounded, 'ISP',
                _locationData['isp'] ?? 'N/A'),
            _sheetRow(Icons.router_rounded, 'Organization',
                _locationData['organization'] ?? 'N/A'),
            _sheetRow(Icons.schedule_rounded, 'Timezone',
                (_locationData['time_zone'] as Map?)?['name'] ?? 'N/A'),
            _sheetRow(Icons.attach_money_rounded, 'Currency',
                '${(_locationData['currency'] as Map?)?['name'] ?? 'N/A'} (${(_locationData['currency'] as Map?)?['code'] ?? ''})'),
            _sheetRow(Icons.gps_fixed_rounded, 'Coordinates',
                '${_locationData['latitude'] ?? 'N/A'}, ${_locationData['longitude'] ?? 'N/A'}'),
            _sheetRow(Icons.phone_rounded, 'Calling Code',
                '+${_locationData['calling_code'] ?? 'N/A'}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: Colors.deepPurpleAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DISPOSE
  @override
  void dispose() {
    _animController.dispose();
    _yBanner?.destroy();
    _yInterstitial?.destroy();
    _aBanner?.dispose();
    _aInterstitial?.dispose();
    super.dispose();
  }
}