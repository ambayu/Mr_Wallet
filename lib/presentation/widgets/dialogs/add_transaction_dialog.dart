import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';
import 'camera_bill_snap_modal.dart';

class AddTransactionDialog extends StatefulWidget {
  final String? initialType;

  const AddTransactionDialog({super.key, this.initialType});

  static Future<void> show(BuildContext context, {String? initialType}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionDialog(initialType: initialType),
    );
  }

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late String _selectedType; // EXPENSE, INCOME, TRANSFER
  late String _selectedWalletId;
  String? _selectedToWalletId;
  String? _selectedCategoryId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? 'EXPENSE';
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    _selectedWalletId = walletProv.selectedWalletId ??
        (walletProv.wallets.isNotEmpty ? walletProv.wallets.first.id : 'w_cash');
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    if (txProv.categories.isNotEmpty) {
      _selectedCategoryId = txProv.categories.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
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

    setState(() => _isSaving = true);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);

    try {
      if (_selectedType == 'TRANSFER') {
        if (_selectedToWalletId == null || _selectedToWalletId == _selectedWalletId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih rekening tujuan transfer yang berbeda!')),
          );
          setState(() => _isSaving = false);
          return;
        }
        await txProv.addTransfer(
          fromWalletId: _selectedWalletId,
          toWalletId: _selectedToWalletId!,
          amount: amount,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : 'Transfer Saldo',
          date: _selectedDate,
        );
      } else {
        await txProv.addTransaction(
          walletId: _selectedWalletId,
          categoryId: _selectedCategoryId ?? 'cat_food',
          type: _selectedType,
          amount: amount,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : (_selectedType == 'INCOME' ? 'Pemasukan' : 'Pengeluaran'),
          transactionDate: _selectedDate,
        );
      }
      await walletProv.loadWallets();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: const BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.borderBlack, width: 2.5),
            left: BorderSide(color: AppColors.borderBlack, width: 2.5),
            right: BorderSide(color: AppColors.borderBlack, width: 2.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 1.6),
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Segmented Toggle matching Showcase Screen 6: [Pengeluaran] [Pemasukan] [Transfer]
              Row(
                children: [
                  _buildTypeTab('EXPENSE', 'Pengeluaran'),
                  const SizedBox(width: 8),
                  _buildTypeTab('INCOME', 'Pemasukan'),
                  const SizedBox(width: 8),
                  _buildTypeTab('TRANSFER', 'Transfer'),
                ],
              ),
              const SizedBox(height: 18),

              // Nominal Section
              const Text(
                'Nominal',
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                    hintText: '0',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Kategori Dropdown (if not transfer)
              if (_selectedType != 'TRANSFER') ...[
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCategoryId,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textBlack),
                      items: txProv.categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              const Icon(Icons.fastfood_rounded, size: 18, color: AppColors.textBlack),
                              const SizedBox(width: 8),
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Sumber Dompet & Rekening Tujuan (if Transfer)
              const Text(
                'Pilih Dompet / Akun',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderBlack, width: 1.8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedWalletId,
                    items: walletProv.wallets.map((w) {
                      return DropdownMenuItem(
                        value: w.id,
                        child: Text(
                          '${w.name} (${w.type.toUpperCase()})',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedWalletId = val);
                    },
                  ),
                ),
              ),

              if (_selectedType == 'TRANSFER') ...[
                const SizedBox(height: 14),
                const Text(
                  'Ke Dompet Tujuan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedToWalletId,
                      hint: const Text('Pilih rekening tujuan'),
                      items: walletProv.wallets
                          .where((w) => w.id != _selectedWalletId)
                          .map((w) {
                        return DropdownMenuItem(
                          value: w.id,
                          child: Text(
                            '${w.name} (${w.type.toUpperCase()})',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedToWalletId = val);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Tanggal
              const Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.textBlack),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Catatan
              NeoTextField(
                controller: _descController,
                labelText: 'Catatan',
                hintText: 'Contoh: Makan siang di kantor',
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 16),

              // "📷 Tambah Foto Struk" Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  CameraBillSnapModal.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt_outlined, color: AppColors.textBlack, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tambah Foto Struk',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mascot Quote Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderBlack, width: 1.8),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.mascotThumbsUp,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Catat setiap langkah, keuangan makin sehat! 🦀',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pink CTA Button: "Simpan"
              NeoButton(
                label: _isSaving ? 'Menyimpan...' : 'Simpan',
                backgroundColor: AppColors.bubblePink,
                textColor: AppColors.textBlack,
                height: 52,
                borderRadius: 26,
                onPressed: _isSaving ? null : _handleSave,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String typeKey, String label) {
    final isSelected = _selectedType == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = typeKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
