import 'package:flutter/material.dart';

/// Clips the bottom edge of a container into a zigzag, like a receipt
/// torn off a till roll. This is the signature detail for the auth
/// screens — everything else on the page stays quiet so this reads
/// as intentional rather than decorative noise.
class ReceiptEdgeClipper extends CustomClipper<Path> {
  const ReceiptEdgeClipper({this.zigzagHeight = 10, this.zigzagWidth = 16});

  final double zigzagHeight;
  final double zigzagWidth;

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - zigzagHeight);

    final zigzagCount = (size.width / zigzagWidth).ceil();
    var goingUp = true;
    for (var i = 0; i < zigzagCount; i++) {
      final x = (i + 1) * zigzagWidth;
      final y = goingUp ? size.height : size.height - zigzagHeight;
      path.lineTo(x.clamp(0, size.width), y);
      goingUp = !goingUp;
    }

    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Small barcode-style tick marks used under the wordmark on auth
/// screens. Purely decorative, sized to sit under a title line.
class BarcodeTicks extends StatelessWidget {
  const BarcodeTicks({super.key, this.color = const Color(0xFF0B3D3A)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Deterministic pseudo-random-looking widths so it reads as a
    // barcode rather than a uniform striped bar.
    const widths = [2.0, 4.0, 2.0, 6.0, 2.0, 2.0, 4.0, 8.0, 2.0, 4.0, 2.0, 6.0];
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final w in widths) ...[
            Container(width: w, height: 18, color: color),
            const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}