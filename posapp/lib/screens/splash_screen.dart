import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _gridController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _statusOpacity;
  late final Animation<double> _gridOpacity;
  late final Animation<double> _progressValue;

  final List<String> _statusMessages = [
    'Initializing system modules...',
    'Verifying security certificates...',
    'Synchronizing mainframe nodes...',
    'Loading operational data...',
    'Ready.',
  ];
  int _statusIndex = 0;

  @override
  void initState() {
    super.initState();

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _gridOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gridController, curve: Curves.easeOut),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _statusOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    _progressValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _gridController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

    // Cycle status messages
    for (int i = 1; i < _statusMessages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _statusIndex = i);
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Dot grid background
          AnimatedBuilder(
            animation: _gridOpacity,
            builder: (_, __) => Opacity(
              opacity: _gridOpacity.value * 0.15,
              child: const _DotGridPainterWidget(),
            ),
          ),

          // Gradient accents
          Positioned(
            top: -200,
            right: -200,
            child: AnimatedBuilder(
              animation: _gridOpacity,
              builder: (_, __) => Opacity(
                opacity: _gridOpacity.value * 0.3,
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo block
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, __) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Column(
                          children: [
                            // Icon mark
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.factory_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'POS SYSTEM',
                              style: AppTypography.displayLg.copyWith(
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, __) => SlideTransition(
                      position: _subtitleSlide,
                      child: Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Text(
                          'POS SYSTEM • V2.4.0',
                          style: AppTypography.labelCaps.copyWith(
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, __) => Opacity(
                      opacity: _statusOpacity.value,
                      child: Column(
                        children: [
                          // Progress track
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondary,
                              ),
                              minHeight: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Status message
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _statusMessages[_statusIndex],
                              key: ValueKey(_statusIndex),
                              style: AppTypography.bodySm.copyWith(
                                color: Colors.white.withOpacity(0.45),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom version tag
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (_, __) => Opacity(
                opacity: _subtitleOpacity.value,
                child: Center(
                  child: Text(
                    '© 2026 POS SYSTEM',
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainterWidget extends StatelessWidget {
  const _DotGridPainterWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5C6CA)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    const radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}