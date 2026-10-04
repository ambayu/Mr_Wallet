import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/app_background_scaffold.dart';
import '../widgets/dialogs/add_funds_dialog.dart';
import '../widgets/dialogs/add_savings_goal_dialog.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';

/// Master menu untuk mengelola Pencapaian / Target Tabungan.
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const Map<String, IconData> _iconMap = {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SavingsGoalProvider>(context);
    final activeGoals = provider.activeGoals;
    final completedGoals = provider.completedGoals;

    final overallProgress =
        provider.totalTarget > 0 ? provider.totalSaved / provider.totalTarget : 0.0;

    return AppBackgroundScaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: AppColors.butterYellow,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderBlack, width: 2.2),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    size: 18, color: AppColors.textBlack),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kelola Pencapaian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ringkasan Total
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: NeoCard(
                backgroundColor: const Color(0xFFD4F8C4),
                borderRadius: 22,
                borderWidth: 2.2,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Terkumpul (Aktif)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${CurrencyFormatter.formatRupiah(provider.totalSaved)} / ${CurrencyFormatter.formatRupiah(provider.totalTarget)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.borderBlack, width: 1.4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: overallProgress.clamp(0.0, 1.0),
                          child: Container(color: const Color(0xFF10B981)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Tambah Pencapaian
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: NeoButton(
                label: '+  Tambah Pencapaian',
                icon: Icons.add_rounded,
                backgroundColor: const Color(0xFFFFCCD8),
                textColor: AppColors.textBlack,
                height: 46,
                borderRadius: 24,
                onPressed: () => AddSavingsGoalDialog.show(context),
              ),
            ),

            // Tab Bar [Aktif] [Selesai]
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderBlack, width: 1.8),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textBlack,
                indicatorWeight: 3,
                labelColor: AppColors.textBlack,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: 'Aktif (${activeGoals.length})'),
                  Tab(text: 'Selesai (${completedGoals.length})'),
                ],
              ),
            ),

            // Daftar Pencapaian (TabBarView)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Aktif
                  activeGoals.isEmpty
                      ? _buildEmptyState(context, isCompletedTab: false)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          itemCount: activeGoals.length,
                          itemBuilder: (context, index) =>
                              _buildGoalCard(context, activeGoals[index], isCompleted: false),
                        ),

                  // Tab 2: Selesai
                  completedGoals.isEmpty
                      ? _buildEmptyState(context, isCompletedTab: true)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          itemCount: completedGoals.length,
                          itemBuilder: (context, index) =>
                              _buildGoalCard(context, completedGoals[index], isCompleted: true),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isCompletedTab}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompletedTab ? Icons.emoji_events_outlined : Icons.savings_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            isCompletedTab ? 'Belum ada target yang diselesaikan' : 'Belum ada pencapaian aktif',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCompletedTab
                ? 'Selesaikan target tabunganmu dan rayakan di sini! 🎉'
                : 'Mulai buat target impianmu sekarang yuk!',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoalModel goal, {required bool isCompleted}) {
    final iconData = _iconMap[goal.icon] ?? Icons.savings_rounded;
    final cardColor = AppColors.fromHex(goal.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFFDCFCE7) : cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  child: Icon(
                    isCompleted ? Icons.emoji_events_rounded : iconData,
                    size: 22,
                    color: isCompleted ? const Color(0xFF16A34A) : AppColors.textBlack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderBlack, width: 0.8),
                              ),
                              child: const Text(
                                'Tercapai 🎉',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (goal.walletName != null) ...[
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
                                    goal.walletName!,
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
                          ],
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
                      if (goal.deadline != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.event_rounded,
                                size: 11, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              DateFormat('d MMM yyyy', 'id_ID')
                                  .format(goal.deadline!),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Aksi Edit & Hapus
                Column(
                  children: [
                    _buildIconAction(
                      icon: Icons.edit_rounded,
                      color: AppColors.butterYellow,
                      tooltip: 'Edit Pencapaian',
                      onTap: () => AddSavingsGoalDialog.show(
                        context,
                        existing: goal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildIconAction(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFFFE4E6),
                      tooltip: 'Hapus Pencapaian',
                      onTap: () => _confirmDelete(context, goal),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: isCompleted ? 1.0 : goal.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted || goal.isAchieved
                          ? const Color(0xFF10B981)
                          : AppColors.textBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Text(
                  isCompleted ? '🎉 Sudah Selesai' : '${goal.progressPercent}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isCompleted || goal.isAchieved
                        ? const Color(0xFF16A34A)
                        : AppColors.textBlack,
                  ),
                ),
                const Spacer(),

                // Tombol Toggle Selesai / Tambah Dana
                if (!isCompleted) ...[
                  // Tombol Cepat Tandai Selesai
                  GestureDetector(
                    onTap: () => _handleToggleComplete(context, goal),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderBlack, width: 1.4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text(
                            'Selesai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AddFundsDialog.show(context, goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderBlack, width: 1.6),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: AppColors.textBlack),
                          SizedBox(width: 4),
                          Text(
                            'Tambah Dana',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Tombol Buka Kembali
                  GestureDetector(
                    onTap: () => _handleToggleComplete(context, goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderBlack, width: 1.4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.replay_rounded, size: 14, color: AppColors.textBlack),
                          SizedBox(width: 4),
                          Text(
                            'Aktifkan Kembali',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderBlack, width: 1.5),
          ),
          child: Icon(icon, size: 16, color: AppColors.textBlack),
        ),
      ),
    );
  }

  Future<void> _handleToggleComplete(BuildContext context, SavingsGoalModel goal) async {
    final prov = Provider.of<SavingsGoalProvider>(context, listen: false);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);

    if (goal.isCompleted) {
      // Revert status
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.butterYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
          ),
          title: const Text('Aktifkan Kembali Target?', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('Saldo yang telah dipotong akan dikembalikan ke dompet dan target kembali aktif.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Aktifkan', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBlack)),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await prov.revertGoalCompletion(goal);
        await walletProv.loadWallets();
        await txProv.refreshTransactions();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Target "${goal.name}" diaktifkan kembali dan saldo dikembalikan.')),
          );
        }
      }
      return;
    }

    // Eksekusi Penyelesaian Target dengan Validasi Saldo & Selebrasi Pop-up
    String targetWalletId = goal.walletId ??
        (walletProv.wallets.isNotEmpty
            ? walletProv.wallets.firstWhere((w) => w.isDefault, orElse: () => walletProv.wallets.first).id
            : 'w_cash');

    final targetWallet = walletProv.wallets.firstWhere(
      (w) => w.id == targetWalletId,
      orElse: () => walletProv.wallets.first,
    );

    final requiredAmount = goal.targetAmount;
    final currentBalance = targetWallet.balance;

    // 1. Validasi saldo tidak cukup
    if (currentBalance < requiredAmount) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.butterYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 28),
              SizedBox(width: 8),
              Text('Tabungan Belum Cukup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          content: Text(
            'Kamu tidak bisa menyelesaikan target ini karena tabungan di ${targetWallet.name} belum cukup.\n\n'
            'Dibutuhkan: ${CurrencyFormatter.formatRupiah(requiredAmount)}\n'
            'Saldo ${targetWallet.name}: ${CurrencyFormatter.formatRupiah(currentBalance)}\n'
            'Kurang: ${CurrencyFormatter.formatRupiah(requiredAmount - currentBalance)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBlack)),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Pop-up Selamat / Selebrasi Mr. Wallet (Mascot Kepiting)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF8A7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowBlack,
                offset: Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Maskot Kepiting Selebrasi
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.mintGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.shadowBlack, offset: Offset(2, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  AppAssets.mascotLogin,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '🎉 SELAMAT! TARGET TERCAPAI! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Impian "${goal.name}" berhasil kamu capai! Saldo ${targetWallet.name} akan dipotong sebesar ${CurrencyFormatter.formatRupiah(requiredAmount)} untuk realisasi pembelian.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderBlack, width: 1.8),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.mintGreen,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderBlack, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowBlack,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Ya, Realisasikan! 🛍️',
                          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBlack),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await prov.completeGoalWithFinancialAction(
        goal: goal,
        walletId: targetWalletId,
      );
      if (success) {
        await walletProv.loadWallets();
        await txProv.refreshTransactions();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat! Target "${goal.name}" berhasil direalisasikan! 🎉🛍️'),
              backgroundColor: AppColors.textBlack,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, SavingsGoalModel goal) async {
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
            child: const Text('Batal',
                style: TextStyle(
                    color: AppColors.textBlack, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(
                    color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<SavingsGoalProvider>(context, listen: false)
          .deleteGoal(goal.id);
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
}
