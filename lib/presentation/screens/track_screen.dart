import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/transaction_provider.dart';
import '../widgets/neo_card.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  String _selectedPeriod = 'Bulan'; // 'Bulan', '3 Bulan', 'Tahun'

  final List<Map<String, dynamic>> _demoCategories = [
    {'name': 'Makanan', 'pct': 30, 'color': Color(0xFFFF6B6B)},
    {'name': 'Transportasi', 'pct': 18, 'color': Color(0xFFFF9F43)},
    {'name': 'Belanja', 'pct': 15, 'color': Color(0xFF54A0FF)},
    {'name': 'Hiburan', 'pct': 12, 'color': Color(0xFF1DD1A1)},
    {'name': 'Tagihan', 'pct': 10, 'color': Color(0xFF9B59B6)},
    {'name': 'Lainnya', 'pct': 15, 'color': Color(0xFF48DBFB)},
  ];

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    final spending = txProv.monthlySpending > 0 ? txProv.monthlySpending : 1350000.0;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Insight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Period Selector matching Showcase Screen 8: [Bulan] [3 Bulan] [Tahun]
              Row(
                children: [
                  _buildPeriodPill('Bulan'),
                  const SizedBox(width: 8),
                  _buildPeriodPill('3 Bulan'),
                  const SizedBox(width: 8),
                  _buildPeriodPill('Tahun'),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Pengeluaran Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                borderRadius: 22,
                borderWidth: 1.8,
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatRupiah(spending),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.bubblePink,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.dangerRed),
                          SizedBox(width: 2),
                          Text(
                            '12%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dangerRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Donut Chart & Breakdown Card matching Showcase Screen 8
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                borderRadius: 22,
                borderWidth: 1.8,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Donut Chart
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 44,
                                  sections: _demoCategories.map((c) {
                                    return PieChartSectionData(
                                      color: c['color'] as Color,
                                      value: (c['pct'] as int).toDouble(),
                                      showTitle: false,
                                      radius: 24,
                                    );
                                  }).toList(),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${(spending / 1000000).toStringAsFixed(2)} jt',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Legend
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _demoCategories.map((c) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: c['color'] as Color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        c['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textBlack,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${c['pct']}%',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. "Tips dari Mr Wallet" Card matching Showcase Screen 8
              NeoCard(
                backgroundColor: AppColors.skyBlue,
                borderRadius: 22,
                borderWidth: 2,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.textBlack, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tips dari Mr Wallet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Coba masak di rumah untuk menghemat pengeluaran makan di luar hingga 30%! Masakan sendiri lebih sehat dan dompet makin tebal.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                              height: 1.3,
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
    );
  }

  Widget _buildPeriodPill(String label) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lavenderPurple : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderBlack, width: 1.8),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(1.5, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: AppColors.textBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
