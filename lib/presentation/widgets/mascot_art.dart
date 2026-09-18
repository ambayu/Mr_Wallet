import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

enum MascotMood {
  happy,
  holdingCoin,
  peeking,
  coolSkater,
  thinking,
  withPhone,
  piggyBank,
  celebration,
  checklist,
  workingLaptop,
}

class CrabMascotWidget extends StatelessWidget {
  final MascotMood mood;
  final String? assetPath;
  final double size;
  final String? speechBubbleText;
  final bool showSparkles;
  final BoxFit fit;

  const CrabMascotWidget({
    super.key,
    this.mood = MascotMood.happy,
    this.assetPath,
    this.size = 80,
    this.speechBubbleText,
    this.showSparkles = true,
    this.fit = BoxFit.contain,
  });

  String get _effectiveAsset {
    if (assetPath != null) return assetPath!;
    switch (mood) {
      case MascotMood.happy:
        return AppAssets.mascotHappy;
      case MascotMood.holdingCoin:
        return AppAssets.mascotRpCoin;
      case MascotMood.peeking:
        return AppAssets.mascotHalfBody;
      case MascotMood.coolSkater:
        return AppAssets.mascotScooter;
      case MascotMood.thinking:
        return AppAssets.mascotThinking;
      case MascotMood.withPhone:
        return AppAssets.mascotPhone;
      case MascotMood.piggyBank:
        return AppAssets.mascotPiggyBank;
      case MascotMood.celebration:
        return AppAssets.mascotConfetti;
      case MascotMood.checklist:
        return AppAssets.mascotChecklist;
      case MascotMood.workingLaptop:
        return AppAssets.mascotLaptop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      _effectiveAsset,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return CustomPaint(
          size: Size(size, size),
          painter: _CrabPainter(mood: mood),
        );
      },
    );

    if (speechBubbleText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          const SizedBox(width: 8),
          Flexible(child: _buildSpeechBubble(speechBubbleText!)),
        ],
      );
    }

    return imageWidget;
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlack, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textBlack,
          letterSpacing: 0.1,
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

    final bodyRect = Rect.fromCenter(
      center: const Offset(50, 55),
      width: 62,
      height: 44,
    );
    canvas.drawOval(bodyRect, fillCrabPaint);
    canvas.drawOval(bodyRect, blackPaint);

    // Eyes
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 38), width: 16, height: 20),
      whiteFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 38), width: 16, height: 20),
      blackPaint,
    );
    canvas.drawCircle(const Offset(39, 39), 6, blackFill);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(62, 38), width: 16, height: 20),
      whiteFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(62, 38), width: 16, height: 20),
      blackPaint,
    );
    canvas.drawCircle(const Offset(61, 39), 6, blackFill);

    // Smile
    final mouthPath = Path()
      ..moveTo(42, 57)
      ..quadraticBezierTo(50, 66, 58, 57)
      ..close();
    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF7F1D1D));
    canvas.drawPath(mouthPath, blackPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CrabPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
