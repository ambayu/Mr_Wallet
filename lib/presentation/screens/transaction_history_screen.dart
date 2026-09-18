import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/neo_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? initialWalletFilter;

  const TransactionHistoryScreen({super.key, this.initialWalletFilter});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedTypeFilter = 'Semua'; // 'Semua', 'Pemasukan', 'Pengeluaran'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String? catName, String type) {
    if (type == 'INCOME') return AppColors.mintGreen;
    final cat = (catName ?? '').toLowerCase();
    if (cat.contains('makan') || cat.contains('food')) return AppColors.primaryYellow;
    if (cat.contains('trans') || cat.contains('kendaraan')) return AppColors.skyBlue;
    if (cat.contains('kopi') || cat.contains('coffee')) return AppColors.softPeach;
    if (cat.contains('belanja') || cat.contains('shop')) return AppColors.bubblePink;
    return AppColors.lavenderPurple;
  }

  IconData _getCategoryIcon(String? catName, String type) {
    if (type == 'INCOME') return Icons.payments_outlined;
    final cat = (catName ?? '').toLowerCase();
    if (cat.contains('makan') || cat.contains('food')) return Icons.restaurant_rounded;
    if (cat.contains('trans') || cat.contains('kendaraan')) return Icons.directions_bus_rounded;
    if (cat.contains('kopi') || cat.contains('coffee')) return Icons.coffee_rounded;
    if (cat.contains('belanja') || cat.contains('shop')) return Icons.shopping_bag_outlined;
    if (cat.contains('hiburan')) return Icons.sports_esports_outlined;
    if (cat.contains('tagihan')) return Icons.receipt_long_rounded;
    return Icons.category_rounded;
  }

  Map<String, List<TransactionModel>> _groupTransactions(List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var tx in list) {
      // Filter by type
      if (_selectedTypeFilter == 'Pemasukan' && tx.type != 'INCOME') continue;
      if (_selectedTypeFilter == 'Pengeluaran' && tx.type != 'EXPENSE') continue;

      // Filter by search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final desc = tx.description.toLowerCase();
        final cat = (tx.categoryName ?? '').toLowerCase();
        if (!desc.contains(q) && !cat.contains(q)) continue;
      }

      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String groupKey;
      if (txDate == today) {
        groupKey = 'Hari ini, ${DateFormat('d MMM yyyy').format(tx.date)}';
      } else if (txDate == yesterday) {
        groupKey = 'Kemarin, ${DateFormat('d MMM yyyy').format(tx.date)}';
      } else {
        groupKey = DateFormat('EEEE, d MMM yyyy').format(tx.date);
      }

      groups.putIfAbsent(groupKey, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    final grouped = _groupTransactions(txProv.transactions);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            onPressed: () => AddTransactionDialog.show(context),
            tooltip: 'Tambah Transaksi',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input matching Showcase Screen 5
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
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
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textBlack, size: 22),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter pills: [Semua] [Pemasukan] [Pengeluaran]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterPill('Semua'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Pemasukan'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Pengeluaran'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Grouped Transaction List
            Expanded(
              child: grouped.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.mascotThinking,
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada transaksi yang sesuai',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, index) {
                        final dateHeader = grouped.keys.elementAt(index);
                        final txList = grouped[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 8),
                              child: Text(
                                dateHeader,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),
                            ...txList.map((tx) => _buildTransactionTile(tx)),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedTypeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bubblePink : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final isIncome = tx.type == 'INCOME';
    final iconColor = _getCategoryColor(tx.categoryName, tx.type);
    final iconData = _getCategoryIcon(tx.categoryName, tx.type);
    final timeStr = DateFormat('HH:mm').format(tx.date);

    return NeoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: AppColors.cardWhite,
      borderRadius: 18,
      borderWidth: 1.8,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 1.8),
            ),
            child: Icon(iconData, color: AppColors.textBlack, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description.isNotEmpty ? tx.description : (tx.categoryName ?? 'Transaksi'),
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
                  timeStr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(tx.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isIncome ? AppColors.successGreen : AppColors.dangerRed,
            ),
          ),
        ],
      ),
    );
  }
}
