import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _progressValue;

  final List<String> _loadingSteps = [
    'Warming cloud clusters...',
    'Checking workspace session...',
    'Restoring active terminal...',
    'Syncing local inventory...',
    'Active.',
  ];
  
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Staggered intervals
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
      ),
    );

    _runOnboardingSequence();
  }

  Future<void> _runOnboardingSequence() async {
    // Start animations
    _animationController.forward();

    // Cycle text tags
    for (int i = 0; i < _loadingSteps.length; i++) {
      if (!mounted) return;
      setState(() => _stepIndex = i);
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // Call session initializations in the background
    if (mounted) {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.initializeSession();

      // Smooth final delay
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        // Navigating via GoRouter. The redirect handler will intercept and route:
        // - To /login if not authenticated
        // - To /business-setup if authenticated but has no business context
        // - To /dashboard if authenticated with a business context
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Dot grid overlay (refined and optimized)
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: const _StaticDotGrid(),
            ),
          ),

          // Rich dynamic radial top-right glow for a modern visual look
          Positioned(
            top: -200,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main splash logo and loading sequence
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container with Scale & Fade
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.accentPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.point_of_sale_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'CloudPOS',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Slogan and progress bar with slide transition
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => SlideTransition(
                      position: _contentSlide,
                      child: Opacity(
                        opacity: _contentOpacity.value,
                        child: child,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'THE OPERATIONAL BACKBONE FOR RETAIL',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimaryContainer,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 60),

                        // Progress Indicator
                        SizedBox(
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondary,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dynamic text switcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _loadingSteps[_stepIndex],
                            key: ValueKey(_stepIndex),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimaryContainer.withOpacity(0.65),
                              fontStyle: FontStyle.italic,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Copyright details in bottom footer
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Opacity(
                opacity: _contentOpacity.value,
                child: child,
              ),
              child: Center(
                child: Text(
                  '© 2026 CLOUDPOS INC • ALL RIGHTS RESERVED',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimaryContainer.withOpacity(0.4),
                    fontSize: 10,
                    letterSpacing: 1.5,
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

class _StaticDotGrid extends StatelessWidget {
  const _StaticDotGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    const radius = 1.0;

    for (double x = 16; x < size.width; x += spacing) {
      for (double y = 16; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
