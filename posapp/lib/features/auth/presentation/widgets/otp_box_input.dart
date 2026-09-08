import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// A 6-box segmented PIN / OTP input widget with modern receipt/ink aesthetics,
/// supporting direct typing, paste, and SMS autofill without focus glitches.
class OtpBoxInput extends StatefulWidget {
  const OtpBoxInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.hasError = false,
    this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<OtpBoxInput> createState() => _OtpBoxInputState();
}

class _OtpBoxInputState extends State<OtpBoxInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final text = value.text;
        final isFocused = _focusNode.hasFocus;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Invisible input field that handles keyboard, paste, and autofill
            Positioned.fill(
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  autofillHints: const [AutofillHints.oneTimeCode],
                  enableSuggestions: false,
                  autocorrect: false,
                  showCursor: false,
                  onChanged: (val) {
                    widget.onChanged?.call(val);
                    if (val.length == widget.length) {
                      widget.onCompleted?.call(val);
                    }
                  },
                ),
              ),
            ),
            // Visible 6-box segmented display
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _focusNode.requestFocus();
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.length, (index) {
                    final char = index < text.length ? text[index] : '';
                    final isCurrent = isFocused && index == text.length;
                    final isFilled = index < text.length;

                    Color borderColor;
                    double borderWidth;
                    List<BoxShadow> shadows = [];

                    if (widget.hasError) {
                      borderColor = AppColors.error;
                      borderWidth = 1.8;
                    } else if (isCurrent) {
                      borderColor = AppColors.inkTeal;
                      borderWidth = 2.0;
                      shadows = [
                        BoxShadow(
                          color: AppColors.inkTeal.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ];
                    } else if (isFilled) {
                      borderColor = AppColors.inkTeal.withValues(alpha: 0.8);
                      borderWidth = 1.6;
                    } else {
                      borderColor = AppColors.hairline;
                      borderWidth = 1.4;
                    }

                    return Container(
                      width: 48,
                      height: 56,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == widget.length - 1 ? 0 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                        boxShadow: shadows,
                      ),
                      alignment: Alignment.center,
                      child: isCurrent && char.isEmpty
                          ? const _BlinkingCursor()
                          : Text(
                              char,
                              style: GoogleFonts.sora(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.inkTeal,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
