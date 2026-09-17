import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/edit_goal_dialog.dart';
import '../widgets/mascot_art.dart';
import '../widgets/neo_badge.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  double _savingsGoal = 10000000.0;
  String _statusFilter = 'ALL'; // ALL, PENDING, COMPLETED
  final String _priorityFilter = 'ALL'; // ALL, HIGH, MEDIUM, LOW

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savingsGoal = prefs.getDouble('savings_goal_target') ?? 10000000.0;
    });
  }

  List<TaskModel> _filterTasks(List<TaskModel> all) {
    return all.where((t) {
      if (_statusFilter == 'PENDING' && t.isCompleted) return false;
      if (_statusFilter == 'COMPLETED' && !t.isCompleted) return false;
      if (_priorityFilter != 'ALL' && t.priority != _priorityFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);

    final totalBalance = walletProv.totalBalance;
    final progress = _savingsGoal > 0 ? (totalBalance / _savingsGoal).clamp(0.0, 1.0) : 0.0;
    final progressPct = (progress * 100).toInt();

    final filteredTasks = _filterTasks(taskProv.tasks);

    return Scaffold(
      backgroundColor: AppColors.bubblePink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Financial Success',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AddTaskDialog.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.butterYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 2.2),
                      ),
                      child: const Icon(Icons.add, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Main Title Banner: "Big Goals Brighter Days"
              const Text(
                'Big Goals\nBrighter Days',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Save today. A happier you tomorrow.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Mascot Skater Hero Card (Matching 3rd Screen Mockup)
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FINANCIAL\nFREEDOM\nAHEAD! 🚀',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const CrabMascotWidget(
                          mood: MascotMood.coolSkater,
                          size: 110,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Goal Target Progress Bar
                    GestureDetector(
                      onTap: () async {
                        final newGoal = await EditGoalDialog.show(context, _savingsGoal);
                        if (newGoal != null) {
                          setState(() => _savingsGoal = newGoal);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.butterYellow,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.borderBlack, width: 2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.track_changes_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Target: ${CurrencyFormatter.formatShort(_savingsGoal)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$progressPct%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 14, color: AppColors.textMuted),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Custom Neo Progress Bar
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.borderBlack, width: 2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E), // Bright Green
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. "Keep Going!" Action Pill Button (Matching Mockup)
              NeoButton(
                label: 'Keep Going!  ➔',
                backgroundColor: AppColors.borderBlack,
                textColor: Colors.white,
                height: 56,
                onPressed: () => AddTaskDialog.show(context),
              ),
              const SizedBox(height: 20),

              // 5. Scheduled Tasks Header & Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agenda & Alarm Tugas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  NeoBadge(
                    text: '${taskProv.pendingTasks.length} Aktif',
                    backgroundColor: AppColors.cardWhite,
                    fontSize: 11,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterBadge('ALL', 'Semua Agenda'),
                    const SizedBox(width: 8),
                    _buildFilterBadge('PENDING', 'Belum Selesai'),
                    const SizedBox(width: 8),
                    _buildFilterBadge('COMPLETED', 'Sudah Selesai'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (filteredTasks.isEmpty) ...[
                const NeoCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Tidak ada jadwal yang sesuai filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ...filteredTasks.map((task) {
                  return _buildTaskCard(task, taskProv);
                }),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBadge(String key, String label) {
    final isSel = _statusFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = key),
      child: NeoBadge(
        text: label,
        backgroundColor: isSel ? AppColors.butterYellow : AppColors.cardWhite,
        borderWidth: isSel ? 2.5 : 1.5,
      ),
    );
  }

  Widget _buildTaskCard(dynamic task, TaskProvider taskProv) {
    final isCompleted = task.isCompleted;

    Color priorityColor = AppColors.butterYellow;
    if (task.priority == 'HIGH') priorityColor = AppColors.coralOrange;
    if (task.priority == 'LOW') priorityColor = AppColors.mintGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        backgroundColor: isCompleted ? AppColors.pillGray : AppColors.cardWhite,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => taskProv.toggleTaskStatus(task),
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF22C55E)
                      : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? AppColors.textMuted
                          : AppColors.textBlack,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Metadata Badges (Due Date, Priority, Financial Binding)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      NeoBadge(
                        text: DateFormatter.formatRelative(task.dueDate),
                        icon: Icons.alarm,
                        backgroundColor: AppColors.butterYellow,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                      ),
                      NeoBadge(
                        text: task.priority,
                        backgroundColor: priorityColor,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                      ),
                      if (task.estimatedAmount != null) ...[
                        NeoBadge(
                          text: CurrencyFormatter.format(task.estimatedAmount!),
                          icon: Icons.monetization_on_outlined,
                          backgroundColor: AppColors.mintGreen,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Delete Task Button
            GestureDetector(
              onTap: () => taskProv.deleteTask(task.id),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
