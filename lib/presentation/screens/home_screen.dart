import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/dialogs/ai_voice_modal.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/dialogs/camera_bill_snap_modal.dart';
import '../widgets/neo_card.dart';
import 'calendar_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAllTransactions;
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    required this.onSeeAllTransactions,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    final rawUser = authProv.currentUser?.username.trim() ?? '';
    String displayName = 'Andi';
    if (rawUser.isNotEmpty) {
      if (rawUser.contains('@')) {
        final prefix = rawUser.split('@').first;
        final parts = prefix.split(RegExp(r'[._]'));
        displayName = parts
            .where((p) => p.isNotEmpty)
            .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
            .join(' ');
      } else {
        displayName = rawUser;
      }
    }
    final totalBalance = walletProv.totalBalance;

    return Scaffold(
      backgroundColor: AppColors.bgOffWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await walletProv.loadWallets();
            await txProv.refreshTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header matching UI Showcase Screen 4
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $displayName! 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Saatnya buat hari ini lebih bermakna!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        // Calendar shortcut
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CalendarScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderBlack, width: 1.8),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                        // Notification Bell with unread badge
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationScreen(),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderBlack, width: 1.8),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  size: 22,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 4,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: AppColors.dangerRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar Crab Mascot
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 46,
                            height: 46,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderBlack, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowBlack,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppAssets.appIcon,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Total Saldo Card (Pastel Lavender + Crab Mascot Peeking)
                NeoCard(
                  width: double.infinity,
                  backgroundColor: AppColors.lavenderPurple,
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
                              'Total Saldo',
                              style: TextStyle(
                                fontSize: 13.5,
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
                            const SizedBox(height: 12),
                            // Badge: ↑ 12%
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderBlack, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.textBlack),
                                  SizedBox(width: 4),
                                  Text(
                                    '12%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mascot Crab
                      Image.asset(
                        AppAssets.mascotHappy,
                        width: 95,
                        height: 95,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. 4 Quick Action Buttons matching Showcase Screen 4
                // [+] Pengeluaran, [-] Pemasukan, [💳] Tabungan, [📷] Scan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(
                      context: context,
                      label: 'Pengeluaran',
                      icon: Icons.add_rounded,
                      bgColor: AppColors.mintGreen,
                      onTap: () => AddTransactionDialog.show(context, initialType: 'EXPENSE'),
                    ),
                    _buildQuickAction(
                      context: context,
                      label: 'Pemasukan',
                      icon: Icons.remove_rounded,
                      bgColor: AppColors.bubblePink,
                      onTap: () => AddTransactionDialog.show(context, initialType: 'INCOME'),
                    ),
                    _buildQuickAction(
                      context: context,
                      label: 'Tabungan',
                      icon: Icons.account_balance_wallet_outlined,
                      bgColor: AppColors.skyBlue,
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(3); // Go to Tabungan Tab
                        }
                      },
                    ),
                    _buildQuickAction(
                      context: context,
                      label: 'Scan',
                      icon: Icons.qr_code_scanner_rounded,
                      bgColor: AppColors.cardWhite,
                      onTap: () => CameraBillSnapModal.show(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Voice AI & Rekonsiliasi (Uang Hilang) Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        offset: Offset(2, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => AIVoiceModal.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 1.5),
                          ),
                          child: const Icon(Icons.mic_rounded, size: 20, color: AppColors.textBlack),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Voice AI & Uang Hilang',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Text(
                              'Bicara perintah atau samakan saldo riil dompet',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textBlack),
                        onPressed: () => BalanceAdjustmentDialog.show(context),
                        tooltip: 'Rekonsiliasi Saldo Riil',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Tujuan Keuangan Section matching Screen 4
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tujuan Keuangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(3); // Go to Tabungan
                        }
                      },
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Goal Card matching Showcase Screen 4
                NeoCard(
                  backgroundColor: AppColors.cardWhite,
                  borderRadius: 20,
                  borderWidth: 1.8,
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    if (onNavigateTab != null) {
                      onNavigateTab!(3);
                    }
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.bubblePink,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderBlack, width: 1.5),
                            ),
                            child: Center(
                              child: Image.asset(
                                AppAssets.iconRollingSuitcase,
                                width: 28,
                                height: 28,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.flight_takeoff_rounded,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Liburan ke Jepang',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Rp 8.000.000 / Rp 15.000.000',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '53%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.pillGray,
                            border: Border.all(color: AppColors.borderBlack, width: 1.2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.53,
                            child: Container(
                              color: AppColors.mintGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 6. "Ayo Nabung!" Banner Card matching Showcase Screen 4
                NeoCard(
                  backgroundColor: AppColors.butterYellow,
                  borderRadius: 22,
                  borderWidth: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAssets.mascotHappy,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Ayo Nabung!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Masa depan cerah mulai dari sekarang.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack,
                                height: 1.2,
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderBlack, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  offset: Offset(2, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 28, color: AppColors.textBlack),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
