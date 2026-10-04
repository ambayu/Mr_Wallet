import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/wallet_icon_helper.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/neo_card.dart';
import 'add_transaction_screen.dart';

class WalletDetailScreen extends StatefulWidget {
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Pemasukan', 'Pengeluaran'

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
    if (cat.contains('hiburan') || cat.contains('game')) return Icons.sports_esports_outlined;
    if (cat.contains('telepon') || cat.contains('pulsa')) return Icons.phone_android_rounded;
    return Icons.category_rounded;
  }

  Map<String, List<TransactionModel>> _groupTransactions(List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Filter khusus dompet ini
    final walletTxs = list.where((t) => t.walletId == widget.wallet.id || t.toWalletId == widget.wallet.id);

    for (var tx in walletTxs) {
      if (_selectedFilter == 'Pemasukan' && tx.type != 'INCOME') continue;
      if (_selectedFilter == 'Pengeluaran' && tx.type != 'EXPENSE') continue;

      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String groupKey;
      if (txDate == today) {
        groupKey = 'Hari ini, ${DateFormat('d MMMM yyyy', 'id_ID').format(tx.date)}';
      } else if (txDate == yesterday) {
        groupKey = 'Kemarin, ${DateFormat('d MMMM yyyy', 'id_ID').format(tx.date)}';
      } else {
        groupKey = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tx.date);
      }

      groups.putIfAbsent(groupKey, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    // Ambil data dompet terupdate dari provider
    final currentWallet = walletProv.wallets.firstWhere(
      (w) => w.id == widget.wallet.id,
      orElse: () => widget.wallet,
    );

    // Hitung total pemasukan & pengeluaran untuk dompet ini
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var tx in txProv.transactions) {
      if (tx.walletId == currentWallet.id || tx.toWalletId == currentWallet.id) {
        if (tx.type == 'INCOME') {
          totalIncome += tx.amount;
        } else if (tx.type == 'EXPENSE') {
          totalExpense += tx.amount;
        }
      }
    }

    final grouped = _groupTransactions(txProv.transactions);

    return Scaffold(
      backgroundColor: const Color(0xFFD2EEFC), // Biru Muda Neo-Brutalist
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            border: Border(
              bottom: BorderSide(color: AppColors.borderBlack, width: 2.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlack,
                offset: Offset(0, 2.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Tombol Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.butterYellow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderBlack, width: 1.6),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textBlack),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title Dompet
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentWallet.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Tombol Rekonsiliasi / Sesuaikan Saldo
                  GestureDetector(
                    onTap: () => BalanceAdjustmentDialog.show(
                      context,
                      initialWalletId: currentWallet.id,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderBlack, width: 1.8),
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
                          Icon(Icons.published_with_changes_rounded, size: 15, color: AppColors.textBlack),
                          SizedBox(width: 4),
                          Text(
                            'Sesuaikan',
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
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Kartu Saldo Utama Dompet (NeoCard)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: NeoCard(
                backgroundColor: AppColors.fromHex(currentWallet.color),
                borderRadius: 20,
                borderWidth: 2.2,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.borderBlack, width: 1.8),
                              ),
                              child: Icon(
                                WalletIconHelper.resolve(currentWallet.icon),
                                size: 20,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentWallet.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                if (currentWallet.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.mintGreen,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.borderBlack, width: 0.8),
                                    ),
                                    child: const Text(
                                      'Dompet Utama',
                                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        // Tombol Cepat Catat di Dompet Ini
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(
                                initialWalletId: currentWallet.id,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderBlack, width: 1.6),
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
                                Icon(Icons.add_rounded, size: 14, color: AppColors.textBlack),
                                SizedBox(width: 2),
                                Text(
                                  'Catat',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Saldo Saat Ini:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.formatRupiah(currentWallet.balance),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Baris Arus Masuk & Keluar Dompet Ini
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBlack, width: 1.6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Masuk', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                                    Text(
                                      CurrencyFormatter.formatShort(totalIncome),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1.2, height: 24, color: AppColors.borderBlack.withValues(alpha: 0.2)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Keluar', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
                                      Text(
                                        CurrencyFormatter.formatShort(totalExpense),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Filter Pills Khusus Dompet Ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Riwayat Transaksi:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textBlack),
                  ),
                  const Spacer(),
                  _buildFilterPill('Semua'),
                  const SizedBox(width: 4),
                  _buildFilterPill('Pemasukan'),
                  const SizedBox(width: 4),
                  _buildFilterPill('Pengeluaran'),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // 3. List Transaksi Khusus Dompet Ini
            Expanded(
              child: grouped.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada transaksi di ${currentWallet.name}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, index) {
                        final dateHeader = grouped.keys.elementAt(index);
                        final txList = grouped[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.textBlack,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateHeader,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...txList.map((tx) {
                              final isIncome = tx.type == 'INCOME';
                              final isTransfer = tx.type == 'TRANSFER';
                              final categoryColor = _getCategoryColor(tx.categoryName, tx.type);
                              final categoryIcon = _getCategoryIcon(tx.categoryName, tx.type);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: NeoCard(
                                  backgroundColor: AppColors.cardWhite,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  borderRadius: 16,
                                  borderWidth: 1.8,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: isTransfer ? AppColors.skyBlue : categoryColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.borderBlack, width: 1.6),
                                        ),
                                        child: Icon(
                                          isTransfer ? Icons.sync_alt_rounded : categoryIcon,
                                          size: 18,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.description.isNotEmpty
                                                  ? tx.description
                                                  : (tx.categoryName ?? 'Transaksi'),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textBlack,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              DateFormat('HH:mm').format(tx.date),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.45,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(tx.amount)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: isIncome
                                                  ? const Color(0xFF16A34A)
                                                  : isTransfer
                                                      ? AppColors.textBlack
                                                      : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
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
    final isSelected = _selectedFilter == label;
    final shortLabel = label == 'Pemasukan'
        ? 'Masuk'
        : label == 'Pengeluaran'
            ? 'Keluar'
            : label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textBlack : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderBlack, width: 1.5),
        ),
        child: Text(
          shortLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textBlack,
          ),
        ),
      ),
    );
  }
}
