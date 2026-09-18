import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
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
      backgroundColor: const Color(0xFFFEF8A7),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full Screen Wallpaper Background (Adaptive Portrait / Landscape)
              Image.asset(
                isLandscape
                    ? AppAssets.landingPageLandscape
                    : AppAssets.landingPage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: isLandscape ? Alignment.center : Alignment.topCenter,
              ),

              // 2. Interactive CTA Actions & Indicators
              SafeArea(
                child: isLandscape
                    ? _buildLandscapeLayout(context)
                    : _buildPortraitLayout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  // Portrait: Buttons & Dots centered at bottom
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrimaryButton(context),
              const SizedBox(height: 12),
              _buildSecondaryButton(context),
              const SizedBox(height: 18),
              _buildDotsIndicator(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // Landscape: Buttons positioned on the left side under the description text
  Widget _buildLandscapeLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Left content area matching the description & title column
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _buildPrimaryButton(context, height: 48)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSecondaryButton(context, height: 48)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDotsIndicator(),
                  ],
                ),
              ),
            ),
            // Right area (reserved for crab mascot and piggy bank artwork)
            const Expanded(
              flex: 5,
              child: SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {double height = 56}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterScreen(),
          ),
        );
      },
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF1E1E24),
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mulai Sekarang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {double height = 54}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      },
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEB7D),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF1E1E24),
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1E1E24),
              offset: Offset(2, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Masuk ke Akun',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _activePage;
        return GestureDetector(
          onTap: () => setState(() => _activePage = index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF1E1E24)
                  : const Color(0xFFFFD54F),
            ),
          ),
        );
      }),
    );
  }
}





