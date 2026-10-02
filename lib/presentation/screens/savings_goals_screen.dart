import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/savings_goal_provider.dart';
import '../widgets/app_background_scaffold.dart';
import '../widgets/dialogs/add_funds_dialog.dart';
import '../widgets/dialogs/add_savings_goal_dialog.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';

/// Master menu untuk mengelola Pencapaian / Target Tabungan.
class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

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
    final goals = provider.goals;

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: NeoCard(
                backgroundColor: const Color(0xFFD4F8C4),
                borderRadius: 22,
                borderWidth: 2.2,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Terkumpul',
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: NeoButton(
                label: '+  Tambah Pencapaian',
                icon: Icons.add_rounded,
                backgroundColor: const Color(0xFFFFCCD8),
                textColor: AppColors.textBlack,
                height: 48,
                borderRadius: 24,
                onPressed: () => AddSavingsGoalDialog.show(context),
              ),
            ),

            // Daftar Pencapaian
            Expanded(
              child: goals.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: goals.length,
                      itemBuilder: (context, index) =>
                          _buildGoalCard(context, goals[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings_outlined,
              size: 72, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Belum ada pencapaian',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mulai buat target impianmu yuk!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoalModel goal) {
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
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  child: Icon(iconData, size: 22, color: AppColors.textBlack),
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
                      const SizedBox(height: 2),
                      Text(
                        '${CurrencyFormatter.formatShort(goal.savedAmount)} / ${CurrencyFormatter.formatShort(goal.targetAmount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
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
                // Aksi
                Column(
                  children: [
                    _buildIconAction(
                      icon: Icons.edit_rounded,
                      color: AppColors.butterYellow,
                      onTap: () => AddSavingsGoalDialog.show(
                        context,
                        existing: goal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildIconAction(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFFFE4E6),
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
                  widthFactor: goal.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: goal.isAchieved
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
                  goal.isAchieved ? '🎉 Tercapai!' : '${goal.progressPercent}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: goal.isAchieved
                        ? const Color(0xFF16A34A)
                        : AppColors.textBlack,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => AddFundsDialog.show(context, goal),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.borderBlack, width: 1.6),
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
                        Icon(Icons.add_rounded,
                            size: 14, color: AppColors.textBlack),
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
          ],
        ),
      ),
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
    );
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
