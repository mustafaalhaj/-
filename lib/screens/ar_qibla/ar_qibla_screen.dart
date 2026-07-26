import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class ARQiblaScreen extends StatefulWidget {
  const ARQiblaScreen({super.key});

  @override
  State<ARQiblaScreen> createState() => _ARQiblaScreenState();
}

class _ARQiblaScreenState extends State<ARQiblaScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;

  // Qibla & Location
  double? _qiblaDirection; // Confirmed Qibla bearing
  double _heading = 0.0;
  String _statusMessage = 'جاري التحميل...';

  // Smoothing
  double _lastHeading = 0.0;
  final double _alpha = 0.15; // Filter factor

  // Kaaba Constants
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initEverything();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle camera resource release/re-acquire
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initEverything() async {
    await _checkPermissions();
    await _initCamera();
    await _initLocationAndQibla();
  }

  Future<void> _checkPermissions() async {
    await [Permission.camera, Permission.locationWhenInUse].request();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _statusMessage = 'لا توجد كاميرا متاحة');
        return;
      }

      // Use the first back camera
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'خطأ في الكاميرا: $e');
      }
    }
  }

  Future<void> _initLocationAndQibla() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _statusMessage = 'يرجى تفعيل خدمة الموقع');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double qibla = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _qiblaDirection = qibla;
          _statusMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'خطأ في الموقع: $e');
      }
    }
  }

  double _calculateQiblaDirection(double lat, double lng) {
    final latRad = lat * (math.pi / 180);
    final lngRad = lng * (math.pi / 180);
    final kaabaLatRad = _kaabaLat * (math.pi / 180);
    final kaabaLngRad = _kaabaLng * (math.pi / 180);

    final y = math.sin(kaabaLngRad - lngRad);
    final x =
        math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(kaabaLngRad - lngRad);

    var qibla = math.atan2(y, x) * (180 / math.pi);
    return (qibla + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Layer
          if (_isCameraInitialized && _controller != null)
            CameraPreview(_controller!)
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
              ),
            ),

          // 2. Overlay Layer (Compass & AR Arrow)
          StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.heading != null) {
                // Smoothing
                double newHeading = snapshot.data!.heading!;

                // Fix wrapping issue (0 -> 360)
                if (newHeading - _lastHeading > 180) _lastHeading += 360;
                if (_lastHeading - newHeading > 180) _lastHeading -= 360;

                _lastHeading =
                    _lastHeading * (1 - _alpha) + newHeading * _alpha;

                // The actual heading to display/use
                _heading = (_lastHeading % 360 + 360) % 360;
              }

              if (_qiblaDirection == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Calculate Angle to rotate the arrow
              // Arrow points UP (0 deg) by default.
              // We want it to point to Qibla relative to North.
              // Rotation = (Qibla - Heading)
              double rotationAngle =
                  (_qiblaDirection! - _heading) * (math.pi / 180);

              // Determine if "Found" (within 5 degrees)
              bool isAligned =
                  (_qiblaDirection! - _heading).abs() < 5 ||
                  (_qiblaDirection! - _heading).abs() > 355;

              return Stack(
                children: [
                  // Gradient Overlay for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Bar
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "AR Qibla",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 30), // Placeholder for balance
                      ],
                    ),
                  ),

                  // Center Arrow
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The AR Object (Arrow)
                        Transform.rotate(
                          angle: rotationAngle,
                          child: Column(
                            children: [
                              // 3D-ish Arrow
                              Icon(
                                Icons.navigation,
                                size: 150,
                                color: isAligned
                                    ? Colors.greenAccent
                                    : Colors.white.withValues(alpha: 0.9),
                                shadows: [
                                  BoxShadow(
                                    color: isAligned
                                        ? Colors.green.withValues(alpha: 0.8)
                                        : Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Status Text
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isAligned
                                ? Colors.green.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            isAligned
                                ? "أنت تواجه القبلة الآن"
                                : "ابحث عن القبلة...",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Info
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "${_heading.toStringAsFixed(0)}°",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "اتجاهك الحالي",
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
