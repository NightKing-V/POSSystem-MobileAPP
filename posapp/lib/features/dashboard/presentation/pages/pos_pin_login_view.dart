import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mock_data.dart';

/// Standalone POS PIN login screen.
/// Not part of the bottom-nav; pushed as a full-screen route.
class PosPinLoginView extends StatefulWidget {
  const PosPinLoginView({super.key});

  @override
  State<PosPinLoginView> createState() => _PosPinLoginViewState();
}

class _PosPinLoginViewState extends State<PosPinLoginView> {
  final List<int> _entered = [];
  String? _errorMessage;
  MockEmployee? _loggedInEmployee;

  static const int _pinLength = 4;

  void _onKeyTap(int digit) {
    if (_entered.length >= _pinLength || _loggedInEmployee != null) return;
    setState(() {
      _entered.add(digit);
      _errorMessage = null;
    });
    if (_entered.length == _pinLength) _checkPin();
  }

  void _onBackspace() {
    if (_entered.isEmpty || _loggedInEmployee != null) return;
    setState(() {
      _entered.removeLast();
      _errorMessage = null;
    });
  }

  void _checkPin() {
    final typed = _entered.join();
    final match = mockEmployees
        .where((e) => e.isActive && e.pin == typed)
        .cast<MockEmployee?>()
        .firstOrNull;

    if (match != null) {
      setState(() => _loggedInEmployee = match);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) Navigator.of(context).pop(match);
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Try again.';
        _entered.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    _loggedInEmployee != null
                        ? 'Welcome back!'
                        : 'POS Login',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _loggedInEmployee != null
                        ? _loggedInEmployee!.name
                        : 'Enter your 4-digit PIN',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Success avatar or PIN dots
                  if (_loggedInEmployee != null)
                    _SuccessAvatar(employee: _loggedInEmployee!)
                  else
                    _PinDots(enteredCount: _entered.length),

                  const SizedBox(height: 10),

                  // Error message
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _errorMessage != null ? 1.0 : 0.0,
                    child: Text(
                      _errorMessage ?? '',
                      style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Numpad
                  if (_loggedInEmployee == null)
                    _NumPad(
                      onDigit: _onKeyTap,
                      onBackspace: _onBackspace,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.enteredCount});

  final int enteredCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final filled = i < enteredCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.inkTeal : Colors.transparent,
              border: Border.all(
                color:
                    filled ? AppColors.inkTeal : AppColors.hairline,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SuccessAvatar extends StatelessWidget {
  const _SuccessAvatar({required this.employee});

  final MockEmployee employee;

  @override
  Widget build(BuildContext context) {
    final initials = employee.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.inkTeal.withValues(alpha: 0.12),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.inkTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          permissionSetName(employee.permissionSetId),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 12, color: const Color(0xFF16A34A)),
        ),
      ],
    );
  }
}

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onDigit, required this.onBackspace});

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  static const _rows = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row
                  .map((d) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        child: _NumKey(digit: d, onTap: onDigit),
                      ))
                  .toList(),
            ),
          ),
        ),
        // Bottom row: empty | 0 | backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 84 + 28), // placeholder for left key
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _NumKey(digit: 0, onTap: onDigit),
            ),
            SizedBox(
              width: 84,
              child: Center(
                child: GestureDetector(
                  onTap: onBackspace,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.hairline.withValues(alpha: 0.4),
                    ),
                    child: const Icon(Icons.backspace_outlined,
                        color: AppColors.ink, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.digit, required this.onTap});

  final int digit;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
              color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$digit',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 22, color: AppColors.ink),
        ),
      ),
    );
  }
}

