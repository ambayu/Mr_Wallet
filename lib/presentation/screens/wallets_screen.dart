import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_wallet_dialog.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final totalBalance = walletProv.totalBalance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Clean Header: "Tabungan" & Settings / Reconcile Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tabungan',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                      letterSpacing: -0.6,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => BalanceAdjustmentDialog.show(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 2),
                      ),
                      child: const Icon(
                        Icons.donut_large_rounded,
                        size: 20,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Total Tabungan Green Card with Confetti Crab Mascot
              NeoCard(
                width: double.infinity,
                backgroundColor: const Color(0xFFD4F8C4),
                borderRadius: 24,
                borderWidth: 2.2,
                padding: const EdgeInsets.fromLTRB(18, 16, 0, 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Tabungan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatter.formatRupiah(totalBalance),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mascot Crab Celebration Confetti
                    Positioned(
                      right: 4,
                      bottom: -10,
                      child: Image.asset(
                        AppAssets.mascotConfetti,
                        width: 125,
                        height: 125,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. "+ Tambah Tabungan" Button (Pastel Pink)
              NeoButton(
                label: '+  Tambah Tabungan',
                backgroundColor: const Color(0xFFFFCCD8),
                textColor: AppColors.textBlack,
                height: 50,
                borderRadius: 26,
                onPressed: () => AddWalletDialog.show(context),
              ),
              const SizedBox(height: 20),

              // 3. Goals List (Japan, Laptop, Dana Darurat)
              _buildGoalItem(
                title: 'Liburan ke Jepang',
                saved: 'Rp 8.000.000',
                target: 'Rp 15.000.000',
                percentage: 0.53,
                iconAsset: AppAssets.iconRollingSuitcase,
                fallbackIcon: Icons.flight_takeoff_rounded,
                iconBg: const Color(0xFFD6F0FF),
              ),
              const SizedBox(height: 12),

              _buildGoalItem(
                title: 'Beli Laptop',
                saved: 'Rp 2.500.000',
                target: 'Rp 12.000.000',
                percentage: 0.21,
                iconAsset: AppAssets.iconLaptopDevice,
                fallbackIcon: Icons.laptop_mac_rounded,
                iconBg: const Color(0xFFD6F0FF),
              ),
              const SizedBox(height: 12),

              _buildGoalItem(
                title: 'Dana Darurat',
                saved: 'Rp 2.000.000',
                target: 'Rp 10.000.000',
                percentage: 0.20,
                iconAsset: AppAssets.iconPiggyBank,
                fallbackIcon: Icons.shield_rounded,
                iconBg: const Color(0xFFD6F0FF),
              ),
              const SizedBox(height: 18),

              // 4. Mascot Tropical Vacation Card
              NeoCard(
                backgroundColor: const Color(0xFFFFEB85),
                borderRadius: 24,
                borderWidth: 2.2,
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, right: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Sedikit demi sedikit,\nlama-lama jadi banyak!',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mascot Crab Tropical Vacation on Float
                    Positioned(
                      right: 0,
                      bottom: -15,
                      child: Image.asset(
                        AppAssets.mascotTropical,
                        width: 145,
                        height: 145,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem({
    required String title,
    required String saved,
    required String target,
    required double percentage,
    required String iconAsset,
    required IconData fallbackIcon,
    required Color iconBg,
  }) {
    final pctInt = (percentage * 100).toInt();

    return NeoCard(
      backgroundColor: AppColors.cardWhite,
      borderRadius: 18,
      borderWidth: 1.8,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
                ),
                child: Center(
                  child: Image.asset(
                    iconAsset,
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => Icon(
                      fallbackIcon,
                      size: 20,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$saved / $target',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$pctInt%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
