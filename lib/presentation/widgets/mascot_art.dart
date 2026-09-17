import 'package:flutter/material.dart';

enum MascotMood {
  happy,
  holdingCoin,
  peeking,
  coolSkater,
  thinking,
}

class CrabMascotWidget extends StatelessWidget {
  final MascotMood mood;
  final double size;
  final String? speechBubbleText;
  final bool showSparkles;

  const CrabMascotWidget({
    super.key,
    this.mood = MascotMood.happy,
    this.size = 80,
    this.speechBubbleText,
    this.showSparkles = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget mascot = CustomPaint(
      size: Size(size, size),
      painter: _CrabPainter(mood: mood),
    );

    if (speechBubbleText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mascot,
          const SizedBox(width: 6),
          _buildSpeechBubble(speechBubbleText!),
        ],
      );
    }

    return mascot;
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFBFF2A5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _CrabPainter extends CustomPainter {
  final MascotMood mood;

  _CrabPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillCrabPaint = Paint()
      ..color = const Color(0xFFFF5E48)
      ..style = PaintingStyle.fill;

    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final blackFill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final yellowGold = Paint()
      ..color = const Color(0xFFFFD12E)
      ..style = PaintingStyle.fill;

    // 1. Skateboard (if coolSkater)
    if (mood == MascotMood.coolSkater) {
      // Skateboard deck
      final boardRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 78, 84, 10),
        const Radius.circular(5),
      );
      final boardPaint = Paint()..color = const Color(0xFF191919);
      canvas.drawRRect(boardRect, boardPaint);
      canvas.drawRRect(boardRect, blackPaint);

      // Wheels
      canvas.drawCircle(const Offset(22, 92), 6, yellowGold);
      canvas.drawCircle(const Offset(22, 92), 6, blackPaint);
      canvas.drawCircle(const Offset(22, 92), 2, blackFill);

