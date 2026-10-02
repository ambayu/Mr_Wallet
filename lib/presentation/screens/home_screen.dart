import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/auth_provider.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/camera_bill_snap_modal.dart';
import '../widgets/neo_card.dart';
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
    final goalProv = Provider.of<SavingsGoalProvider>(context);

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
      backgroundColor: const Color(0xFFFEF8A7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await walletProv.loadWallets();
            await txProv.refreshTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Clean Top Header: Halo, [Name]! 👋 + Subtitle & Avatar on Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $displayName! 👋',
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                              letterSpacing: -0.8,
                              shadows: [
                                Shadow(
                                  color: AppColors.textBlack,
                                  offset: Offset(0.35, 0.35),
                                  blurRadius: 0,
                                ),
                                Shadow(
                                  color: AppColors.textBlack,
                                  offset: Offset(-0.35, -0.35),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Saatnya buat hari ini lebih bermakna!',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textBlack,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlack, width: 2.2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowBlack,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.mascotLogin,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Total Saldo Card (Pastel Lavender + Mascot Peeking + 12% Badge)
                NeoCard(
                  width: double.infinity,
                  backgroundColor: const Color(0xFFE8DEFF),
                  borderRadius: 24,
                  borderWidth: 2.2,
                  padding: const EdgeInsets.fromLTRB(18, 16, 0, 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Saldo',
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textBlack,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Real Growth Percentage Badge: ↑ X% ↗
                            Builder(
                              builder: (context) {
                                final growth = txProv.monthlyGrowthPercentage;
                                final isPositive = growth >= 0;
                                final growthText = '${growth.abs().toStringAsFixed(0)}%';

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isPositive
                                        ? const Color(0xFFBAF5A8)
                                        : const Color(0xFFFFCCD8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.borderBlack, width: 1.6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        size: 14,
                                        color: AppColors.textBlack,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        growthText,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        isPositive
                                            ? Icons.call_made_rounded
                                            : Icons.call_received_rounded,
                                        size: 13,
                                        color: AppColors.textBlack,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Mascot Crab Half Body Basic rapat lengket ke sisi kanan dan bawah border
                      Positioned(
                        right: 8,
                        bottom: -32,
                        child: Image.asset(
                          AppAssets.mascotHalfBody,
                          width: 145,
                          height: 145,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Quick Action Buttons: [Tabung (Riwayat & Catat)], [Target Tabungan], [Scan Struk]
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Utama "Tabung": Pindah langsung ke Halaman Riwayat Transaksi Bulanan
                    _buildQuickAction(
                      context: context,
                      label: 'Tabung',
                      icon: Icons.savings_rounded,
                      bgColor: const Color(0xFFC8F8B8), // Mint Green Pastel Neo-Brutalist
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(1); // Go to Transaction History Tab (Riwayat & Pencatatan)
                        } else {
                          onSeeAllTransactions();
                        }
                      },
                    ),
                    _buildQuickAction(
                      context: context,
                      label: 'Target Tabungan',
                      icon: Icons.business_center_rounded,
                      bgColor: const Color(0xFFBCE7FE), // Sky Blue Pastel
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(3); // Go to Tabungan Goals Tab
                        }
                      },
                    ),
                    _buildQuickAction(
                      context: context,
                      label: 'Scan Struk',
                      icon: Icons.qr_code_scanner_rounded,
                      bgColor: const Color(0xFFFFCCD8), // Bubble Pink Pastel
                      onTap: () => CameraBillSnapModal.show(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. White Bottom Card Section: "Tujuan Keuangan" & "Ayo Nabung!"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        offset: Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Tujuan Keuangan + Lihat Semua
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tujuan Keuangan',
                            style: TextStyle(
                              fontSize: 17,
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
                      const SizedBox(height: 14),

                      // Goal Card Item (Pencapaian Teratas)
                      if (goalProv.goals.isNotEmpty)
                        _buildTopGoalCard(context, goalProv.goals.first)
                      else
                        _buildGoalEmptyState(context),
                      const SizedBox(height: 16),

                      // "Ayo Nabung!" Yellow Mascot Banner Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEB85),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.borderBlack, width: 2),
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
                            Image.asset(
                              AppAssets.mascotLogin,
                              width: 65,
                              height: 65,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
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
                                  SizedBox(height: 3),
                                  Text(
                                    'Masa depan cerah\nmulai dari sekarang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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

  static const Map<String, IconData> _goalIconMap = {
    'savings': Icons.savings_rounded,
    'flight_takeoff': Icons.flight_takeoff_rounded,
    'laptop_mac': Icons.laptop_mac_rounded,
    'shield': Icons.shield_rounded,
    'home': Icons.home_rounded,
    'directions_car': Icons.directions_car_rounded,
    'school': Icons.school_rounded,
    'favorite': Icons.favorite_rounded,
    'celebration': Icons.celebration_rounded,
    'watch': Icons.watch_rounded,
  };

  Widget _buildTopGoalCard(BuildContext context, SavingsGoalModel goal) {
    final iconData = _goalIconMap[goal.icon] ?? Icons.savings_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.fromHex(goal.color),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.borderBlack, width: 1.5),
                ),
                child: Center(
                  child: Icon(iconData,
                      size: 24, color: AppColors.textBlack),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${CurrencyFormatter.formatShort(goal.savedAmount)} / ${CurrencyFormatter.formatShort(goal.targetAmount)}',
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
                '${goal.progressPercent}%',
                style: const TextStyle(
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
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined,
              size: 28, color: AppColors.textMuted),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Belum ada tujuan keuangan. Buat di halaman Tabungan yuk!',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
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
