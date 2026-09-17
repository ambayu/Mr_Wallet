import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/neo_badge.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_text_field.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? initialWalletFilter;

  const TransactionHistoryScreen({super.key, this.initialWalletFilter});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedTypeFilter = 'ALL'; // ALL, EXPENSE, INCOME, TRANSFER, ADJUSTMENT
  String? _selectedWalletId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.initialWalletFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> list) {
    return list.where((tx) {
      // Type Filter
      if (_selectedTypeFilter != 'ALL' && tx.type != _selectedTypeFilter) {
        return false;
      }
      // Wallet Filter
      if (_selectedWalletId != null &&
          tx.walletId != _selectedWalletId &&
          tx.toWalletId != _selectedWalletId) {
        return false;
      }
      // Search Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final desc = tx.description.toLowerCase();
        final cat = (tx.categoryName ?? '').toLowerCase();
        final wallet = (tx.walletName ?? '').toLowerCase();
        if (!desc.contains(q) && !cat.contains(q) && !wallet.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _showTransactionDetails(TransactionModel tx) {
    final isExpense = tx.type == 'EXPENSE';
    final isIncome = tx.type == 'INCOME';
    final isTransfer = tx.type == 'TRANSFER';
    final isAdjustment = tx.type == 'ADJUSTMENT';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.butterYellow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.borderBlack, width: 3),
            left: BorderSide(color: AppColors.borderBlack, width: 3),
            right: BorderSide(color: AppColors.borderBlack, width: 3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAdjustment
                      ? 'Detail Rekonsiliasi'
                      : isTransfer
                          ? 'Detail Transfer'
                          : 'Detail Transaksi',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlack, width: 2),
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            NeoCard(
              backgroundColor: AppColors.cardWhite,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nominal:',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        isExpense
                            ? '-${CurrencyFormatter.format(tx.amount)}'
                            : isIncome
                                ? '+${CurrencyFormatter.format(tx.amount)}'
                                : isAdjustment
                                    ? '${tx.amount < 0 ? "-" : "+"}${CurrencyFormatter.format(tx.amount.abs())}'
                                    : CurrencyFormatter.format(tx.amount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isExpense || (isAdjustment && tx.amount < 0)
                              ? const Color(0xFFC0392B)
                              : const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderBlack, height: 20),
                  _buildDetailRow('Deskripsi', tx.description),
                  _buildDetailRow('Wadah Rekening', tx.walletName ?? 'Dompet'),
                  if (tx.toWalletName != null)
                    _buildDetailRow('Tujuan Transfer', tx.toWalletName!),
                  if (tx.categoryName != null)
                    _buildDetailRow('Kategori', tx.categoryName!),
                  _buildDetailRow('Waktu', DateFormatter.formatDateTime(tx.transactionDate)),
                  _buildDetailRow('Sub-Tipe', tx.subType),
                  if (tx.actualBalanceSnapshot != null)
                    _buildDetailRow(
                      'Snapshot Saldo Riil',
                      CurrencyFormatter.format(tx.actualBalanceSnapshot!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Delete Action Button
            NeoButton(
              label: 'Hapus Transaksi (Rollback Saldo)',
              icon: Icons.delete_forever_rounded,
              backgroundColor: const Color(0xFFFF8A8A),
              onPressed: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final txProv =
                    Provider.of<TransactionProvider>(context, listen: false);
                final walletProv =
                    Provider.of<WalletProvider>(context, listen: false);

                await txProv.deleteTransaction(tx);
                await walletProv.loadWallets();

                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.borderBlack,
                      content: Text(
                        'Transaksi dihapus dan saldo berhasil dipulihkan secara atomik!',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);

    final filteredList = _filterTransactions(txProv.recentTransactions);

    return Scaffold(
      backgroundColor: AppColors.butterYellow,
      appBar: AppBar(
        backgroundColor: AppColors.butterYellow,
        elevation: 0,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.textBlack, size: 28),
            onPressed: () => AddTransactionDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              NeoTextField(
                controller: _searchController,
                hintText: 'Cari transaksi, jajan, rekening...',
                prefixIcon: Icons.search,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // Filter Chips: Type
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeFilterChip('ALL', 'Semua'),
                    const SizedBox(width: 8),
                    _buildTypeFilterChip('EXPENSE', 'Pengeluaran'),
                    const SizedBox(width: 8),
                    _buildTypeFilterChip('INCOME', 'Pemasukan'),
                    const SizedBox(width: 8),
                    _buildTypeFilterChip('TRANSFER', 'Transfer'),
                    const SizedBox(width: 8),
                    _buildTypeFilterChip('ADJUSTMENT', 'Uang Hilang / Selisih'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips: Wallets
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedWalletId = null),
                      child: NeoBadge(
                        text: 'Semua Rekening',
                        backgroundColor: _selectedWalletId == null
                            ? AppColors.lavenderPurple
                            : AppColors.cardWhite,
                        borderWidth: _selectedWalletId == null ? 2.5 : 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...walletProv.wallets.map((w) {
                      final isSel = _selectedWalletId == w.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedWalletId = w.id),
                          child: NeoBadge(
                            text: w.name,
                            backgroundColor:
                                isSel ? AppColors.lavenderPurple : AppColors.cardWhite,
                            borderWidth: isSel ? 2.5 : 1.5,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Count header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredList.length} Transaksi Ditemukan',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => BalanceAdjustmentDialog.show(context),
                    child: const NeoBadge(
                      text: '+ Rekonsiliasi Saldo',
                      backgroundColor: AppColors.mintGreen,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transaction List
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                        child: NeoCard(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Tidak ada transaksi yang sesuai filter.',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (ctx, idx) {
                          final tx = filteredList[idx];
                          return _buildHistoryItem(tx);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip(String key, String label) {
    final isSel = _selectedTypeFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeFilter = key),
      child: NeoBadge(
        text: label,
        backgroundColor: isSel ? AppColors.mintGreen : AppColors.cardWhite,
        borderWidth: isSel ? 2.5 : 1.5,
      ),
    );
  }

  Widget _buildHistoryItem(TransactionModel tx) {
    final isExpense = tx.type == 'EXPENSE';
    final isIncome = tx.type == 'INCOME';
    final isAdjustment = tx.type == 'ADJUSTMENT';

    Color cardBg = AppColors.cardWhite;
    if (isAdjustment) cardBg = const Color(0xFFFFF7E6);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: NeoCard(
        backgroundColor: cardBg,
        padding: const EdgeInsets.all(14),
        onTap: () => _showTransactionDetails(tx),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.bubblePink
                    : isIncome
                        ? AppColors.mintGreen
                        : AppColors.butterYellow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderBlack, width: 2),
              ),
              child: Icon(
                isExpense
                    ? Icons.shopping_bag_outlined
                    : isIncome
                        ? Icons.attach_money
                        : isAdjustment
                            ? Icons.help_outline
                            : Icons.sync_alt,
                size: 20,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(width: 12),

            // Description and Metadata
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
                      fontWeight: FontWeight.w900,
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

            // Amount Output
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                const SizedBox(height: 2),
                NeoBadge(
                  text: tx.type,
                  fontSize: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  backgroundColor: AppColors.butterYellow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
