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
import '../widgets/dialogs/add_savings_goal_dialog.dart';
import '../widgets/dialogs/ai_text_modal.dart';
import '../widgets/dialogs/camera_bill_snap_modal.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';

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
                // 1. Clean Top Header: Halo, [Name]! + Subtitle & Avatar on Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $displayName!',
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

                // 3. Quick Action Buttons: [Tabung], [Target Tabungan], [Jadwal Task], [Scan Struk]
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      label: 'Target',
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
                      label: 'Jadwal Task',
                      icon: Icons.calendar_month_rounded,
                      bgColor: const Color(0xFFFFE082), // Amber Pastel
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TasksScreen()),
                        );
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
                const SizedBox(height: 16),

                // AI Quick Input Prompt Bar (Ketik Bebas / Foto Struk)
                GestureDetector(
                  onTap: () => AITextModal.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(24),
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
                        const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Untuk apa dan berapa harganya? (Ketik bebas / AI)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => CameraBillSnapModal.show(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.butterYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderBlack, width: 1.4),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.textBlack),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Section: "Tujuan Keuangan" & Mascot Banner (Langsung di Body Latar Belakang)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tujuan Keuangan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                        letterSpacing: -0.3,
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

                // Goal Card Items (Maksimal 3 Pencapaian Aktif Teratas)
                if (goalProv.activeGoals.isNotEmpty) ...[
                  ...goalProv.activeGoals.take(3).map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTopGoalCard(context, goal),
                      )),
                ] else
                  _buildGoalEmptyState(context),
                const SizedBox(height: 16),

                // Mascot Tropical Vacation Banner Card (Sesuai Gambar 2)
                NeoCard(
                  width: double.infinity,
                  backgroundColor: const Color(0xFFFFEB85),
                  borderRadius: 24,
                  borderWidth: 2.2,
                  clipBehavior: false,
                  padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
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
                      // Mascot Crab Tropical Vacation on Float (tembus/nongol ke luar card)
                      Positioned(
                        right: -8,
                        bottom: -28,
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

    return GestureDetector(
      onTap: () => _showHomeGoalActionSheet(context, goal),
      child: NeoCard(
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
                    color: AppColors.fromHex(goal.color),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(iconData, size: 20, color: AppColors.textBlack),
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
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderBlack, width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_balance_wallet_rounded, size: 12, color: AppColors.textBlack),
                                const SizedBox(width: 4.5),
                                Text(
                                  goal.walletName ?? 'Dompet Utama',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: CurrencyFormatter.formatShort(goal.effectiveSavedAmount),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' / ',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  TextSpan(
                                    text: CurrencyFormatter.formatShort(goal.targetAmount),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar & Persentase Sebaris (Loading dari kiri ke kanan)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: goal.progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${goal.progressPercent}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHomeGoalActionSheet(BuildContext context, SavingsGoalModel goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.borderBlack, width: 2.5),
            left: BorderSide(color: AppColors.borderBlack, width: 2.5),
            right: BorderSide(color: AppColors.borderBlack, width: 2.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderBlack.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              goal.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${CurrencyFormatter.formatRupiah(goal.effectiveSavedAmount)} / ${CurrencyFormatter.formatRupiah(goal.targetAmount)} (${goal.progressPercent}%)',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    backgroundColor: AppColors.butterYellow,
                    textColor: AppColors.textBlack,
                    onPressed: () {
                      Navigator.pop(ctx);
                      AddSavingsGoalDialog.show(context, existing: goal);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    label: 'Hapus',
                    icon: Icons.delete_outline_rounded,
                    backgroundColor: const Color(0xFFFFE4E6),
                    textColor: AppColors.dangerRed,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteHomeGoal(context, goal);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Future<void> _confirmDeleteHomeGoal(BuildContext context, SavingsGoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.butterYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
        ),
        title: const Text(
          'Hapus Pencapaian?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Text('"${goal.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<SavingsGoalProvider>(context, listen: false).deleteGoal(goal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencapaian berhasil dihapus'),
            backgroundColor: AppColors.textBlack,
          ),
        );
      }
    }
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
