import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/transaction_provider.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import 'transaction_history_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_currentMonth.year, _currentMonth.month, _currentMonth.day);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    final monthFormat = DateFormat('MMMM yyyy');
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1; // Mon=0

    final selectedDayTransactions = txProv.transactions.where((tx) {
      final d = tx.date;
      return d.year == _selectedDay.year &&
          d.month == _selectedDay.month &&
          d.day == _selectedDay.day;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Kalender'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector matching Screen 9
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    monthFormat.format(_currentMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Calendar Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                borderRadius: 22,
                borderWidth: 1.8,
                child: Column(
                  children: [
                    // Day of week headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                          .map((d) => SizedBox(
                                width: 34,
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),

                    // Days grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daysInMonth + firstDayOffset,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 4,
                      ),
                      itemBuilder: (context, index) {
                        if (index < firstDayOffset) {
                          return const SizedBox.shrink();
                        }
                        final dayNumber = index - firstDayOffset + 1;
                        final isSelected = _selectedDay.year == _currentMonth.year &&
                            _selectedDay.month == _currentMonth.month &&
                            _selectedDay.day == dayNumber;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = DateTime(
                                _currentMonth.year,
                                _currentMonth.month,
                                dayNumber,
                              );
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryYellow : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: AppColors.borderBlack, width: 1.8)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Motivational Crab Quote Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
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
                    Image.asset(
                      AppAssets.mascotStudying,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Disiplin hari ini, untuk mimpi esok! ✨',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Transactions on Selected Day
              Text(
                'Transaksi di ${DateFormat('d MMM yyyy').format(_selectedDay)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),

              if (selectedDayTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Image.asset(
                        AppAssets.mascotReading,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Belum ada transaksi di tanggal ini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...selectedDayTransactions.map((tx) {
                  final isIncome = tx.type == 'INCOME';
                  return NeoCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: AppColors.cardWhite,
                    borderRadius: 16,
                    borderWidth: 1.6,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isIncome ? AppColors.mintGreen : AppColors.bubblePink,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 1.5),
                          ),
                          child: Icon(
                            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            size: 16,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              Text(
                                tx.categoryName ?? 'Kategori',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(tx.amount)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isIncome ? AppColors.successGreen : AppColors.dangerRed,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 16),
              // "Lihat Semua Transaksi" Button matching Screen 9
              NeoButton(
                label: 'Lihat Semua Transaksi',
                backgroundColor: AppColors.primaryYellow,
                height: 50,
                borderRadius: 25,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
