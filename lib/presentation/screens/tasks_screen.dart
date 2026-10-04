import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/app_background_scaffold.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/neo_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter Periode Global untuk Semua Tab (Tagihan, Gaji, Laporan)
  DateTime _selectedDate = DateTime.now();
  String _selectedReportType = 'ALL'; // 'ALL', 'EXPENSE', 'INCOME'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showMonthYearPicker() async {
    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _TaskMonthYearPickerDialog(initialDate: _selectedDate),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _handleExecuteTask(TaskModel task) async {
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    // Dompet acuan task atau dompet default
    String targetWalletId = task.walletId ??
        (walletProv.wallets.isNotEmpty
            ? walletProv.wallets.firstWhere((w) => w.isDefault, orElse: () => walletProv.wallets.first).id
            : 'w_cash');

    final targetWallet = walletProv.wallets.firstWhere(
      (w) => w.id == targetWalletId,
      orElse: () => walletProv.wallets.first,
    );

    final amount = task.estimatedAmount ?? 0.0;
    final isIncome = task.isIncome;

    // Tampilkan Bottom Sheet Konfirmasi Cepat Eksekusi
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String selectedId = targetWalletId;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.butterYellow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(color: AppColors.borderBlack, width: 2.5),
                  left: BorderSide(color: AppColors.borderBlack, width: 2.5),
                  right: BorderSide(color: AppColors.borderBlack, width: 2.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderBlack.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isIncome ? AppColors.mintGreen : AppColors.bubblePink,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 1.8),
                          ),
                          child: Icon(
                            isIncome ? Icons.monetization_on_rounded : Icons.receipt_long_rounded,
                            color: AppColors.textBlack,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isIncome ? 'Konfirmasi Penerimaan Gaji' : 'Konfirmasi Pembayaran Tagihan',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rincian Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isIncome ? 'Total Masuk:' : 'Total Dipotong:',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                CurrencyFormatter.formatRupiah(amount),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: AppColors.borderBlack),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isIncome ? 'Rekening Tujuan:' : 'Rekening Sumber:',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedId,
                                  isDense: true,
                                  items: walletProv.wallets.map((w) {
                                    return DropdownMenuItem(
                                      value: w.id,
                                      child: Text(
                                        '${w.name} (${CurrencyFormatter.formatShort(w.balance)})',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setSheetState(() => selectedId = v);
                                      targetWalletId = v;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx, false),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderBlack, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx, true),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: isIncome ? AppColors.mintGreen : AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderBlack, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowBlack,
                                    offset: Offset(2, 2.5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isIncome ? 'Ya, Cairkan Gaji! 💰' : 'Ya, Bayar Sekarang! 💸',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBlack),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      final txProv = Provider.of<TransactionProvider>(context, listen: false);
      await taskProv.completeTaskWithFinancialAction(
        task: task,
        walletId: targetWalletId,
      );
      if (!mounted) return;
      await walletProv.loadWallets();
      await txProv.refreshTransactions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIncome
                  ? 'Gaji Rp ${CurrencyFormatter.formatShort(amount)} berhasil masuk ke ${targetWallet.name}! 🎉'
                  : 'Tagihan Rp ${CurrencyFormatter.formatShort(amount)} berhasil dipotong dari ${targetWallet.name}! ✅',
            ),
            backgroundColor: AppColors.textBlack,
          ),
        );
      }
    }
  }

  Future<void> _handleRevertTask(TaskModel task) async {
    final taskProv = Provider.of<TaskProvider>(context, listen: false);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Status Selesai?'),
        content: const Text(
          'Saldo dompet akan dikembalikan seperti semula dan transaksi terkait akan dihapus.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await taskProv.revertTask(task);
      await walletProv.loadWallets();
      await txProv.refreshTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status task dikembalikan ke belum selesai')),
        );
      }
    }
  }

  Future<void> _confirmDeleteTask(TaskModel task) async {
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.butterYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
        ),
        title: const Text('Hapus Jadwal Task?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text('Jadwal "${task.title}" akan dihapus permanen.'),
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

    if (confirm == true && mounted) {
      await taskProv.deleteTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal task berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);

    // 1. Tagihan pada bulan & tahun yang dipilih:
    final List<TaskModel> filteredExpenses = [];
    final seenExpenseKeys = <String>{};

    // A. Masukkan task yang sudah diselesaikan pada bulan & tahun ini
    for (var task in taskProv.completedTasks) {
      if (task.isIncome) continue;
      final d = task.completedAt ?? task.dueDate;
      if (d.year == _selectedDate.year && d.month == _selectedDate.month) {
        filteredExpenses.add(task);
        seenExpenseKeys.add('${task.title}_${task.recurrence}');
      }
    }

    // B. Masukkan SEMUA task tagihan yang aktif/belum dicek ke bulan & tahun ini
    for (var task in taskProv.pendingExpenses) {
      final key = '${task.title}_${task.recurrence}';
      if (seenExpenseKeys.contains(key)) continue;

      // Sesuaikan representasi tanggal jatuh tempo dengan bulan & tahun yang sedang dilihat
      final daysInSelectedMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
      final targetDay = task.dueDate.day > daysInSelectedMonth ? daysInSelectedMonth : task.dueDate.day;
      final viewDueDate = DateTime(_selectedDate.year, _selectedDate.month, targetDay, task.dueDate.hour, task.dueDate.minute);

      filteredExpenses.add(task.copyWith(dueDate: viewDueDate));
      seenExpenseKeys.add(key);
    }

    // 2. Gaji / Pemasukan pada bulan & tahun yang dipilih:
    final List<TaskModel> filteredIncomes = [];
    final seenIncomeKeys = <String>{};

    // A. Masukkan pemasukan yang sudah diselesaikan pada bulan & tahun ini
    for (var task in taskProv.completedTasks) {
      if (!task.isIncome) continue;
      final d = task.completedAt ?? task.dueDate;
      if (d.year == _selectedDate.year && d.month == _selectedDate.month) {
        filteredIncomes.add(task);
        seenIncomeKeys.add('${task.title}_${task.recurrence}');
      }
    }

    // B. Masukkan SEMUA task pemasukan yang aktif/belum dicek ke bulan & tahun ini
    for (var task in taskProv.pendingIncomes) {
      final key = '${task.title}_${task.recurrence}';
      if (seenIncomeKeys.contains(key)) continue;

      final daysInSelectedMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
      final targetDay = task.dueDate.day > daysInSelectedMonth ? daysInSelectedMonth : task.dueDate.day;
      final viewDueDate = DateTime(_selectedDate.year, _selectedDate.month, targetDay, task.dueDate.hour, task.dueDate.minute);

      filteredIncomes.add(task.copyWith(dueDate: viewDueDate));
      seenIncomeKeys.add(key);
    }

    // 3. Filter Tab Laporan berdasarkan Bulan, Tahun, dan Jenis yang dipilih
    final filteredCompletedTasks = taskProv.completedTasks.where((task) {
      final date = task.completedAt ?? task.dueDate;
      final matchMonth = date.month == _selectedDate.month;
      final matchYear = date.year == _selectedDate.year;

      bool matchType = true;
      if (_selectedReportType == 'EXPENSE') {
        matchType = !task.isIncome;
      } else if (_selectedReportType == 'INCOME') {
        matchType = task.isIncome;
      }

      return matchMonth && matchYear && matchType;
    }).toList();

    // Hitung total nominal pending periode ini
    double periodPendingExpense = 0;
    for (var t in filteredExpenses) {
      if (!t.isCompleted) {
        periodPendingExpense += (t.estimatedAmount ?? 0);
      }
    }

    double periodPendingIncome = 0;
    for (var t in filteredIncomes) {
      if (!t.isCompleted) {
        periodPendingIncome += (t.estimatedAmount ?? 0);
      }
    }

    final monthName = DateFormat('MMMM', 'id_ID').format(_selectedDate);
    final yearName = DateFormat('yyyy', 'id_ID').format(_selectedDate);

    return AppBackgroundScaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack,
              offset: Offset(2.5, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => AddTaskDialog.show(context),
          backgroundColor: AppColors.primaryYellow,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
          ),
          child: const Icon(Icons.add_rounded, size: 28, color: AppColors.textBlack),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Card Neo-Brutalist
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderBlack, width: 2.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 1.8),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textBlack),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jadwal & Task Finansial',
                              style: TextStyle(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Text(
                              'Kelola pengeluaran rutin & jadwal gaji',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ========================================================
                  // BARIS RINGKASAN 3-KOLOM (Bulan/Tahun | Pemasukan | Pengeluaran)
                  // ========================================================
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          offset: Offset(2, 2.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            // 1. Selector Bulan & Tahun
                            Expanded(
                              flex: 7,
                              child: InkWell(
                                onTap: _showMonthYearPicker,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        yearName,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textMuted,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              monthName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textBlack,
                                                letterSpacing: -0.3,
                                                height: 1.1,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textBlack),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Garis Vertikal
                            Container(width: 1.8, height: double.infinity, color: AppColors.borderBlack),

                            // 2. Gaji / Pemasukan Menunggu
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_downward_rounded, size: 11, color: Color(0xFF16A34A)),
                                        SizedBox(width: 2),
                                        Text(
                                          'Gaji/Cuan',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        CurrencyFormatter.formatRupiah(periodPendingIncome),
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Garis Vertikal
                            Container(width: 1.8, height: double.infinity, color: AppColors.borderBlack),

                            // 3. Tagihan / Pengeluaran Menunggu
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_upward_rounded, size: 11, color: Color(0xFFDC2626)),
                                        SizedBox(width: 2),
                                        Text(
                                          'Tagihan',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        CurrencyFormatter.formatRupiah(periodPendingExpense),
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Segmented Tab Bar: [Tagihan Rutin] [Pemasukan Gaji] [Laporan Selesai]
            Container(
              color: AppColors.cardWhite,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textBlack,
                indicatorWeight: 3,
                labelColor: AppColors.textBlack,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: 'Tagihan (${filteredExpenses.length})'),
                  Tab(text: 'Gaji (${filteredIncomes.length})'),
                  Tab(text: 'Laporan (${filteredCompletedTasks.length})'),
                ],
              ),
            ),

            // 3. Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(
                    tasks: filteredExpenses,
                    emptyText: 'Tidak ada tagihan rutin di bulan $monthName $yearName.',
                    isReport: false,
                  ),
                  _buildTaskList(
                    tasks: filteredIncomes,
                    emptyText: 'Tidak ada jadwal gaji/pemasukan di bulan $monthName $yearName.',
                    isReport: false,
                  ),
                  _buildReportView(
                    tasks: filteredCompletedTasks,
                    totalAll: taskProv.completedTasks.length,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView({
    required List<TaskModel> tasks,
    required int totalAll,
  }) {
    // Hitung total realisasi di periode & filter yang dipilih
    double totalExpenseRealized = 0;
    double totalIncomeRealized = 0;

    for (var t in tasks) {
      if (t.isIncome) {
        totalIncomeRealized += (t.estimatedAmount ?? 0);
      } else {
        totalExpenseRealized += (t.estimatedAmount ?? 0);
      }
    }

    final monthName = DateFormat('MMMM', 'id_ID').format(_selectedDate);
    final yearName = DateFormat('yyyy', 'id_ID').format(_selectedDate);

    return Column(
      children: [
        // Filter Bar Jenis (Semua / Pengeluaran / Pemasukan)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
            border: Border(
              bottom: BorderSide(color: AppColors.borderBlack, width: 1.8),
            ),
          ),
          child: Column(
            children: [
              // Chip Filter Tipe (Semua / Pengeluaran / Pemasukan)
              Row(
                children: [
                  _buildFilterChip(
                    label: 'Semua',
                    isSelected: _selectedReportType == 'ALL',
                    onTap: () => setState(() => _selectedReportType = 'ALL'),
                    selectedBgColor: AppColors.primaryYellow,
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: '💸 Pengeluaran',
                    isSelected: _selectedReportType == 'EXPENSE',
                    onTap: () => setState(() => _selectedReportType = 'EXPENSE'),
                    selectedBgColor: const Color(0xFFFFE4E6),
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: '💰 Gaji/Pemasukan',
                    isSelected: _selectedReportType == 'INCOME',
                    onTap: () => setState(() => _selectedReportType = 'INCOME'),
                    selectedBgColor: const Color(0xFFDCFCE7),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Mini Info Rekap Realisasi Periode
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderBlack, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_selectedReportType == 'ALL' || _selectedReportType == 'EXPENSE')
                      Text(
                        'Realisasi Keluar: ${CurrencyFormatter.formatRupiah(totalExpenseRealized)}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                      ),
                    if (_selectedReportType == 'ALL')
                      const Text('|', style: TextStyle(color: AppColors.borderBlack, fontWeight: FontWeight.bold)),
                    if (_selectedReportType == 'ALL' || _selectedReportType == 'INCOME')
                      Text(
                        'Realisasi Masuk: ${CurrencyFormatter.formatRupiah(totalIncomeRealized)}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List View Laporan
        Expanded(
          child: _buildTaskList(
            tasks: tasks,
            emptyText: totalAll == 0
                ? 'Belum ada laporan pembayaran/pencairan.'
                : 'Tidak ada riwayat laporan di $monthName $yearName.',
            isReport: true,
          ),
        ),
      ],
    );
  }

  double totalExpenseExpenseFallback(double v) => v;

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedBgColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderBlack, width: isSelected ? 1.6 : 1.2),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(1, 1),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList({
    required List<TaskModel> tasks,
    required String emptyText,
    required bool isReport,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.task_alt_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, isReport: isReport);
      },
    );
  }

  Future<void> _showTaskActionSheet(TaskModel task, bool isReport) async {
    final isIncome = task.isIncome;
    final amount = task.estimatedAmount ?? 0.0;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.5),
              left: BorderSide(color: AppColors.borderBlack, width: 2.5),
              right: BorderSide(color: AppColors.borderBlack, width: 2.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderBlack.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),

                // Info Singkat Task
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isIncome ? AppColors.mintGreen : AppColors.bubblePink,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderBlack, width: 1.5),
                        ),
                        child: Icon(
                          isIncome ? Icons.monetization_on_rounded : Icons.receipt_long_rounded,
                          size: 20,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Text(
                              '${isIncome ? 'Pemasukan' : 'Tagihan'} • ${task.walletName ?? 'Dompet'}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (amount > 0)
                        Text(
                          '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(amount)}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Eksekusi Bayar/Cairkan (Jika belum selesai)
                if (!isReport) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleExecuteTask(task);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isIncome ? AppColors.mintGreen : AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBlack, width: 1.8),
                        boxShadow: const [
                          BoxShadow(color: AppColors.shadowBlack, offset: Offset(2, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isIncome ? Icons.monetization_on_rounded : Icons.check_circle_outline_rounded,
                            size: 18,
                            color: AppColors.textBlack,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isIncome ? 'Cairkan Gaji Sekarang 💰' : 'Bayar Tagihan Sekarang 💸',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.textBlack),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleRevertTask(task);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded, size: 18, color: AppColors.dangerRed),
                          SizedBox(width: 8),
                          Text(
                            'Batalkan Status Selesai',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.dangerRed),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Baris Menu: Edit & Hapus
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          AddTaskDialog.show(context, existing: task);
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderBlack, width: 1.8),
                            boxShadow: const [
                              BoxShadow(color: AppColors.shadowBlack, offset: Offset(1.5, 1.5)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_rounded, size: 16, color: AppColors.textBlack),
                              SizedBox(width: 6),
                              Text('Edit Jadwal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _confirmDeleteTask(task);
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderBlack, width: 1.8),
                            boxShadow: const [
                              BoxShadow(color: AppColors.shadowBlack, offset: Offset(1.5, 1.5)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.dangerRed),
                              SizedBox(width: 6),
                              Text('Hapus', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: AppColors.dangerRed)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, {required bool isReport}) {
    final isIncome = task.isIncome;
    final amount = task.estimatedAmount ?? 0.0;
    final recurrenceLabel = task.recurrence == 'WEEKLY'
        ? 'Tiap Minggu'
        : (task.recurrence == 'MONTHLY' ? 'Tiap Bulan' : 'Sekali');

    final isCompleted = task.isCompleted || isReport;
    final now = DateTime.now();
    final isOverdue = !isCompleted && task.dueDate.isBefore(DateTime(now.year, now.month, now.day));

    // Desain Card: Abu-abu jika sudah selesai dibayar/dicairkan
    final cardBg = isCompleted ? const Color(0xFFF4F4F5) : AppColors.cardWhite;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showTaskActionSheet(task, isCompleted),
        child: NeoCard(
          backgroundColor: cardBg,
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          borderWidth: 1.8,
          child: Row(
            children: [
              // Checkbox / Aksi Centang Cepat
              if (!isCompleted)
                GestureDetector(
                  onTap: () => _handleExecuteTask(task),
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderBlack,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          offset: Offset(1, 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.transparent),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _handleRevertTask(task),
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderBlack, width: 1.8),
                    ),
                    child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  ),
                ),

              // Icon Type & Status Badge (Bayar/Cairkan vs Selesai)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFE4E4E7)
                          : (isIncome ? AppColors.mintGreen : AppColors.bubblePink),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted ? const Color(0xFFA1A1AA) : AppColors.borderBlack,
                        width: 1.6,
                      ),
                    ),
                    child: Icon(
                      isIncome ? Icons.monetization_on_rounded : Icons.receipt_long_rounded,
                      size: 18,
                      color: isCompleted ? const Color(0xFF71717A) : AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFE4E4E7)
                          : (isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFEF08A)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCompleted ? const Color(0xFFA1A1AA) : AppColors.borderBlack,
                        width: 0.9,
                      ),
                    ),
                    child: Text(
                      isCompleted
                          ? 'Selesai'
                          : (isIncome ? 'Cairkan' : 'Bayar'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isCompleted ? const Color(0xFF71717A) : AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Info Task (Judul di baris 1 bersama nominal, Baris 2: Badge frekuensi & dompet, Baris 3: Tanggal/Tempo)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris 1: Judul Task (Kiri) & Nominal (Kanan)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: isCompleted ? const Color(0xFF71717A) : AppColors.textBlack,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (amount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(amount)}',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: isCompleted
                                  ? const Color(0xFF71717A)
                                  : (isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Baris 2: Badge Frekuensi & Badge Dompet
                    Row(
                      children: [
                        // Badge Frekuensi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFE4E4E7) : AppColors.skyBlue,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCompleted ? const Color(0xFFA1A1AA) : AppColors.borderBlack,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            recurrenceLabel,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isCompleted ? const Color(0xFF71717A) : AppColors.textBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),

                        // Badge Dompet
                        if (task.walletName != null)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isCompleted ? const Color(0xFFE4E4E7) : AppColors.pillGray,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCompleted ? const Color(0xFFA1A1AA) : AppColors.borderBlack,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                task.walletName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isCompleted ? const Color(0xFF71717A) : AppColors.textBlack,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Baris 3: Status Selesai vs Jatuh Tempo
                    if (isCompleted)
                      Text(
                        'Selesai: ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(task.completedAt ?? task.dueDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue ? Icons.warning_amber_rounded : Icons.alarm_rounded,
                            size: 13,
                            color: isOverdue ? const Color(0xFFDC2626) : AppColors.textBlack,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              'Tempo: ${DateFormat('d MMM yyyy', 'id_ID').format(task.dueDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isOverdue ? const Color(0xFFDC2626) : AppColors.textBlack,
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
        ),
      ),
    );
  }
}

/// Dialog Gabungan Pemilih Bulan & Tahun untuk TasksScreen
class _TaskMonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _TaskMonthYearPickerDialog({required this.initialDate});

  @override
  State<_TaskMonthYearPickerDialog> createState() => _TaskMonthYearPickerDialogState();
}

class _TaskMonthYearPickerDialogState extends State<_TaskMonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(5, (i) => now.year - 2 + i);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.butterYellow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderBlack, width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack,
              offset: Offset(3, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Dialog
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Periode Bulan & Tahun',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlack, width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textBlack),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Label Section Tahun
            const Text(
              'Tahun:',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),

            // Horizontal Year Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: years.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final year = years[i];
                  final isSelected = year == _selectedYear;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedYear = year),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryYellow : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderBlack,
                          width: isSelected ? 2.0 : 1.4,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: AppColors.shadowBlack,
                                  offset: Offset(1.5, 1.5),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Label Section Bulan
            const Text(
              'Bulan:',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),

            // Grid 3x4 Pilihan Bulan
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, idx) {
                final monthNum = idx + 1;
                final isSelected = _selectedMonth == monthNum && _selectedYear == widget.initialDate.year;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      context,
                      DateTime(_selectedYear, monthNum, 1),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.mintGreen : AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderBlack,
                        width: isSelected ? 2.0 : 1.4,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: AppColors.shadowBlack,
                                offset: Offset(1.5, 1.5),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _months[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
