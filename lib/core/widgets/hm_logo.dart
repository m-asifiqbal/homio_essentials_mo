/// ============================================================
/// HM LOGO — the Homiopedia mark (also used to render the app icon)
/// ============================================================
///
/// Teal squircle, a white leaf with a teal midrib and a peach globule —
/// plant medicine + the pellet. [HomioMarkPainter] draws it at any size;
/// `tool/icon/render_icon_test.dart` uses the same painter to export the
/// launcher icons, so the icon and the in-app logo never drift apart.
/// ============================================================
library;

import 'package:flutter/widgets.dart';

class HmLogo extends StatelessWidget {
  const HmLogo({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: 'Homiopedia',
        child: CustomPaint(size: Size.square(size), painter: const HomioMarkPainter()),
      );
}

class HomioMarkPainter extends CustomPainter {
  const HomioMarkPainter({this.background = true, this.markScale = 1, this.rounded = true});

  /// false → transparent background (Android adaptive-icon foreground).
  final bool background;

  /// false → square tile (launcher icons: iOS / Android apply their own mask).
  final bool rounded;

  /// Shrinks the leaf + globule around the centre (adaptive icons keep art in the inner 66%).
  final double markScale;

  static const teal1 = Color(0xFF0B5557);
  static const teal2 = Color(0xFF1B8077);
  static const peach = Color(0xFFFF9B7B);

  @override
  void paint(Canvas c, Size s) {
    final k = s.width / 48;
    if (background) {
      final rect = Offset.zero & s;
      c.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rounded ? 14 * k : 0)),
        Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [teal1, teal2]).createShader(rect),
      );
    }
    c.save();
    c.translate(s.width / 2, s.height / 2);
    c.scale(markScale);
    c.translate(-s.width / 2, -s.height / 2);
    // leaf
    final leaf = Path()
      ..moveTo(12.5 * k, 35.5 * k)
      ..cubicTo(11.5 * k, 21 * k, 20 * k, 12.5 * k, 35.5 * k, 12.5 * k)
      ..cubicTo(36 * k, 27 * k, 27.5 * k, 36.5 * k, 12.5 * k, 35.5 * k)
      ..close();
    c.drawPath(leaf, Paint()..color = const Color(0xFFFFFFFF)..isAntiAlias = true);
    // midrib
    c.drawPath(
      Path()
        ..moveTo(15.5 * k, 32.3 * k)
        ..quadraticBezierTo(21 * k, 24.5 * k, 29 * k, 18.5 * k),
      Paint()
        ..color = teal1
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1 * k
        ..strokeCap = StrokeCap.round,
    );
    // globule (pellet) with a soft highlight
    c.drawCircle(Offset(34.5 * k, 34.5 * k), 5 * k, Paint()..color = peach);
    c.drawCircle(Offset(33 * k, 33 * k), 1.5 * k, Paint()..color = const Color(0x99FFFFFF));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant HomioMarkPainter old) => old.background != background || old.markScale != markScale || old.rounded != rounded;
}
