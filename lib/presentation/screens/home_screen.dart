import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/mascot_art.dart';
import '../widgets/neo_badge.dart';
import '../widgets/neo_card.dart';
import 'settings_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAllTransactions;

  const HomeScreen({super.key, required this.onSeeAllTransactions});

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    final totalBalance = walletProv.totalBalance;
    final monthlySpending = txProv.monthlySpending;
    final totalSavings = totalBalance > monthlySpending ? totalBalance - monthlySpending : totalBalance;

    return Scaffold(
      backgroundColor: AppColors.butterYellow,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await walletProv.loadWallets();
            await txProv.refreshTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'SmartFlow',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textBlack,
                              ),
                              child: const Text(
                                '™',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Good to see you again!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    // Header Actions & Mascot Avatar
                    Row(
                      children: [
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderBlack, width: 2.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowBlack,
                                  offset: Offset(2, 2.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              size: 22,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => BalanceAdjustmentDialog.show(context),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.bubblePink,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderBlack, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowBlack,
                                  offset: Offset(2.5, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: CrabMascotWidget(
                                mood: MascotMood.happy,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Three Overview Pill Badges (Total Balance, Spending, Savings)
                Row(
                  children: [
                    Expanded(
                      child: _buildOverviewPill(
                        label: 'Total Saldo',
                        amount: CurrencyFormatter.formatShort(totalBalance),
                        bgColor: AppColors.mintGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOverviewPill(
                        label: 'Pengeluaran',
                        amount: CurrencyFormatter.formatShort(monthlySpending),
                        bgColor: AppColors.bubblePink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOverviewPill(
                        label: 'Net Balance',
                        amount: CurrencyFormatter.formatShort(totalSavings),
                        bgColor: AppColors.cardWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. Hero Promo / Action Card: "Spend Smarter Live Happier"
                NeoCard(
                  backgroundColor: AppColors.bubblePink,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  onTap: () => BalanceAdjustmentDialog.show(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spend Smarter\nLive Happier',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const NeoBadge(
                              text: 'Cek Uang Hilang 🔍',
                              backgroundColor: AppColors.butterYellow,
                              fontSize: 11,
                            ),
                          ],
                        ),
                      ),
                      const CrabMascotWidget(
                        mood: MascotMood.holdingCoin,
                        size: 90,
                        speechBubbleText: "YOU\nGOT THIS!",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Multi-Account Wallet Carousels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wadah Rekening',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => AddTransactionDialog.show(context),
                      child: const NeoBadge(
                        text: '+ Catat Manual',
                        backgroundColor: AppColors.mintGreen,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: walletProv.wallets.map((wallet) {
                      final isSelected = wallet.id == walletProv.selectedWalletId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => walletProv.selectWallet(wallet.id),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.fromHex(wallet.color),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.borderBlack,
                                width: isSelected ? 3.0 : 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowBlack,
                                  offset: isSelected
                                      ? const Offset(3.5, 4)
                                      : const Offset(2, 2.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      _getWalletIcon(wallet.type),
                                      size: 20,
                                      color: AppColors.textBlack,
                                    ),
                                    if (wallet.isDefault)
                                      const NeoBadge(
                                        text: 'Utama',
                                        backgroundColor: AppColors.cardWhite,
                                        fontSize: 9,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  wallet.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textBlack,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatShort(wallet.balance),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 22),

                // 5. Recent Activity Section
                NeoCard(
                  backgroundColor: AppColors.cardWhite,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TransactionHistoryScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'See all',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.borderBlack,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Transactions List
                      if (txProv.recentTransactions.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Belum ada transaksi. Gunakan Voice AI atau Catat Manual!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ] else ...[
                        ...txProv.recentTransactions.take(5).map((tx) {
                          return _buildTransactionItem(tx);
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewPill({
    required String label,
    required String amount,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlack, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack,
            offset: Offset(2.2, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    final isExpense = tx.type == 'EXPENSE';
    final isIncome = tx.type == 'INCOME';
    final isAdjustment = tx.type == 'ADJUSTMENT';

    Color iconBg = AppColors.butterYellow;
    IconData iconData = Icons.receipt_long;

    if (tx.categoryIcon != null) {
      if (tx.categoryIcon == 'restaurant') iconData = Icons.coffee_rounded;
      if (tx.categoryIcon == 'shopping_bag') iconData = Icons.shopping_bag_outlined;
      if (tx.categoryIcon == 'directions_car') iconData = Icons.directions_car_outlined;
      if (tx.categoryIcon == 'receipt_long') iconData = Icons.electric_bolt_rounded;
      if (tx.categoryIcon == 'help_outline') iconData = Icons.search_rounded;
      if (tx.categoryIcon == 'attach_money') iconData = Icons.monetization_on_outlined;
    }

    if (isExpense) iconBg = AppColors.bubblePink;
    if (isIncome) iconBg = AppColors.mintGreen;
    if (isAdjustment) iconBg = const Color(0xFFFFD4D4);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 2),
            ),
            child: Icon(iconData, color: AppColors.textBlack, size: 22),
          ),
          const SizedBox(width: 12),

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description.isNotEmpty
                      ? tx.description
                      : (tx.categoryName ?? 'Transaksi'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormatter.formatRelative(tx.transactionDate)} • ${tx.walletName ?? "Dompet"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            isExpense
                ? '-${CurrencyFormatter.format(tx.amount)}'
                : isIncome
                    ? '+${CurrencyFormatter.format(tx.amount)}'
                    : isAdjustment
                        ? '${tx.amount < 0 ? "-" : "+"}${CurrencyFormatter.format(tx.amount.abs())}'
                        : CurrencyFormatter.format(tx.amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isExpense || (isAdjustment && tx.amount < 0)
                  ? AppColors.textBlack
                  : const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWalletIcon(String type) {
    switch (type) {
      case 'BANK':
        return Icons.account_balance_rounded;
      case 'EWALLET':
        return Icons.phone_android_rounded;
      case 'CASH':
      default:
        return Icons.payments_rounded;
    }
  }
}
