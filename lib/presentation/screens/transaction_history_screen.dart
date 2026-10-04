import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/wallet_icon_helper.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/header_wallet_picker_dialog.dart';
import '../widgets/dialogs/wallet_list_modal.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_text_field.dart';
import 'add_transaction_screen.dart';
import 'wallet_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? initialWalletFilter;

  const TransactionHistoryScreen({super.key, this.initialWalletFilter});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedTypeFilter = 'Semua'; // 'Semua', 'Pemasukan', 'Pengeluaran'
  String _selectedWalletId = 'ALL'; // 'ALL' or specific wallet id
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // State Bulan & Tahun yang sedang dilihat
  late DateTime _selectedMonth;

  // State Dompet yang ditampilkan di Header (Maksimal 3)
  List<String> _headerWalletIds = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    if (widget.initialWalletFilter != null) {
      _selectedWalletId = widget.initialWalletFilter!;
    }
    _loadHeaderWalletsPref();
  }

  Future<void> _loadHeaderWalletsPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(HeaderWalletPickerDialog.prefsKey);
      if (savedStr != null) {
        final decoded = jsonDecode(savedStr);
        if (decoded is List) {
          setState(() {
            _headerWalletIds = decoded.map((e) => e.toString()).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading header wallet prefs: $e');
    }
  }

  /// Mendapatkan maksimal 3 dompet untuk baris header
  List<WalletModel> _resolveHeaderWallets(List<WalletModel> allWallets) {
    if (allWallets.isEmpty) return [];

    // Jika user sudah menyimpan pilihan di preferences
    if (_headerWalletIds.isNotEmpty) {
      final selectedList = <WalletModel>[];
      for (final id in _headerWalletIds) {
        final found = allWallets.where((w) => w.id == id).toList();
        if (found.isNotEmpty) {
          selectedList.add(found.first);
        }
      }

      // Jika ada dompet yang dihapus sehingga kurang dari 3, isi dengan dompet lain yang belum terpilih
      if (selectedList.length < 3 && selectedList.length < allWallets.length) {
        for (final w in allWallets) {
          if (!selectedList.any((sw) => sw.id == w.id)) {
            selectedList.add(w);
            if (selectedList.length == 3) break;
          }
        }
      }

      return selectedList.take(3).toList();
    }

    // Default: 3 dompet pertama
    return allWallets.take(3).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Dialog Gabungan Pemilih Bulan & Tahun (Tahun di atas, Bulan di bawah)
  Future<void> _showMonthYearPicker() async {
    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _MonthYearPickerDialog(initialDate: _selectedMonth),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedMonth = pickedDate;
      });
    }
  }

  Color _getCategoryColor(String? catName, String type) {
    if (type == 'INCOME') return AppColors.mintGreen;
    final cat = (catName ?? '').toLowerCase();
    if (cat.contains('makan') || cat.contains('food')) return AppColors.primaryYellow;
    if (cat.contains('trans') || cat.contains('kendaraan')) return AppColors.skyBlue;
    if (cat.contains('kopi') || cat.contains('coffee')) return AppColors.softPeach;
    if (cat.contains('belanja') || cat.contains('shop')) return AppColors.bubblePink;
    if (cat.contains('hiburan') || cat.contains('game')) return AppColors.bubblePink;
    if (cat.contains('telepon') || cat.contains('pulsa')) return AppColors.skyBlue;
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
    if (cat.contains('tagihan') || cat.contains('listrik')) return Icons.receipt_long_rounded;
    return Icons.category_rounded;
  }

  Map<String, List<TransactionModel>> _groupTransactions(
    List<TransactionModel> list,
  ) {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var tx in list) {
      // 1. Filter strictly by the selected Month & Year
      if (tx.date.year != _selectedMonth.year || tx.date.month != _selectedMonth.month) {
        continue;
      }

      // 2. Filter by wallet container
      if (_selectedWalletId != 'ALL') {
        if (tx.walletId != _selectedWalletId && tx.toWalletId != _selectedWalletId) {
          continue;
        }
      }

      // 3. Filter by type
      if (_selectedTypeFilter == 'Pemasukan' && tx.type != 'INCOME') continue;
      if (_selectedTypeFilter == 'Pengeluaran' && tx.type != 'EXPENSE') continue;

      // 4. Filter by search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final desc = tx.description.toLowerCase();
        final cat = (tx.categoryName ?? '').toLowerCase();
        if (!desc.contains(q) && !cat.contains(q)) continue;
      }

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
    final txProv = Provider.of<TransactionProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);
    final grouped = _groupTransactions(txProv.transactions);

    // Hitung akumulasi bulanan untuk bulan yang sedang dilihat (berdasarkan filter dompet jika dipilih)
    double currentMonthIncome = 0.0;
    double currentMonthExpense = 0.0;

    for (var tx in txProv.transactions) {
      if (tx.date.year == _selectedMonth.year && tx.date.month == _selectedMonth.month) {
        if (_selectedWalletId != 'ALL') {
          if (tx.walletId != _selectedWalletId && tx.toWalletId != _selectedWalletId) {
            continue;
          }
        }

        if (tx.type == 'INCOME') {
          currentMonthIncome += tx.amount;
        } else if (tx.type == 'EXPENSE') {
          currentMonthExpense += tx.amount;
        }
      }
    }

    final currentMonthNet = currentMonthIncome - currentMonthExpense;
    final onlyMonthFormatted = DateFormat('MMMM', 'id_ID').format(_selectedMonth);
    final onlyYearFormatted = _selectedMonth.year.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFD2EEFC), // Biru Muda Neo-Brutalist (Fresh & Kontras)
      body: SafeArea(
        child: Column(
          children: [
            // Custom Unified Top Ledger Table Header
            Container(
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderBlack,
                    width: 2.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowBlack,
                    offset: Offset(0, 3.0),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ==========================================
                  // BARIS 1: Bulan | Tahun | Pemasukan | Pengeluaran (Full Height, Tanpa Border Dalam)
                  // ==========================================
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      // 1. Pemilih Periode: Tahun di atas, Bulan di bawah (Satu Sel Tappable)
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
                                  onlyYearFormatted,
                                  style: const TextStyle(
                                    fontSize: 11,
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
                                        onlyMonthFormatted,
                                        style: const TextStyle(
                                          fontSize: 14.5,
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

                      // Garis Vertikal Pembatas
                      Container(width: 1.8, height: double.infinity, color: AppColors.borderBlack),

                      // 3. Pemasukan (Label di atas, Angka di bawah)
                      Expanded(
                        flex: 5,
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
                                    'Pemasukan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  CurrencyFormatter.formatRupiah(currentMonthIncome),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Garis Vertikal Pembatas
                      Container(width: 1.8, height: double.infinity, color: AppColors.borderBlack),

                      // 4. Pengeluaran (Label di atas, Angka di bawah)
                      Expanded(
                        flex: 5,
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
                                    'Pengeluaran',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  CurrencyFormatter.formatRupiah(currentMonthExpense),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFDC2626),
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

                // ==========================================
                // HR: Garis Pembatas Horizontal Penuh (Full Width)
                // ==========================================
                Container(
                  height: 1.8,
                  width: double.infinity,
                  color: AppColors.borderBlack,
                ),

                // ==========================================
                // BARIS 2: Ikon [Lihat Dompet] + Maks 3 Dompet + Ikon [Lainnya]
                // ==========================================
                Builder(
                  builder: (context) {
                    final displayWallets = _resolveHeaderWallets(walletProv.wallets);
                    final hasMoreThan3 = walletProv.wallets.length > 3;

                    final rowChildren = <Widget>[
                      // Tombol Ikon [Lihat Dompet] (Membuka Modal List Dompet & Total Uangnya)
                      _buildHeaderIconButton(
                        icon: Icons.account_balance_wallet_rounded,
                        backgroundColor: AppColors.butterYellow,
                        onTap: () {
                          WalletListModal.show(
                            context,
                            selectedWalletId: _selectedWalletId,
                            onSelectWallet: (id) => setState(() => _selectedWalletId = id),
                          );
                        },
                      ),
                      _buildHeaderVerticalDivider(1.8),
                    ];

                    // Maksimal 3 Dompet Terpilih di Header — dibagi rata (justify) memenuhi lebar
                    for (final w in displayWallets) {
                      rowChildren.add(
                        Expanded(
                          child: _buildWalletItem(
                            wallet: w,
                            isSelected: _selectedWalletId == w.id,
                            onTap: () {
                              setState(() {
                                // Toggle: kalau diklik lagi saat aktif, kembali ke semua dompet
                                if (_selectedWalletId == w.id) {
                                  _selectedWalletId = 'ALL';
                                } else {
                                  _selectedWalletId = w.id;
                                }
                              });
                            },
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WalletDetailScreen(wallet: w),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                      rowChildren.add(_buildHeaderVerticalDivider(1.6));
                    }

                    // Tombol Ikon [Lainnya] jika dompet > 3 untuk mengatur dompet mana yang tampil di header
                    if (hasMoreThan3) {
                      rowChildren.add(
                        _buildHeaderIconButton(
                          icon: Icons.tune_rounded,
                          backgroundColor: const Color(0xFFF1F5F9),
                          onTap: () {
                            HeaderWalletPickerDialog.show(
                              context,
                              allWallets: walletProv.wallets,
                              currentSelectedIds: displayWallets.map((w) => w.id).toList(),
                              onSaved: (selectedIds) {
                                setState(() {
                                  _headerWalletIds = selectedIds;
                                });
                              },
                            );
                          },
                        ),
                      );
                      rowChildren.add(_buildHeaderVerticalDivider(1.6));
                    }

                    return Container(
                      height: 48,
                      color: const Color(0xFFF9FAFC),
                      child: Row(children: rowChildren),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Baris Aksi Cepat: Sisa Saldo Bulan Ini + Filter Tipe + Tombol Catat Transaksi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                  // Sisa Saldo Badge
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderBlack, width: 1.6),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          offset: Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sisa: ',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                        ),
                        Text(
                          currentMonthNet < 0
                              ? '- ${CurrencyFormatter.formatShort(currentMonthNet.abs())}'
                              : CurrencyFormatter.formatShort(currentMonthNet),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: currentMonthNet >= 0
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filter Pills: [Semua] [Masuk] [Keluar]
                  _buildFilterPill('Semua'),
                  const SizedBox(width: 6),
                  _buildFilterPill('Pemasukan'),
                  const SizedBox(width: 6),
                  _buildFilterPill('Pengeluaran'),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Search Bar Ramping
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderBlack, width: 1.6),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Cari catatan transaksi...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textBlack, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // 3. Grouped Transaction List
            Expanded(
              child: grouped.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.mascotThinking,
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Belum ada transaksi di ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(
                                  initialDate: DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month,
                                    1,
                                  ),
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderBlack, width: 1.8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowBlack,
                                    offset: Offset(1.5, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Text(
                                '+ Catat di Bulan Ini',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 14, right: 14, top: 4, bottom: 84),
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, index) {
                          final dateHeader = grouped.keys.elementAt(index);
                          final txList = grouped[dateHeader]!;

                          return Padding(
                            padding: EdgeInsets.only(top: index == 0 ? 2 : 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Tanggal Lebih Jelas, Tegas & Beraksen Neo-Brutalist
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
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
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...txList.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final tx = entry.value;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildTransactionCard(tx),
                                      if (idx < txList.length - 1)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          child: Divider(
                                            color: AppColors.borderBlack.withValues(alpha: 0.2),
                                            thickness: 1.4,
                                            height: 1.4,
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack,
              offset: Offset(2.5, 3.0),
              blurRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(
                initialDate: DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month,
                  DateTime.now().month == _selectedMonth.month ? DateTime.now().day : 1,
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.primaryYellow,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 32,
            color: AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  /// Tombol ikon di Baris 2 header (lebar tetap agar konsisten & efisien)
  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44,
        height: double.infinity,
        color: backgroundColor,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.textBlack),
      ),
    );
  }

  /// Garis pembatas vertikal Baris 2 header
  Widget _buildHeaderVerticalDivider(double width) {
    return Container(
      width: width,
      height: double.infinity,
      color: AppColors.borderBlack,
    );
  }

  /// Item Dompet di Baris Bawah Header (mengisi lebar secara justify)
  Widget _buildWalletItem({
    required dynamic wallet,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    final name = wallet.name as String;
    final bal = wallet.balance as double;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        color: isSelected ? AppColors.butterYellow : Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.textBlack,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.formatShort(bal),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedTypeFilter == label;
    final shortLabel = label == 'Pemasukan'
        ? 'Masuk'
        : label == 'Pengeluaran'
            ? 'Keluar'
            : label;

    return GestureDetector(
      onTap: () => setState(() => _selectedTypeFilter = label),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textBlack : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderBlack, width: 1.6),
          boxShadow: isSelected
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.shadowBlack,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          shortLabel,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  void _showTransactionActionsModal(TransactionModel tx) {
    final isIncome = tx.type == 'INCOME';
    final isTransfer = tx.type == 'TRANSFER';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.5),
              left: BorderSide(color: AppColors.borderBlack, width: 2.5),
              right: BorderSide(color: AppColors.borderBlack, width: 2.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderBlack.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Info singkat transaksi
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
                          color: _getCategoryColor(tx.categoryName, tx.type),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderBlack, width: 1.4),
                        ),
                        child: Icon(
                          _getCategoryIcon(tx.categoryName, tx.type),
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
                              tx.description.isNotEmpty
                                  ? tx.description
                                  : (tx.categoryName ?? 'Transaksi'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(tx.date)} • ${tx.walletName ?? 'Dompet'}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Edit Transaksi
                NeoButton(
                  label: 'Edit Transaksi',
                  icon: Icons.edit_rounded,
                  backgroundColor: AppColors.primaryYellow,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    _openEditTransactionModal(tx);
                  },
                ),
                const SizedBox(height: 10),

                // Tombol Hapus Transaksi
                NeoButton(
                  label: 'Hapus Transaksi',
                  icon: Icons.delete_outline_rounded,
                  backgroundColor: const Color(0xFFFCA5A5),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Hapus Transaksi?'),
                        content: const Text(
                            'Tindakan ini akan mengembalikan saldo dompet seperti semula.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, true),
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await Provider.of<TransactionProvider>(context, listen: false)
                          .deleteTransaction(tx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaksi berhasil dihapus')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditTransactionModal(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditTransactionSheet(transaction: tx),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    final isIncome = tx.type == 'INCOME';
    final isTransfer = tx.type == 'TRANSFER';
    final isAdjustment = tx.type == 'ADJUSTMENT';

    final categoryColor = _getCategoryColor(tx.categoryName, tx.type);
    final categoryIcon = _getCategoryIcon(tx.categoryName, tx.type);

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Transaksi?'),
            content: const Text('Tindakan ini akan mengembalikan saldo seperti semula.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<TransactionProvider>(context, listen: false)
            .deleteTransaction(tx);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionActionsModal(tx),
          child: NeoCard(
            backgroundColor: AppColors.cardWhite,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: 16,
            borderWidth: 1.8,
            child: Row(
            children: [
              // Category Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isTransfer
                      ? AppColors.skyBlue
                      : isAdjustment
                          ? AppColors.softPeach
                          : categoryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderBlack, width: 1.6),
                ),
                child: Icon(
                  isTransfer
                      ? Icons.sync_alt_rounded
                      : isAdjustment
                          ? Icons.published_with_changes_rounded
                          : categoryIcon,
                  size: 20,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(width: 10),

              // Title, Wallet & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description.isNotEmpty
                          ? tx.description
                          : (tx.categoryName ?? 'Transaksi'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(tx.date),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.pillGray,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderBlack, width: 0.8),
                            ),
                            child: Text(
                              isTransfer
                                  ? '${tx.walletName ?? 'Dompet'} ➔ ${tx.toWalletName ?? 'Akun'}'
                                  : tx.walletName ?? 'Dompet',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Amount Nominal
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.45,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(tx.amount)}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isIncome
                              ? const Color(0xFF16A34A)
                              : isTransfer
                                  ? AppColors.textBlack
                                  : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    if (tx.subType == 'LOST_MONEY') ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Uang Hilang',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dangerRed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

/// Bottom sheet untuk mengedit transaksi
class _EditTransactionSheet extends StatefulWidget {
  final TransactionModel transaction;

  const _EditTransactionSheet({required this.transaction});

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late String _selectedType;
  late String? _selectedCategoryId;
  late String _selectedWalletId;
  String? _selectedToWalletId;
  late DateTime _selectedDate;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _selectedType = tx.type;
    _selectedCategoryId = tx.categoryId;
    _selectedWalletId = tx.walletId;
    _selectedToWalletId = tx.toWalletId;
    _selectedDate = tx.transactionDate;

    _amountController.text = _currencyFormat.format(tx.amount.toInt());
    _descController.text = tx.description;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    if (val.isEmpty) return;
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      _amountController.value = const TextEditingValue(text: '');
      return;
    }
    final number = int.tryParse(clean) ?? 0;
    final formatted = _currencyFormat.format(number);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _handleSave() async {
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(rawAmount) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0!')),
      );
      return;
    }

    final isTransfer = _selectedType == 'TRANSFER';
    if (isTransfer &&
        (_selectedToWalletId == null ||
            _selectedToWalletId == _selectedWalletId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rekening tujuan transfer yang berbeda!'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);

    try {
      final desc = _descController.text.trim();
      final updatedTx = widget.transaction.copyWith(
        walletId: _selectedWalletId,
        toWalletId: isTransfer ? _selectedToWalletId : null,
        categoryId: isTransfer ? null : _selectedCategoryId,
        type: _selectedType,
        amount: amount,
        description: desc.isNotEmpty ? desc : (widget.transaction.categoryName ?? 'Transaksi'),
        transactionDate: _selectedDate,
      );

      await txProv.updateTransaction(widget.transaction, updatedTx);
      await walletProv.loadWallets();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final isTransfer = _selectedType == 'TRANSFER';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.butterYellow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.borderBlack, width: 2.5),
            left: BorderSide(color: AppColors.borderBlack, width: 2.5),
            right: BorderSide(color: AppColors.borderBlack, width: 2.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Edit Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlack, width: 1.8),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textBlack),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nominal Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderBlack, width: 2),
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
                      Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _selectedType == 'INCOME'
                              ? const Color(0xFF16A34A)
                              : isTransfer
                                  ? AppColors.textBlack
                                  : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: _onAmountChanged,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: '0',
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Wadah / Dompet
                Text(
                  isTransfer ? 'Dari Rekening Asal:' : 'Wadah / Dompet:',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                _buildWalletPickerDropdown(
                  walletProv: walletProv,
                  value: _selectedWalletId,
                  onChanged: (id) {
                    if (id != null) setState(() => _selectedWalletId = id);
                  },
                ),

                if (isTransfer) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Ke Rekening Tujuan:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildWalletPickerDropdown(
                    walletProv: walletProv,
                    value: _selectedToWalletId,
                    hint: 'Pilih rekening tujuan',
                    excludeId: _selectedWalletId,
                    onChanged: (id) => setState(() => _selectedToWalletId = id),
                  ),
                ],

                const SizedBox(height: 14),

                // Tanggal
                Row(
                  children: [
                    const Text(
                      'Tanggal:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderBlack, width: 1.6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.textBlack),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Catatan
                NeoTextField(
                  controller: _descController,
                  labelText: 'Catatan Transaksi',
                  hintText: 'Misal: Makan Siang / Beli Pulsa',
                  prefixIcon: Icons.edit_note_rounded,
                ),
                const SizedBox(height: 20),

                // Simpan Perubahan
                NeoButton(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.primaryYellow,
                  onPressed: _isSaving ? null : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletPickerDropdown({
    required WalletProvider walletProv,
    required String? value,
    required ValueChanged<String?> onChanged,
    String? hint,
    String? excludeId,
  }) {
    final items = walletProv.wallets
        .where((w) => excludeId == null || w.id != excludeId)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderBlack, width: 1.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.any((w) => w.id == value) ? value : null,
          hint: hint != null
              ? Text(hint, style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted))
              : null,
          items: items.map((w) {
            return DropdownMenuItem(
              value: w.id,
              child: Row(
                children: [
                  Icon(WalletIconHelper.resolve(w.icon), size: 18, color: AppColors.textBlack),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${w.name} (${CurrencyFormatter.formatShort(w.balance)})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Dialog pemilih Periode gabungan (Tahun di atas berupa strip horizontal, Bulan di bawah berupa grid 3x4).
class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _MonthYearPickerDialog({required this.initialDate});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  static const int _yearsBefore = 30;
  static const int _yearsAfter = 10;
  static const double _chipWidth = 74.0;

  late int _selectedYear;
  late int _selectedMonth;
  late final int _currentYear;
  late final int _minYear;
  late final int _maxYear;
  late final ScrollController _scrollController;

  final List<String> _monthNames = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _currentYear = DateTime.now().year;
    _minYear = _currentYear - _yearsBefore;
    _maxYear = _currentYear + _yearsAfter;

    final selectedIndex = _selectedYear - _minYear;
    final initialOffset = (selectedIndex * (_chipWidth + 8)) - 100.0;
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset < 0 ? 0 : initialOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.butterYellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pilih Periode',
            style: TextStyle(
              fontSize: 16.5,
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
              child: const Icon(Icons.close, size: 16, color: AppColors.textBlack),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label Section Tahun
            const Text(
              'Tahun:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),

            // Strip Horizontal Pilihan Tahun
            SizedBox(
              height: 42,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _maxYear - _minYear + 1,
                itemBuilder: (context, idx) {
                  final year = _minYear + idx;
                  final isSelected = _selectedYear == year;
                  final isCurrentYear = _currentYear == year;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedYear = year;
                        });
                      },
                      child: Container(
                        width: _chipWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryYellow
                              : AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderBlack,
                            width: isSelected ? 2.2 : 1.4,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$year',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: AppColors.textBlack,
                              ),
                            ),
                            if (isCurrentYear) ...[
                              const SizedBox(width: 3),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Label Section Bulan
            const Text(
              'Bulan:',
              style: TextStyle(
                fontSize: 12,
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
                final isSelected = _selectedMonth == monthNum &&
                    _selectedYear == widget.initialDate.year;

                return GestureDetector(
                  onTap: () {
                    // Tap bulan langsung konfirmasi dan tutup dialog
                    Navigator.pop(
                      context,
                      DateTime(_selectedYear, monthNum, 1),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mintGreen
                          : AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderBlack,
                        width: isSelected ? 2.2 : 1.4,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: AppColors.shadowBlack,
                                offset: Offset(1.5, 1.5),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _monthNames[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
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
    );
  }
}
