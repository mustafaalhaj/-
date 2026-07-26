import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ana_muslim/screens/ar_qibla/ar_qibla_screen.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../utils/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  static const double _makkahLat = 21.422487;
  static const double _makkahLng = 39.826206;

  double? _qiblaDirection;
  double _heading = 0.0;
  CompassEvent? _lastCompassEvent;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasCompass = true;

  final double _alpha = 0.15;

  @override
  void initState() {
    super.initState();
    _checkDeviceSensors();
    _initLocation();
  }

  Future<void> _checkDeviceSensors() async {
    final stream = FlutterCompass.events;
    try {
      final event = await stream?.first.timeout(const Duration(seconds: 2));
      if (event == null) {
        if (mounted) setState(() => _hasCompass = false);
      }
    } catch (e) {
      if (mounted) setState(() => _hasCompass = false);
    }
  }

  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _errorMessage = 'يرجى السماح بالوصول للموقع لحساب القبلة';
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = 'يرجى تفعيل صلاحية الموقع من الإعدادات';
            _isLoading = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final qibla = _calculateProfessionalQibla(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _qiblaDirection = qibla;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطأ في تحديد الموقع: $e';
          _isLoading = false;
        });
      }
    }
  }

  double _calculateProfessionalQibla(double userLat, double userLng) {
    final userLatRad = userLat * (math.pi / 180.0);
    final makkahLatRad = _makkahLat * (math.pi / 180.0);
    final deltaLongRad = (_makkahLng - userLng) * (math.pi / 180.0);

    final y = math.sin(deltaLongRad);
    final x =
        math.cos(userLatRad) * math.tan(makkahLatRad) -
        math.sin(userLatRad) * math.cos(deltaLongRad);

    double qiblaRad = math.atan2(y, x);
    double qiblaDeg = qiblaRad * (180.0 / math.pi);

    return (qiblaDeg + 360) % 360;
  }

  Future<void> _openGoogleMapsQibla() async {
    final Uri url = Uri.parse('https://qiblafinder.withgoogle.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح الخرائط')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'القبلة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'AR View',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ARQiblaScreen()),
            ),
          ),
        ],
      ),
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: !_hasCompass
              ? _buildNoCompassFallback()
              : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _buildCompassStream(),
        ),
      ),
    );
  }

  Widget _buildCompassStream() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطأ في البوصلة',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            _lastCompassEvent == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final event = snapshot.data;
        if (event != null) {
          _lastCompassEvent = event;
        }

        if (_lastCompassEvent == null) return const SizedBox();

        double? newHeading = _lastCompassEvent!.heading;

        if (newHeading == null) return _buildNoCompassFallback();

        double diff = newHeading - _heading;
        if (diff.abs() > 180) {
          if (diff > 0) {
            diff -= 360;
          } else {
            diff += 360;
          }
        }
        _heading += diff * _alpha;

        if (_heading < 0) _heading += 360;
        if (_heading >= 360) _heading -= 360;

        final bool needsCalibration = (_lastCompassEvent!.accuracy ?? 0) < 15;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Crucial for centering
            children: [
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      'درجة القبلة',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_qiblaDirection?.toStringAsFixed(1)}°',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildCompassDisk(_heading),

              const SizedBox(height: 40),

              if (needsCalibration)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'دقة منخفضة! حرك هاتفك على شكل 8',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'قم بتدوير الهاتف باتجاه الكعبة',
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 14),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompassDisk(double heading) {
    return SizedBox(
      height: 320,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 4,
              ),
            ),
          ),

          Transform.rotate(
            angle: -heading * (math.pi / 180),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/compass_dial.png',
                  width: 280,
                  height: 280,
                  errorBuilder: (c, e, s) => _buildFallbackDial(),
                ),

                if (_qiblaDirection != null)
                  Transform.rotate(
                    angle: _qiblaDirection! * (math.pi / 180),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.quranGold,
                              size: 36,
                            ),
                            Container(
                              height: 40,
                              width: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.quranGold,
                                    AppColors.quranGold.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            child: Column(
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 40,
                ),
              ],
            ),
          ),

          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackDial() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white24),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'W',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoCompassFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sensor_occupied_rounded,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 20),
          Text(
            'جهازك لا يدعم البوصلة',
            style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _openGoogleMapsQibla,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            icon: const Icon(Icons.map_rounded),
            label: const Text('استخدام خريطة القبلة'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initLocation,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
