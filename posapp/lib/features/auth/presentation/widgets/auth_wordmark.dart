import 'package:flutter/material.dart';

/// Reusable brand logo/wordmark for authentication screens.
class AuthWordmark extends StatelessWidget {
  const AuthWordmark({super.key, this.height = 72});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo.png', height: height);
  }
}
