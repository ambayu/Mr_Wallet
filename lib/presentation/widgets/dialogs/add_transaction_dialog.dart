import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_badge.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

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
  final DateTime _selectedDate = DateTime.now();
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

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
                    'Catat Transaksi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.bubblePink,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 2),
                      ),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Type Selector Chips (EXPENSE / INCOME / TRANSFER)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'EXPENSE'),
                      child: NeoBadge(
                        text: 'Pengeluaran',
                        backgroundColor: _selectedType == 'EXPENSE'
                            ? AppColors.coralOrange
                            : AppColors.cardWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'INCOME'),
                      child: NeoBadge(
                        text: 'Pemasukan',
                        backgroundColor: _selectedType == 'INCOME'
                            ? AppColors.mintGreen
                            : AppColors.cardWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'TRANSFER'),
                      child: NeoBadge(
                        text: 'Transfer',
                        backgroundColor: _selectedType == 'TRANSFER'
                            ? AppColors.skyBlue
                            : AppColors.cardWhite,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Amount Input
              NeoTextField(
                controller: _amountController,
                labelText: 'Nominal (Rp)',
                hintText: 'Contoh: 25000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 14),

              // Wallet Selector
              Text(
                _selectedType == 'TRANSFER' ? 'Dari Rekening:' : 'Pilih Wadah Dana:',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: walletProv.wallets.map((w) {
                    final isSelected = w.id == _selectedWalletId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedWalletId = w.id),
                        child: NeoBadge(
                          text: w.name,
                          backgroundColor:
                              isSelected ? AppColors.lavenderPurple : AppColors.cardWhite,
                          borderWidth: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Destination Wallet if Transfer
              if (_selectedType == 'TRANSFER') ...[
                const Text(
                  'Ke Rekening Tujuan:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: walletProv.wallets
                        .where((w) => w.id != _selectedWalletId)
                        .map((w) {
                      final isSelected = w.id == _selectedToWalletId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedToWalletId = w.id),
                          child: NeoBadge(
                            text: w.name,
                            backgroundColor: isSelected
                                ? AppColors.mintGreen
                                : AppColors.cardWhite,
                            borderWidth: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Category Selector (if not Transfer)
              if (_selectedType != 'TRANSFER') ...[
                const Text(
                  'Kategori:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: txProv.categories.map((c) {
                      final isSelected = c.id == _selectedCategoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategoryId = c.id),
                          child: NeoBadge(
                            text: c.name,
                            backgroundColor: isSelected
                                ? AppColors.bubblePink
                                : AppColors.cardWhite,
                            borderWidth: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Description
              NeoTextField(
                controller: _descController,
                labelText: 'Keterangan / Catatan',
                hintText: 'Misal: Kopi kenangan siang hari',
              ),
              const SizedBox(height: 24),

              // Save Button
              NeoButton(
                label: _isSaving ? 'Menyimpan...' : 'Simpan Transaksi',
                icon: Icons.save_alt_rounded,
                backgroundColor: AppColors.bubblePink,
                onPressed: _amountController.text.isEmpty || _isSaving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final amt = double.tryParse(_amountController.text
                                .replaceAll('.', '')
                                .replaceAll(',', '')) ??
                            0.0;
                        if (amt <= 0) return;

                        setState(() => _isSaving = true);
                        await txProv.addTransaction(
                          walletId: _selectedWalletId,
                          toWalletId: _selectedType == 'TRANSFER'
                              ? _selectedToWalletId
                              : null,
                          categoryId: _selectedCategoryId,
                          type: _selectedType,
                          amount: amt,
                          description: _descController.text.trim().isNotEmpty
                              ? _descController.text.trim()
                              : (_selectedType == 'TRANSFER'
                                  ? 'Transfer Antar Rekening'
                                  : 'Transaksi'),
                          transactionDate: _selectedDate,
                        );

                        await walletProv.loadWallets();

                        if (mounted) {
                          setState(() => _isSaving = false);
                          navigator.pop();
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