      canvas.drawCircle(const Offset(78, 92), 6, yellowGold);
      canvas.drawCircle(const Offset(78, 92), 6, blackPaint);
      canvas.drawCircle(const Offset(78, 92), 2, blackFill);
    }

    // 2. Legs
    if (mood != MascotMood.peeking) {
      _drawLeg(canvas, 30, 68, 25, 78, blackPaint, fillCrabPaint);
      _drawLeg(canvas, 70, 68, 75, 78, blackPaint, fillCrabPaint);
      _drawLeg(canvas, 20, 62, 12, 70, blackPaint, fillCrabPaint);
      _drawLeg(canvas, 80, 62, 88, 70, blackPaint, fillCrabPaint);
    }

    // 3. Claws (Arms)
    if (mood == MascotMood.holdingCoin) {
      // Left claw raised
      _drawClaw(canvas, 16, 42, -0.4, blackPaint, fillCrabPaint);
      // Right hand holding gold coin
      _drawClaw(canvas, 76, 50, 0.2, blackPaint, fillCrabPaint);
      // Giant Coin
      canvas.drawCircle(const Offset(78, 44), 16, yellowGold);
      canvas.drawCircle(const Offset(78, 44), 16, blackPaint);
      final coinInner = Paint()
        ..color = const Color(0xFFFFBA08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(const Offset(78, 44), 12, coinInner);

      // Dollar text
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '\$',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, const Offset(73, 34));
    } else if (mood == MascotMood.coolSkater) {
      // Left big claw
      _drawBigClaw(canvas, 12, 36, -0.6, blackPaint, fillCrabPaint);
      // Right claw holding dollar bills
      _drawBigClaw(canvas, 86, 38, 0.6, blackPaint, fillCrabPaint);

      // Dollar cash fan
      final greenPaint = Paint()..color = const Color(0xFF86EFAC);
      final bill1 = RRect.fromRectAndRadius(
        const Rect.fromLTWH(80, 18, 14, 20),
        const Radius.circular(2),
      );
      canvas.save();
      canvas.translate(82, 18);
      canvas.rotate(0.3);
      canvas.drawRRect(bill1, greenPaint);
      canvas.drawRRect(bill1, blackPaint);
      canvas.restore();
    } else {
      // Cheerful claws
      _drawClaw(canvas, 14, 32, -0.5, blackPaint, fillCrabPaint);
      _drawClaw(canvas, 86, 32, 0.5, blackPaint, fillCrabPaint);
    }

    // 4. Crab Body (Oval)
    final bodyRect = Rect.fromCenter(
      center: Offset(50, mood == MascotMood.peeking ? 65 : 55),
      width: 62,
      height: 44,
    );
    canvas.drawOval(bodyRect, fillCrabPaint);
    canvas.drawOval(bodyRect, blackPaint);

    // 5. Eyes & Eyeballs
    final eyeY = mood == MascotMood.peeking ? 48.0 : 38.0;

    if (mood == MascotMood.coolSkater) {
      // Sunglasses
      final glassLeft = RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 36, 22, 16),
        const Radius.circular(4),
      );
      final glassRight = RRect.fromRectAndRadius(
        const Rect.fromLTWH(52, 36, 22, 16),
        const Radius.circular(4),
      );
      final glassWhite = Paint()..color = Colors.white;
      canvas.drawRRect(glassLeft, glassWhite);
      canvas.drawRRect(glassLeft, blackPaint);
      canvas.drawRRect(glassRight, glassWhite);
      canvas.drawRRect(glassRight, blackPaint);

      // Glass shine stripes
      final shinePaint = Paint()
        ..color = const Color(0xFF191919)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawLine(const Offset(30, 48), const Offset(42, 39), shinePaint);
      canvas.drawLine(const Offset(56, 48), const Offset(68, 39), shinePaint);

      // Bridge
      canvas.drawLine(const Offset(48, 42), const Offset(52, 42), blackPaint);

      // Cap / Hat "RICH VIBES"
      final capRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 14, 46, 22),
        const Radius.circular(10),
      );
      final capPaint = Paint()..color = const Color(0xFFFFF0B3);
      canvas.drawRRect(capRect, capPaint);
      canvas.drawRRect(capRect, blackPaint);

      // Cap brim
      final brimPath = Path()
        ..moveTo(24, 32)
        ..quadraticBezierTo(50, 36, 76, 32)
        ..lineTo(74, 28)
        ..quadraticBezierTo(50, 31, 26, 28)
        ..close();
      canvas.drawPath(brimPath, capPaint);
      canvas.drawPath(brimPath, blackPaint);

      // Cap Text
      final capText = TextPainter(
        text: const TextSpan(
          text: 'RICH\nVIBES',
          style: TextStyle(
            color: Colors.black,
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
            height: 0.9,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      capText.paint(canvas, const Offset(39, 18));
    } else if (mood == MascotMood.holdingCoin) {
      // Winking left eye, open right eye
      // Left eye winking (arc)
      final winkPath = Path()
        ..moveTo(32, eyeY + 2)
        ..quadraticBezierTo(39, eyeY - 6, 46, eyeY + 2);
      canvas.drawPath(winkPath, blackPaint);

      // Right Eye (Big cartoon eye)
      canvas.drawOval(
        Rect.fromCenter(center: Offset(62, eyeY), width: 16, height: 20),
        whiteFill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(62, eyeY), width: 16, height: 20),
        blackPaint,
      );
      canvas.drawCircle(Offset(63, eyeY + 2), 6, blackFill);
      canvas.drawCircle(Offset(65, eyeY - 1), 2.5, whiteFill);
    } else {
      // Cute Double Big Eyes
      // Left eye
      canvas.drawOval(
        Rect.fromCenter(center: Offset(38, eyeY), width: 16, height: 20),
        whiteFill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(38, eyeY), width: 16, height: 20),
        blackPaint,
      );
      canvas.drawCircle(Offset(39, eyeY + 1), 6, blackFill);
      canvas.drawCircle(Offset(41, eyeY - 2), 2.5, whiteFill);

      // Right eye
      canvas.drawOval(
        Rect.fromCenter(center: Offset(62, eyeY), width: 16, height: 20),
        whiteFill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(62, eyeY), width: 16, height: 20),
        blackPaint,
      );
      canvas.drawCircle(Offset(61, eyeY + 1), 6, blackFill);
      canvas.drawCircle(Offset(63, eyeY - 2), 2.5, whiteFill);
    }

    // 6. Cute Smile / Mouth
    final mouthPath = Path();
    if (mood == MascotMood.coolSkater) {
      mouthPath.moveTo(43, 58);
      mouthPath.quadraticBezierTo(50, 65, 58, 58);
      mouthPath.close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF7F1D1D));
      canvas.drawPath(mouthPath, blackPaint);
    } else {
      mouthPath.moveTo(42, 57);
      mouthPath.quadraticBezierTo(50, 66, 58, 57);
      mouthPath.close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF7F1D1D));
      canvas.drawPath(mouthPath, blackPaint);
      // Tongue
      final tonguePath = Path()
        ..moveTo(47, 62)
        ..quadraticBezierTo(50, 65, 54, 62)
        ..close();
      canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFFF80C8));
    }

    // 7. Cheeks (Blush)
    final blushPaint = Paint()..color = const Color(0xFFFF85A1).withValues(alpha: 0.6);
    canvas.drawCircle(const Offset(27, 56), 4, blushPaint);
    canvas.drawCircle(const Offset(73, 56), 4, blushPaint);

    canvas.restore();
  }

  void _drawClaw(
    Canvas canvas,
    double x,
    double y,
    double angle,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-8, -12, -14, -6, -4, 4)
      ..cubicTo(2, 10, 10, 8, 8, 0)
      ..cubicTo(14, -8, 8, -14, 0, 0);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  void _drawBigClaw(
    Canvas canvas,
    double x,
    double y,
    double angle,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-12, -18, -20, -8, -6, 6)
      ..cubicTo(4, 14, 14, 12, 10, 0)
      ..cubicTo(18, -12, 12, -20, 0, 0);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  void _drawLeg(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final legPath = Path()
      ..moveTo(x1, y1)
      ..quadraticBezierTo((x1 + x2) / 2, y1 + 6, x2, y2);
    canvas.drawPath(legPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CrabPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
