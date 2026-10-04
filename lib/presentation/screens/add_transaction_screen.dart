import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/category_group_helper.dart';
import '../../core/utils/category_icon_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/wallet_icon_helper.dart';
import '../../data/models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_category_dialog.dart';
import '../widgets/dialogs/ai_text_modal.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/dialogs/camera_bill_snap_modal.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_text_field.dart';

/// Halaman penuh "Catat Transaksi" (Gaya Grid Ikon Terkurasi ala Referensi).
///
/// Alur:
/// 1. Tab segmentasi atas: [Pengeluaran] [Pemasukan] [Transfer].
/// 2. Grid 4 kolom berisi seluruh ikon kategori (makanan, belanja, telepon, hiburan, dll).
/// 3. Saat kategori diketuk, muncul panel mengambang (bottom sheet) untuk mengisi nominal,
///    dompet sumber, tanggal, dan catatan.
class AddTransactionScreen extends StatefulWidget {
  final String? initialWalletId;
  final DateTime? initialDate;

  const AddTransactionScreen({
    super.key,
    this.initialWalletId,
    this.initialDate,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Tab aktif: EXPENSE (Pengeluaran), INCOME (Pemasukan), TRANSFER (Transfer Saldo)
  String _selectedTab = 'EXPENSE';

  Future<void> _openFormSheet(CategoryModel category, {String? type}) async {
    final effectiveType = type ?? _selectedTab;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TransactionFormSheet(
        initialCategory: category,
        initialType: effectiveType,
        initialWalletId: widget.initialWalletId,
        initialDate: widget.initialDate ?? DateTime.now(),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan! 🎉'),
          backgroundColor: AppColors.textBlack,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    final categories = txProv.categories;

    return Scaffold(
      backgroundColor: AppColors.butterYellow,
      appBar: AppBar(
        backgroundColor: AppColors.butterYellow,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderBlack, width: 2.2),
        ),
        title: Row(
          children: [
            // Tombol "Batalkan"
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
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
                    Icon(Icons.close_rounded, size: 16, color: AppColors.textBlack),
                    SizedBox(width: 4),
                    Text(
                      'Batalkan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Tambahkan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            // Tombol Rekonsiliasi Saldo & Scan Struk di pojok kanan
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => BalanceAdjustmentDialog.show(
                    context,
                    initialWalletId: widget.initialWalletId,
                    initialMonthDate: widget.initialDate,
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          offset: Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => CameraBillSnapModal.show(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack,
                          offset: Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Control: [Pengeluaran] [Pemasukan] [Transfer]
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
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
                child: Row(
                  children: [
                    Expanded(child: _buildSegmentButton('EXPENSE', 'Pengeluaran')),
                    Expanded(child: _buildSegmentButton('INCOME', 'Pemasukan')),
                    Expanded(child: _buildSegmentButton('TRANSFER', 'Transfer')),
                  ],
                ),
              ),
            ),

            // Content Area: Grid 4 Kolom Kategori atau Panel Transfer
            Expanded(
              child: _selectedTab == 'TRANSFER'
                  ? _buildTransferPrompt(categories)
                  : _buildCategoryGrid(categories),
            ),

            // Bottom Prompt Bar (Kolom AI Teks dengan Riwayat & Menu Konfirmasi)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: GestureDetector(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final committed = await AITextModal.show(context);
                  if (committed == true && mounted) {
                    navigator.pop();
                  }
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(24),
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
                      const Icon(Icons.auto_awesome,
                          color: Color(0xFF8B5CF6), size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Untuk apa dan berapa harganya? (Ketik bebas / AI)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => CameraBillSnapModal.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.butterYellow,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.borderBlack, width: 1.4),
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 16, color: AppColors.textBlack),
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
    );
  }

  Widget _buildSegmentButton(String type, String label) {
    final isSelected = _selectedTab == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.borderBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? AppColors.primaryYellow : AppColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildEmptyCategories(),
        ),
      );
    }

    final sections = CategoryGroupHelper.groupCategories(
      categories,
      activeTab: _selectedTab,
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: sections.length,
      itemBuilder: (context, sectionIdx) {
        final section = sections[sectionIdx];
        final isLastSection = sectionIdx == sections.length - 1;
        final itemCount = section.categories.length + (isLastSection ? 1 : 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGroupHeader(section.title),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.84,
              ),
              itemBuilder: (context, idx) {
                if (isLastSection && idx == section.categories.length) {
                  return _buildAddCategoryTile();
                }
                final category = section.categories[idx];
                return _buildCategoryGridItem(category);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 10, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1.6,
              color: const Color(0x401E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem(CategoryModel category) {
    final iconData = CategoryIconHelper.resolve(category.icon);

    return GestureDetector(
      onTap: () => _openFormSheet(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  offset: Offset(1.5, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              iconData,
              size: 24,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryTile() {
    return GestureDetector(
      onTap: () => AddCategoryDialog.show(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderBlack,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  offset: Offset(1.5, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 26,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambah',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferPrompt(List<CategoryModel> categories) {
    final transferCat = categories.firstWhere(
      (c) => c.type == 'TRANSFER' || c.icon == 'sync_alt',
      orElse: () => categories.isNotEmpty
          ? categories.first
          : CategoryModel(
              id: 'c_transfer',
              name: 'Transfer Saldo',
              type: 'TRANSFER',
              icon: 'sync_alt',
              color: '#C4D7FF',
            ),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(24),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                ),
                child: const Icon(Icons.sync_alt_rounded,
                    size: 30, color: AppColors.textBlack),
              ),
              const SizedBox(height: 14),
              const Text(
                'Transfer Antar Rekening',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pindahkan uang antar dompet tunai, ATM, atau e-wallet tanpa memengaruhi catatan pemasukan/pengeluaran bersih.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              NeoButton(
                label: 'Isi Data Transfer',
                icon: Icons.arrow_forward_rounded,
                backgroundColor: AppColors.primaryYellow,
                onPressed: () => _openFormSheet(transferCat, type: 'TRANSFER'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCategories() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlack, width: 1.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.category_outlined, color: AppColors.textMuted),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Belum ada kategori. Tambahkan kategori baru dulu ya.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => AddCategoryDialog.show(context),
            child: const Text(
              'Tambah',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel mengambang (bottom sheet) yang muncul setelah kategori dipilih.
class _TransactionFormSheet extends StatefulWidget {
  final CategoryModel initialCategory;
  final String? initialType;
  final String? initialWalletId;
  final DateTime initialDate;

  const _TransactionFormSheet({
    required this.initialCategory,
    this.initialType,
    required this.initialWalletId,
    required this.initialDate,
  });

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  late String _selectedType; // EXPENSE, INCOME, TRANSFER
  late String _selectedCategoryId;
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
    _selectedType = widget.initialType ?? widget.initialCategory.type;
    _selectedCategoryId = widget.initialCategory.id;
    _selectedDate = widget.initialDate;

    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    if (widget.initialWalletId != null) {
      _selectedWalletId = widget.initialWalletId!;
    } else if (walletProv.wallets.isNotEmpty) {
      final def = walletProv.wallets.firstWhere(
        (w) => w.isDefault,
        orElse: () => walletProv.wallets.first,
      );
      _selectedWalletId = def.id;
    } else {
      _selectedWalletId = 'w_cash';
    }
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
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final desc = _descController.text.trim();
      if (isTransfer) {
        await txProv.addTransaction(
          walletId: _selectedWalletId,
          toWalletId: _selectedToWalletId,
          type: 'TRANSFER',
          amount: amount,
          description: desc.isNotEmpty ? desc : 'Transfer Saldo',
          transactionDate: _selectedDate,
        );
      } else {
        final cat = txProv.categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => widget.initialCategory,
        );
        await txProv.addTransaction(
          walletId: _selectedWalletId,
          categoryId: cat.id,
          type: _selectedType,
          amount: amount,
          description: desc.isNotEmpty ? desc : cat.name,
          transactionDate: _selectedDate,
        );
      }
      await walletProv.loadWallets();
      if (mounted) navigator.pop(true);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
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
    final txProv = Provider.of<TransactionProvider>(context);
    final isTransfer = _selectedType == 'TRANSFER';

    final currentCategory = txProv.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => widget.initialCategory,
    );

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
                // Header: kategori terpilih
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.borderBlack, width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        CategoryIconHelper.resolve(currentCategory.icon),
                        size: 22,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentCategory.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTransfer
                                  ? AppColors.skyBlue
                                  : (_selectedType == 'INCOME'
                                      ? AppColors.mintGreen
                                      : AppColors.bubblePink),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.borderBlack, width: 0.9),
                            ),
                            child: Text(
                              isTransfer
                                  ? 'Transfer Saldo'
                                  : (_selectedType == 'INCOME'
                                      ? 'Pemasukan'
                                      : 'Pengeluaran'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.borderBlack, width: 1.6),
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textBlack),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nominal uang
                const Text(
                  'Nominal Uang',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
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
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: _onAmountChanged,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 14, right: 6, top: 12),
                        child: Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dompet sumber
                const Text(
                  'Dompet Sumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                _buildWalletDropdown(
                  walletProv: walletProv,
                  value: _selectedWalletId,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedWalletId = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                if (isTransfer) ...[
                  const Text(
                    'Dompet Tujuan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildWalletDropdown(
                    walletProv: walletProv,
                    value: _selectedToWalletId,
                    hint: 'Pilih rekening tujuan',
                    excludeId: _selectedWalletId,
                    onChanged: (val) =>
                        setState(() => _selectedToWalletId = val),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tanggal transaksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tanggal Transaksi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 16, color: AppColors.textBlack),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('d MMMM yyyy', 'id_ID')
                                   .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 12.5,
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
                const SizedBox(height: 16),

                // Catatan
                NeoTextField(
                  controller: _descController,
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Misal: Nasi Goreng Komplit / Bayar Wifi',
                  prefixIcon: Icons.edit_note_rounded,
                ),
                const SizedBox(height: 22),

                // Simpan
                NeoButton(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan Transaksi',
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

  Widget _buildWalletDropdown({
    required WalletProvider walletProv,
    required String? value,
    required ValueChanged<String?> onChanged,
    String? hint,
    String? excludeId,
  }) {
    if (walletProv.wallets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderBlack, width: 1.8),
        ),
        child: const Text(
          'Belum ada wadah rekening.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    final items = walletProv.wallets
        .where((w) => excludeId == null || w.id != excludeId)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderBlack, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack,
            offset: Offset(2, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.any((w) => w.id == value) ? value : null,
          hint: hint != null
              ? Text(hint,
                  style: const TextStyle(
                      fontSize: 13.5, color: AppColors.textMuted))
              : null,
          items: items.map((w) {
            return DropdownMenuItem(
              value: w.id,
              child: Row(
                children: [
                  Icon(WalletIconHelper.resolve(w.icon),
                      size: 18, color: AppColors.textBlack),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${w.name} (${CurrencyFormatter.formatShort(w.balance)})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
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
