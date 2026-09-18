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
import '../widgets/neo_header_card.dart';
import 'transaction_history_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final totalBalance = walletProv.totalBalance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NeoHeaderCard(
        title: 'Tabungan & Dompet',
        subtitle: 'Atur pos & wadah finansial',
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textBlack),
            onPressed: () => BalanceAdjustmentDialog.show(context),
            tooltip: 'Rekonsiliasi Saldo Riil',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textBlack),
            onPressed: () => AddWalletDialog.show(context),
            tooltip: 'Tambah Wadah Tabungan',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Total Tabungan Green Banner Card matching Showcase Screen 7
              NeoCard(
                width: double.infinity,
                backgroundColor: AppColors.mintGreen,
                borderRadius: 24,
                borderWidth: 2,
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Tabungan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderBlack, width: 1.5),
                            ),
                            child: const Text(
                              'Akumulasi Saldo Aman 🛡️',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      AppAssets.mascotGrowthChart,
                      width: 95,
                      height: 95,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. "+ Tambah Tabungan" Button (Pastel Pink) matching Screen 7
              NeoButton(
                label: '+ Tambah Tabungan',
                backgroundColor: AppColors.bubblePink,
                textColor: AppColors.textBlack,
                height: 48,
                borderRadius: 24,
                onPressed: () => AddWalletDialog.show(context),
              ),
              const SizedBox(height: 24),

              // 3. Goal List matching Showcase Screen 7
              const Text(
                'Target & Impian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),

              _buildGoalItem(
                title: 'Liburan ke Jepang',
                saved: 'Rp 8.000.000',
                target: 'Rp 15.000.000',
                percentage: 0.53,
                iconAsset: AppAssets.iconRollingSuitcase,
                fallbackIcon: Icons.flight_takeoff_rounded,
                iconBg: AppColors.bubblePink,
              ),
              const SizedBox(height: 10),

              _buildGoalItem(
                title: 'Beli Laptop',
                saved: 'Rp 2.500.000',
                target: 'Rp 12.000.000',
                percentage: 0.21,
                iconAsset: AppAssets.iconLaptopDevice,
                fallbackIcon: Icons.laptop_mac_rounded,
                iconBg: AppColors.skyBlue,
              ),
              const SizedBox(height: 10),

              _buildGoalItem(
                title: 'Dana Darurat',
                saved: 'Rp 2.000.000',
                target: 'Rp 10.000.000',
                percentage: 0.20,
                iconAsset: AppAssets.iconPiggyBank,
                fallbackIcon: Icons.shield_rounded,
                iconBg: AppColors.primaryYellow,
              ),
              const SizedBox(height: 24),

              // 4. Rekening & Wadah Saldo Section (Cash, ATM, E-Wallet)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wadah Rekening Aktif',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => BalanceAdjustmentDialog.show(context),
                    child: const Text(
                      'Cek Selisih Saku',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...walletProv.wallets.map((w) {
                return NeoCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  backgroundColor: AppColors.cardWhite,
                  borderRadius: 18,
                  borderWidth: 1.8,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionHistoryScreen(
                          initialWalletFilter: w.id,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getWalletColor(w.type),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderBlack, width: 1.6),
                        ),
                        child: Icon(
                          _getWalletIcon(w.type),
                          size: 22,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Text(
                              w.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(w.balance),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // 5. Mascot Quote Banner matching Showcase Screen 7
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(2.5, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.mascotTravel,
                      width: 68,
                      height: 68,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sedikit demi sedikit, lama-lama jadi banyak! 🦀💰',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          height: 1.25,
                        ),
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
                color: AppColors.pillGray,
                border: Border.all(color: AppColors.borderBlack, width: 1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  color: AppColors.mintGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWalletColor(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return AppColors.mintGreen;
      case 'bank':
        return AppColors.skyBlue;
      case 'ewallet':
        return AppColors.bubblePink;
      default:
        return AppColors.lavenderPurple;
    }
  }

  IconData _getWalletIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'ewallet':
        return Icons.phone_android_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
}
