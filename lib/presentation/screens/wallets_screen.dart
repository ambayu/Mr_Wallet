import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/wallet_icon_helper.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/models/wallet_model.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_funds_dialog.dart';
import '../widgets/dialogs/add_savings_goal_dialog.dart';
import '../widgets/dialogs/add_wallet_dialog.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import 'savings_goals_screen.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final goalProv = Provider.of<SavingsGoalProvider>(context);
    final totalBalance = walletProv.totalBalance;
    final goals = goalProv.goals;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Clean Header: "Tabungan"
              const Text(
                'Tabungan',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Total Tabungan Green Card with Confetti Crab Mascot
              NeoCard(
                width: double.infinity,
                backgroundColor: const Color(0xFFD4F8C4),
                borderRadius: 24,
                borderWidth: 2.2,
                clipBehavior: false,
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
                    // Mascot Crab Celebration Confetti (tembus/nongol ke atas border card)
                    Positioned(
                      right: 4,
                      bottom: -8,
                      child: Image.asset(
                        AppAssets.mascotConfetti,
                        width: 135,
                        height: 135,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Dua Tombol Terpisah: Tambah Wadah Rekening & Kelola Pencapaian
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: '+ Wadah',
                      icon: Icons.account_balance_wallet_rounded,
                      backgroundColor: const Color(0xFFFFCCD8),
                      textColor: AppColors.textBlack,
                      height: 48,
                      borderRadius: 24,
                      onPressed: () => AddWalletDialog.show(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoButton(
                      label: 'Pencapaian',
                      icon: Icons.emoji_events_rounded,
                      backgroundColor: const Color(0xFFBCE7FE),
                      textColor: AppColors.textBlack,
                      height: 48,
                      borderRadius: 24,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavingsGoalsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Header Wadah Rekening
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wadah Rekening',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (walletProv.wallets.isNotEmpty)
                    Text(
                      '${walletProv.wallets.length} wadah',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Daftar Wadah Rekening
              if (walletProv.wallets.isEmpty)
                _buildEmptyWallets(context)
              else
                ...walletProv.wallets.map((wallet) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildWalletItem(context, wallet),
                    )),
              const SizedBox(height: 20),

              // 5. Header Pencapaian + Lihat Semua
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pencapaian',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (goals.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavingsGoalsScreen(),
                          ),
                        );
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

              // 6. Daftar Pencapaian (maks 3 teratas yang aktif)
              if (goalProv.activeGoals.isEmpty)
                _buildEmptyGoals(context)
              else
                ...goalProv.activeGoals.take(3).map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGoalItem(context, goal),
                    )),
              const SizedBox(height: 16),

              // 5. Mascot Tropical Vacation Card
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
    );
  }

  Widget _buildEmptyWallets(BuildContext context) {
    return NeoCard(
      backgroundColor: AppColors.cardWhite,
      borderRadius: 18,
      borderWidth: 1.8,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 28, color: AppColors.textMuted),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Belum ada wadah rekening. Yuk tambahkan!',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => AddWalletDialog.show(context),
            child: const Text(
              'Tambah',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem(BuildContext context, WalletModel wallet) {
    final iconData = WalletIconHelper.resolve(wallet.icon);

    return NeoCard(
      backgroundColor: AppColors.cardWhite,
      borderRadius: 18,
      borderWidth: 1.8,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WalletDetailScreen(wallet: wallet),
          ),
        );
      },
      child: Row(
        children: [
          // Ikon Wadah
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.fromHex(wallet.color),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 1.5),
            ),
            child: Icon(iconData, size: 22, color: AppColors.textBlack),
          ),
          const SizedBox(width: 12),

          // Nama Wadah
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    wallet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                if (wallet.isDefault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.borderBlack, width: 0.8),
                    ),
                    child: const Text(
                      'Utama',
                      style: TextStyle(
                          fontSize: 8.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Saldo & Panah
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatRupiah(wallet.balance),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 2),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoals(BuildContext context) {
    return NeoCard(
      backgroundColor: AppColors.cardWhite,
      borderRadius: 18,
      borderWidth: 1.8,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined,
              size: 28, color: AppColors.textMuted),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Belum ada pencapaian. Yuk buat target impianmu!',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
              );
            },
            child: const Text(
              'Buat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, SavingsGoalModel goal) {
    final iconData = _goalIconMap[goal.icon] ?? Icons.savings_rounded;

    return GestureDetector(
      onTap: () => _showGoalActionSheet(context, goal),
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
                  child: Icon(iconData, size: 20, color: AppColors.textBlack),
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
                          fontSize: 14,
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
                      height: 8,
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => AddFundsDialog.show(context, goal),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 15, color: AppColors.textBlack),
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
          ],
        ),
      ),
    );
  }

  void _showGoalActionSheet(BuildContext context, SavingsGoalModel goal) {
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
                      _confirmDeleteGoal(context, goal);
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

  Future<void> _confirmDeleteGoal(BuildContext context, SavingsGoalModel goal) async {
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
}
