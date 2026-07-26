import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  // 24/7 Live Stream IDs
  static const String _makkahVideoId =
      'bBGqT77xq3I'; // Or Channel: UCrM2f534g9g-E69XQk9g_ng
  static const String _madinahVideoId =
      'vvZMHBH0NUc'; // Or Channel: UCs_8i6QWdJd8kC2_k8A7_cA

  late final WebViewController _controller;
  bool _isMakkah = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Enable landscape for better viewing experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(_getEmbedUrl(_makkahVideoId)));
  }

  String _getEmbedUrl(String videoId) {
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&controls=1&rel=0&playsinline=1';
  }

  void _switchChannel() {
    setState(() {
      _isMakkah = !_isMakkah;
      _isLoading = true;
    });
    final newId = _isMakkah ? _makkahVideoId : _madinahVideoId;
    _controller.loadRequest(Uri.parse(_getEmbedUrl(newId)));
  }

  @override
  void dispose() {
    // Reset orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Area (Aspect Ratio 16:9)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                ],
              ),
            ),

            // Controls & Info
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Color(0xFF1a1a2e)],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isMakkah ? 'مكة المكرمة' : 'المدينة المنورة',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'بث مباشر الآن',
                                    style: GoogleFonts.cairo(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _switchChannel,
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white10,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Channel Switcher Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildChannelCard('مكة المكرمة', '🕋', _isMakkah, () {
                          if (!_isMakkah) _switchChannel();
                        }),
                        _buildChannelCard(
                          'المدينة المنورة',
                          '🕌',
                          !_isMakkah,
                          () {
                            if (_isMakkah) _switchChannel();
                          },
                        ),
                      ],
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    String title,
    String icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.black : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
