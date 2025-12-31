import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_background.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Video player for optional tunnel video
  VideoPlayerController? _videoController;
  bool _hasVideo = false;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();

    // Animation controller - smooth, broadcast style
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Subtle scale animation (no bounce - broadcast style)
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Try to load video, fall back to static if not available
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Check if video asset exists with a timeout
      await rootBundle.load('assets/images/tunnel.mp4').timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw Exception('Video load timeout'),
      );

      // Video exists, initialize player with timeout
      _videoController = VideoPlayerController.asset('assets/images/tunnel.mp4');
      await _videoController!.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('Video init timeout'),
      );

      if (mounted) {
        setState(() {
          _hasVideo = true;
          _videoInitialized = true;
        });

        // Play video and navigate when complete
        _videoController!.play();
        _videoController!.addListener(_onVideoProgress);

        // Safety timeout - navigate after max 5 seconds even if video doesn't complete
        Future.delayed(const Duration(milliseconds: 5000), () {
          if (mounted) _navigateToHome();
        });
      }
    } catch (e) {
      // Video doesn't exist or failed to load, use static fallback
      _startStaticSplash();
    }
  }

  void _onVideoProgress() {
    if (_videoController == null) return;

    // Check if video is complete
    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    if (position >= duration && duration > Duration.zero) {
      _navigateToHome();
    }
  }

  void _startStaticSplash() {
    // Start animation
    _controller.forward();

    // Navigate to home after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If video is available and initialized, show video
    if (_hasVideo && _videoInitialized && _videoController != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Video background
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
            // Overlay with logo (optional - can be removed for pure video)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie soccer ball animation
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Lottie.asset(
                      'assets/icon/soccer-ball.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Football IQ',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test your football knowledge',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Static fallback with tunnel background
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: PitchBackground.zone(
        zone: BackgroundZone.tunnel,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie soccer ball animation
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Lottie.asset(
                          'assets/icon/soccer-ball.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Football IQ',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Test your football knowledge',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
