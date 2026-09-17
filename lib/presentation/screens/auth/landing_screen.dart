import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/mascot_art.dart';
import '../../widgets/neo_badge.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderPurple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Brand Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'SmartFlow',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textBlack,
                        ),
                        child: const Text(
                          '™',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const NeoBadge(
                    text: 'SAVE • SPEND • GROW',
                    backgroundColor: AppColors.mintGreen,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Floating Stickers Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Transform.rotate(
                    angle: -0.08,
                    child: const NeoBadge(
                      text: 'SMALL STEPS\nBIGGER TOMORROWS',
                      backgroundColor: AppColors.butterYellow,
                      fontSize: 10,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.08,
                    child: const NeoBadge(
                      text: 'LOCAL-FIRST\nAI POWERED ⚡',
                      backgroundColor: AppColors.bubblePink,
                      fontSize: 10,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero Centerpiece Card
              NeoCard(
                backgroundColor: AppColors.butterYellow,
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      'Pencatatan Keuangan Digital\nTanpa Ribet & Presisi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Big Cool Crab Mascot
                    const Center(
                      child: CrabMascotWidget(
                        mood: MascotMood.coolSkater,
                        size: 150,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Kelola dompet tunai, ATM, e-wallet, deteksi uang hilang, scan struk, dan perintahkan AI dalam satu aplikasi santai.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 Value Pillars
              _buildFeatureTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Multi-Account & Deteksi Uang Hilang',
                subtitle: 'Hitung selisih saku & saldo riil otomatis (Δ = Saldo Riil - Sistem).',
                color: AppColors.mintGreen,
              ),
              const SizedBox(height: 10),
              _buildFeatureTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Voice AI & Camera Bill Snap',
                subtitle: 'Bicara perintah majemuk & foto struk kasir tanpa ketik manual.',
                color: AppColors.bubblePink,
              ),
              const SizedBox(height: 10),
              _buildFeatureTile(
                icon: Icons.alarm_on_rounded,
                title: 'Task Scheduler & Financial Binding',
                subtitle: 'Pengingat jadwal pembayaran dengan alarm lokal deterministik.',
                color: AppColors.skyBlue,
              ),
              const SizedBox(height: 26),

              // CTA Action Buttons
              NeoButton(
                label: 'Mulai Sekarang — Gratis!',
                icon: Icons.rocket_launch_rounded,
                backgroundColor: AppColors.mintGreen,
                height: 56,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                label: 'Sudah Punya Akun? Masuk',
                icon: Icons.login_rounded,
                backgroundColor: AppColors.cardWhite,
                textColor: AppColors.textBlack,
                height: 54,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return NeoCard(
      backgroundColor: AppColors.cardWhite,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 2),
            ),
            child: Icon(icon, color: AppColors.textBlack, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
