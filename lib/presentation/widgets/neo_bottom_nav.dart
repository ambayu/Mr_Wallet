import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onSmartAITap;

  const NeoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onSmartAITap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.borderBlack,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
            activeColor: AppColors.butterYellow,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.bar_chart_rounded,
            label: 'Track',
            activeColor: AppColors.mintGreen,
          ),
          _buildAIFabItem(),
          _buildNavItem(
            index: 2,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Wallets',
            activeColor: AppColors.skyBlue,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.flag_rounded,
            label: 'Goals',
            activeColor: AppColors.bubblePink,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppColors.borderBlack, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textBlack : Colors.white70,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAIFabItem() {
    return GestureDetector(
      onTap: onSmartAITap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.lavenderPurple,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderBlack, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.white24,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: AppColors.textBlack,
          size: 22,
        ),
      ),
    );
  }
}
