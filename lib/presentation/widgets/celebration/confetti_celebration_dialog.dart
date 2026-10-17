import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../neo_button.dart';

/// Modal Perayaan dengan Animasi Partikel Konfetti Jatuh (Bergaya Neo-Brutalist)
class ConfettiCelebrationDialog extends StatefulWidget {
  final String title;
  final double targetAmount;
  final String? walletName;
  final String? subtitle;

  const ConfettiCelebrationDialog({
    super.key,
    required this.title,
    required this.targetAmount,
    this.walletName,
    this.subtitle,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required double targetAmount,
    String? walletName,
    String? subtitle,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfettiCelebrationDialog(
        title: title,
        targetAmount: targetAmount,
        walletName: walletName,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<ConfettiCelebrationDialog> createState() =>
      _ConfettiCelebrationDialogState();
}

class _ConfettiCelebrationDialogState extends State<ConfettiCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    // Inisialisasi 65 partikel konfetti warna-warni khas Neo-Brutalist
    _particles = List.generate(65, (_) => _generateParticle());
  }

  _ConfettiParticle _generateParticle() {
    final colors = [
      AppColors.primaryYellow,
      AppColors.bubblePink,
      AppColors.mintGreen,
      AppColors.skyBlue,
      AppColors.lavenderPurple,
      const Color(0xFFF97316), // Orange
      const Color(0xFFE11D48), // Rose
      Colors.white,
    ];

    return _ConfettiParticle(
      color: colors[_random.nextInt(colors.length)],
      startX: _random.nextDouble(),
      startY: -0.1 - (_random.nextDouble() * 0.3),
      size: 7 + _random.nextDouble() * 8,
      speedX: (_random.nextDouble() - 0.5) * 0.6,
      speedY: 0.5 + _random.nextDouble() * 0.9,
      rotation: _random.nextDouble() * 2 * math.pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 8,
      isCircle: _random.nextBool(),
      swayFrequency: 2 + _random.nextDouble() * 4,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Kanvas Animasi Partikel Konfetti (Layar Penuh)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                    screenSize: media,
                  ),
                );
              },
            ),
          ),

          // 2. Kotak Modal Perayaan Neo-Brutalist
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF8A7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderBlack, width: 2.8),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  offset: Offset(4, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Maskot Kepiting Selebrasi dengan Frame Neo
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderBlack, width: 2.4),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        offset: Offset(2.5, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    AppAssets.mascotConfetti,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),

                // Badge Kemenangan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderBlack, width: 1.6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.textBlack),
                      SizedBox(width: 6),
                      Text(
                        '100% TARGET TERCAPAI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Judul Target
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Keterangan Nominal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBlack, width: 1.6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.subtitle ?? 'Tabungan kamu sudah genap tercapai:',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        CurrencyFormatter.formatRupiah(widget.targetAmount),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      if (widget.walletName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'di ${widget.walletName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol Aksi
                NeoButton(
                  label: 'Keren Banget! 🦀🎉',
                  backgroundColor: AppColors.primaryYellow,
                  textColor: AppColors.textBlack,
                  height: 46,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double size;
  final double speedX;
  final double speedY;
  final double rotation;
  final double rotationSpeed;
  final bool isCircle;
  final double swayFrequency;

  _ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
    required this.swayFrequency,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final Size screenSize;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.borderBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var p in particles) {
      final t = progress;
      // Gerakan jatuh vertikal dengan percepatan gravitasi halus
      final curY = (p.startY + (p.speedY * t * 1.5)) * size.height;
      // Goyangan horizontal (sway) dengan gelombang sinus
      final curX = (p.startX + (p.speedX * t * 0.3) + (math.sin(t * p.swayFrequency * math.pi) * 0.05)) * size.width;

      if (curY > size.height + 20) continue;

      final fillPaint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(p.rotation + (p.rotationSpeed * t));

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, fillPaint);
        canvas.drawCircle(Offset.zero, p.size / 2, borderPaint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.65,
        );
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
