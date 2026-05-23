import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberStation = false;
  bool _isAuthenticating = false;

  late final AnimationController _entryController;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthenticate() async {
    if (_isAuthenticating) return;
    FocusScope.of(context).unfocus();

    setState(() => _isAuthenticating = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decorative elements
          const _BackgroundDecorations(),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Brand header
                  SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _headerOpacity,
                      child: const _BrandHeader(),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Login card
                  SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardOpacity,
                      child: _LoginCard(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        rememberStation: _rememberStation,
                        isAuthenticating: _isAuthenticating,
                        onTogglePassword: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        onToggleRemember: (v) {
                          setState(() => _rememberStation = v ?? false);
                        },
                        onAuthenticate: _handleAuthenticate,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Security footer
                  FadeTransition(
                    opacity: _cardOpacity,
                    child: const _SecurityFooter(),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brand Header ────────────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Industrial POS',
          style: AppTypography.displayLg.copyWith(
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'POS SYSTEM • V2.4.0',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Login Card ──────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberStation,
    required this.isAuthenticating,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onAuthenticate,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberStation;
  final bool isAuthenticating;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onAuthenticate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card heading
            Text(
              'Access Portal',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter credentials to synchronize with the mainframe.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            // Email field
            _FieldLabel(label: 'Corporate Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'j.doe@industrial-corp.com',
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  color: AppColors.outline,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Password field
            _FieldLabel(label: 'Security Key'),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: '••••••••••••',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.outline,
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: onTogglePassword,
                  child: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.outline,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Remember + Reset row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember station checkbox
                GestureDetector(
                  onTap: () => onToggleRemember(!rememberStation),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: rememberStation,
                          onChanged: onToggleRemember,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember station',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Reset link
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Reset access',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Authenticate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAuthenticate,
                child: isAuthenticating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AUTHENTICATE',
                      style: AppTypography.titleSm.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

// ─── Security Footer ─────────────────────────────────────────────────────────

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user,
                color: Color(0xFF16A34A),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Encrypted Connection Active',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 16,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(width: 16),
              Text(
                'IP: 192.168.1.104',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 Industrial Global Systems. Unauthorized access is strictly\nprohibited and logged.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Background Decorations ──────────────────────────────────────────────────

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.2,
          child: Stack(
            children: [
              // Top-right gradient blob
              Positioned(
                top: -size.width * 0.5,
                right: -size.width * 0.2,
                child: Container(
                  width: size.width * 1.2,
                  height: size.width * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondaryFixed.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom-left gradient blob
              Positioned(
                bottom: -size.width * 0.4,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width,
                  height: size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.surfaceContainerHighest.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Dot grid overlay
              CustomPaint(
                painter: _DotGridPainter(),
                size: size,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5C6CA)
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