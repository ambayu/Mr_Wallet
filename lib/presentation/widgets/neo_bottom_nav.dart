import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(
          top: BorderSide(color: AppColors.borderBlack, width: 1.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Beranda',
                activeColor: AppColors.primaryYellow,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Transaksi',
                activeColor: AppColors.bubblePink,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.pie_chart_outline_rounded,
                activeIcon: Icons.pie_chart_rounded,
                label: 'Insight',
                activeColor: AppColors.lavenderPurple,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.savings_outlined,
                activeIcon: Icons.savings_rounded,
                label: 'Tabungan',
                activeColor: AppColors.mintGreen,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                activeColor: AppColors.skyBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: AppColors.borderBlack, width: 1.5)
                    : null,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: AppColors.textBlack,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textBlack : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
