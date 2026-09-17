import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/mascot_art.dart';
import '../widgets/neo_badge.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import 'transaction_history_screen.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    final totalSavings = walletProv.totalBalance;
    final monthlySpending = txProv.monthlySpending;
    final monthlyIncome = txProv.monthlyIncome;

    // Calculate Uang Hilang total from adjustments
    final adjustments = txProv.recentTransactions.where((t) => t.type == 'ADJUSTMENT').toList();
    double totalLostMoney = 0.0;
    for (final adj in adjustments) {
      if (adj.amount < 0) {
        totalLostMoney += adj.amount.abs();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.mintGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Track Savings',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransactionHistoryScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 2.2),
                          ),
                          child: const Icon(Icons.history, color: AppColors.textBlack),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => BalanceAdjustmentDialog.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.butterYellow,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 2.2),
                          ),
                          child: const Icon(Icons.more_vert, color: AppColors.textBlack),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Chart Card (Matching 2nd Screen in Mockup)
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Savings + Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Savings',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(totalSavings),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                        // +12% this month Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.borderBlack, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco_rounded, size: 16, color: AppColors.textBlack),
                              const SizedBox(width: 4),
                              Text(
                                monthlyIncome > monthlySpending ? '+12%\nthis month' : 'Healthy\nBudget',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textBlack,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Colorful Custom Pill Bar Chart (Jan - Jun)
                    _buildPillBarChart(txProv),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Motivational Mascot Banner (Matching Mockup)
              NeoCard(
                backgroundColor: AppColors.skyBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONSISTENCY\nCREATES\nFREEDOM 💜',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CrabMascotWidget(
                      mood: MascotMood.peeking,
                      size: 82,
                      speechBubbleText: 'SAVE\nTODAY!',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Category Breakdown Section
              const Text(
                'Alokasi Pengeluaran Teratas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),

              if (txProv.categorySpending.isEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryStatCard(
                        title: 'Tagihan',
                        amount: 'Rp 250rb',
                        percentage: '45%',
                        icon: Icons.home_rounded,
                        bgColor: AppColors.cardWhite,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCategoryStatCard(
                        title: 'Makanan',
                        amount: 'Rp 175rb',
                        percentage: '35%',
                        icon: Icons.restaurant_rounded,
                        bgColor: AppColors.bubblePink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCategoryStatCard(
                        title: 'Transport',
                        amount: 'Rp 50rb',
                        percentage: '20%',
                        icon: Icons.airplanemode_active_rounded,
                        bgColor: AppColors.butterYellow,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: txProv.categorySpending.take(3).map((catMap) {
                    final double amount = (catMap['total_amount'] as num?)?.toDouble() ?? 0.0;
                    final String name = catMap['name'] as String? ?? 'Kategori';
                    final double pct = monthlySpending > 0 ? (amount / monthlySpending) * 100 : 0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildCategoryStatCard(
                          title: name.split(' ').first,
                          amount: CurrencyFormatter.formatShort(amount),
                          percentage: '${pct.toStringAsFixed(0)}%',
                          icon: _getCategoryIcon(name),
                          bgColor: AppColors.fromHex(catMap['color'] as String? ?? '#FFFFFF'),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),

              // 5. Rekonsiliasi & Uang Hilang Audit Log Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Audit Uang Hilang & Koreksi Saldo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                        ),
                        NeoBadge(
                          text: '${adjustments.length} Log',
                          backgroundColor: AppColors.mintGreen,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Akumulasi Uang Hilang / Receh:',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            totalLostMoney > 0
                                ? '- ${CurrencyFormatter.format(totalLostMoney)}'
                                : 'Rp 0 (Aman)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: Color(0xFFC0392B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Rumus deterministik SmartFlow: Δ = Saldo Riil - Saldo Sistem. Jika sisa fisik berbeda, sistem otomatis mencatat selisih tanpa merusak integritas buku kas.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    NeoButton(
                      label: 'Sinkronisasi Dompet Sekarang',
                      icon: Icons.sync_rounded,
                      backgroundColor: AppColors.butterYellow,
                      height: 44,
                      onPressed: () => BalanceAdjustmentDialog.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillBarChart(TransactionProvider txProv) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final heights = [80.0, 65.0, 115.0, 75.0, 130.0, 150.0];
    final colors = [
      const Color(0xFFFF6B6B), // Coral
      const Color(0xFF74B9FF), // Sky Blue
      const Color(0xFFFFBEE3), // Bubble Pink
      const Color(0xFFFFEAA7), // Cream Yellow
      const Color(0xFFFAB1A0), // Orange Pastel
      const Color(0xFF55EFC4), // Mint Green
    ];

    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Background track pill
              Container(
                width: 38,
                height: 155,
                decoration: BoxDecoration(
                  color: AppColors.pillGray,
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 38,
                  height: heights[index],
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: AppColors.borderBlack, width: 2.2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                months[index],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryStatCard({
    required String title,
    required String amount,
    required String percentage,
    required IconData icon,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlack, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack,
            offset: Offset(2.5, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.textBlack),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('makan') || lower.contains('kopi')) return Icons.restaurant_rounded;
    if (lower.contains('belanja')) return Icons.shopping_bag_outlined;
    if (lower.contains('transport')) return Icons.directions_car_outlined;
    if (lower.contains('tagihan') || lower.contains('listrik')) return Icons.home_rounded;
    if (lower.contains('uang hilang') || lower.contains('selisih')) return Icons.help_outline;
    if (lower.contains('gaji')) return Icons.monetization_on_outlined;
    return Icons.category_rounded;
  }
}
