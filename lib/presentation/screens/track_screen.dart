import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/transaction_provider.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_header_card.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  String _selectedPeriod = 'Bulan'; // 'Bulan', '3 Bulan', 'Tahun'
  bool _isLoading = true;
  double _spending = 0.0;
  double _income = 0.0;
  double _growthPct = 0.0;
  List<Map<String, dynamic>> _categories = [];

  final List<Color> _chartPalette = [
    const Color(0xFFFF6B6B),
    const Color(0xFFFF9F43),
    const Color(0xFF54A0FF),
    const Color(0xFF1DD1A1),
    const Color(0xFF9B59B6),
    const Color(0xFF48DBFB),
    const Color(0xFFFECA57),
    const Color(0xFFFF9FF3),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final data = await txProv.getAnalyticsForPeriod(_selectedPeriod);

    if (mounted) {
      setState(() {
        _spending = data['spending'] as double? ?? 0.0;
        _income = data['income'] as double? ?? 0.0;
        _growthPct = data['growthPercentage'] as double? ?? 0.0;
        _categories = (data['categories'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String period) {
    if (_selectedPeriod == period) return;
    setState(() {
      _selectedPeriod = period;
    });
    _loadData();
  }

  String _generateMrWalletTips() {
    if (_spending == 0) {
      return 'Belum ada pengeluaran di periode $_selectedPeriod ini! Pertahankan gaya hidup hematmu ya! 🦀💰';
    }

    if (_categories.isNotEmpty) {
      final topCat = _categories.first;
      final topCatName = topCat['name'] as String? ?? 'Kategori';
      final topAmount = (topCat['total_amount'] as num?)?.toDouble() ?? 0.0;
      final pct = _spending > 0 ? ((topAmount / _spending) * 100).toInt() : 0;

      if (topCatName.toLowerCase().contains('makan') || topCatName.toLowerCase().contains('kopi')) {
        return 'Pengeluaran terbesarmu ada di $topCatName ($pct% / ${CurrencyFormatter.formatShort(topAmount)}). Coba kurangi jajan atau masak sendiri untuk hemat hingga 30%! 🍳';
      } else if (topCatName.toLowerCase().contains('belanja')) {
        return 'Kamu menghabiskan $pct% budget di $topCatName! Terapkan aturan 24 jam sebelum checkout keranjang agar tidak impulsif! 🛍️';
      } else if (topCatName.toLowerCase().contains('trans')) {
        return 'Biaya $topCatName memakan $pct% dari total belanja. Coba kombinasikan transportasi umum atau carpool untuk menghemat ongkos! 🛵';
      } else {
        return 'Pos pengeluaran tertinggi adalah $topCatName sebesar ${CurrencyFormatter.formatRupiah(topAmount)} ($pct%). Awasi terus pos ini agar tidak overbudget!';
      }
    }

    if (_growthPct > 0) {
      return 'Pengeluaranmu meningkat ${_growthPct.toStringAsFixed(1)}% dibanding periode sebelumnya. Yuk mulai catat dan evaluasi pos yang kurang penting!';
    } else {
      return 'Bagus sekali! Pengeluaranmu stabil terkontrol di periode ini. Terus pantau cuan dan tabunganmu bersama Mr. Wallet! 🦀✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8A7),
      appBar: const NeoHeaderCard(
        title: 'Insight',
        subtitle: 'Analisis & pergerakan kas',
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.textBlack),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.textBlack,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Period Selector
                      Row(
                        children: [
                          _buildPeriodPill('Bulan'),
                          const SizedBox(width: 8),
                          _buildPeriodPill('3 Bulan'),
                          const SizedBox(width: 8),
                          _buildPeriodPill('Tahun'),
                        ],
                      ),
                      const SizedBox(height: 18),

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
                                Text(
                                  'Pengeluaran ($_selectedPeriod)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatRupiah(_spending),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                if (_income > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pemasukan: ${CurrencyFormatter.formatRupiah(_income)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _growthPct > 0 ? AppColors.bubblePink : AppColors.mintGreen,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderBlack, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _growthPct > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    size: 14,
                                    color: _growthPct > 0 ? AppColors.dangerRed : const Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${_growthPct.abs().toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: _growthPct > 0 ? AppColors.dangerRed : const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 3. Donut Chart & Breakdown Card
                      NeoCard(
                        backgroundColor: AppColors.cardWhite,
                        borderRadius: 22,
                        borderWidth: 1.8,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Proporsi Kategori Pengeluaran',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_categories.isEmpty || _spending == 0)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                alignment: Alignment.center,
                                child: const Column(
                                  children: [
                                    Icon(Icons.pie_chart_outline_rounded, size: 44, color: AppColors.textMuted),
                                    SizedBox(height: 8),
                                    Text(
                                      'Belum ada transaksi pengeluaran pada periode ini.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
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
                                            centerSpaceRadius: 42,
                                            sections: _categories.asMap().entries.map((entry) {
                                              final idx = entry.key;
                                              final c = entry.value;
                                              final amount = (c['total_amount'] as num?)?.toDouble() ?? 0.0;
                                              final color = _chartPalette[idx % _chartPalette.length];

                                              return PieChartSectionData(
                                                color: color,
                                                value: amount,
                                                showTitle: false,
                                                radius: 22,
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
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.formatRupiah(_spending),
                                              style: const TextStyle(
                                                fontSize: 10.5,
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
                                      children: _categories.asMap().entries.map((entry) {
                                        final idx = entry.key;
                                        final c = entry.value;
                                        final amount = (c['total_amount'] as num?)?.toDouble() ?? 0.0;
                                        final pct = _spending > 0 ? ((amount / _spending) * 100).toInt() : 0;
                                        final color = _chartPalette[idx % _chartPalette.length];

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3.5),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  c['name'] as String? ?? 'Kategori',
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
                                                '$pct%',
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
                      const SizedBox(height: 18),

                      // 4. "Tips dari Mr Wallet" Card (Mascot Melewati/Nongol Keluar Card)
                      NeoCard(
                        width: double.infinity,
                        backgroundColor: AppColors.skyBlue,
                        borderRadius: 24,
                        borderWidth: 2.2,
                        clipBehavior: false,
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20, right: 110),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tips dari Mr. Wallet 💡',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _generateMrWalletTips(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textBlack,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Maskot Berpikir Melewati/Nongol Keluar Card
                            Positioned(
                              right: -10,
                              bottom: -16,
                              child: Image.asset(
                                AppAssets.mascotThinking,
                                width: 115,
                                height: 115,
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

  Widget _buildPeriodPill(String label) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onPeriodChanged(label),
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
