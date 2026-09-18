import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/neo_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.butterYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Top Title & Subtitle matching Showcase Screen 1
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.iconCoinRp,
                    width: 34,
                    height: 34,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mr Wallet',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Teman Atur Keuanganmu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),

              const Spacer(),

              // Speech Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(2.5, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'Atur Sekarang\nBahagia Nanti! ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crab Mascot with Sunglasses / Happy
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    AppAssets.mascotHappy,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
                      child: const Text(
                        'Financial\nFreedom Yuk! 🚀',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Primary CTA Button: "Mulai Sekarang ->" (Black Pill)
              NeoButton(
                label: 'Mulai Sekarang',
                trailingIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                backgroundColor: AppColors.textBlack,
                textColor: Colors.white,
                height: 54,
                borderRadius: 28,
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

              // Secondary CTA Button: "Masuk ke Akun" (Yellow)
              NeoButton(
                label: 'Masuk ke Akun',
                backgroundColor: AppColors.primaryYellow,
                textColor: AppColors.textBlack,
                height: 52,
                borderRadius: 28,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Page Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isActive = index == _activePage;
                  return GestureDetector(
                    onTap: () => setState(() => _activePage = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.textBlack : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderBlack, width: 1.5),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
