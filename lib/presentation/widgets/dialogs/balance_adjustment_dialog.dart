import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_badge.dart';
import '../neo_button.dart';
import '../neo_card.dart';
import '../neo_text_field.dart';

class BalanceAdjustmentDialog extends StatefulWidget {
  final String? initialWalletId;
  final DateTime? initialMonthDate;

  const BalanceAdjustmentDialog({
    super.key,
    this.initialWalletId,
    this.initialMonthDate,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialWalletId,
    DateTime? initialMonthDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BalanceAdjustmentDialog(
        initialWalletId: initialWalletId,
        initialMonthDate: initialMonthDate,
      ),
    );
  }

  @override
  State<BalanceAdjustmentDialog> createState() =>
      _BalanceAdjustmentDialogState();
}

class _BalanceAdjustmentDialogState extends State<BalanceAdjustmentDialog> {
  late String _selectedWalletId;
  final TextEditingController _realBalanceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedSubType = 'LOST_MONEY'; // LOST_MONEY, ADMIN_FEE, INTEREST, REGULAR
  double _realBalance = 0.0;
  bool _isSaving = false;

  final Map<String, String> _subTypeLabels = {
    'LOST_MONEY': 'Uang Hilang / Receh Jatuh',
    'ADMIN_FEE': 'Biaya Admin Bank',
    'INTEREST': 'Bunga Tabungan',
    'REGULAR': 'Koreksi Saldo Manual',
  };

  @override
  void initState() {
    super.initState();
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    _selectedWalletId = widget.initialWalletId ??
        walletProv.selectedWalletId ??
        (walletProv.wallets.isNotEmpty ? walletProv.wallets.first.id : 'w_cash');
  }

  @override
  void dispose() {
    _realBalanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final selectedWallet = walletProv.wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
      orElse: () => walletProv.wallets.isNotEmpty
          ? walletProv.wallets.first
          : walletProv.wallets.first,
    );

    final double systemBalance = selectedWallet.balance;
    final double delta = _realBalance - systemBalance;
    final double absDelta = delta.abs();

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekonsiliasi Saldo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        'Deteksi Uang Hilang & Selisih Saldo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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
              const SizedBox(height: 20),

              // Wallet Selector Dropdown (Wadah Rekening)
              const Text(
                'Pilih Wadah Rekening:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWalletId,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, size: 28, color: AppColors.textBlack),
                    dropdownColor: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    onChanged: (newId) {
                      if (newId != null) {
                        setState(() => _selectedWalletId = newId);
                      }
                    },
                    items: walletProv.wallets.map((w) {
                      return DropdownMenuItem<String>(
                        value: w.id,
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.textBlack),
                            const SizedBox(width: 10),
                            Text(
                              w.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.formatShort(w.balance),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // System vs Real Balance Comparison Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo di Sistem:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(systemBalance),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderBlack, height: 20),
                    NeoTextField(
                      controller: _realBalanceController,
                      labelText: 'Berapa Saldo Riil / Fisik Saat Ini?',
                      hintText: 'Contoh: 30000',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.account_balance_wallet,
                      onChanged: (val) {
                        setState(() {
                          _realBalance = double.tryParse(val.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Delta Badge Output
                    if (_realBalanceController.text.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: delta < 0
                              ? const Color(0xFFFFD4D4)
                              : const Color(0xFFD5F5E3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              delta < 0 ? '⚠️ Selisih Kurang (Hilang):' : '✨ Selisih Lebih:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${delta < 0 ? "-" : "+"} ${CurrencyFormatter.format(absDelta)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: delta < 0
                                    ? const Color(0xFFC0392B)
                                    : const Color(0xFF27AE60),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SubType Reason Selector
              const Text(
                'Alasan / Kategori Selisih:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subTypeLabels.entries.map((entry) {
                  final isSelected = _selectedSubType == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSubType = entry.key),
                    child: NeoBadge(
                      text: entry.value,
                      backgroundColor: isSelected
                          ? AppColors.lavenderPurple
                          : AppColors.cardWhite,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Note Field
              NeoTextField(
                controller: _noteController,
                labelText: 'Catatan Opsional',
                hintText: 'Misal: Receh jatuh di jalan / saku celana',
              ),
              const SizedBox(height: 24),

              // Submit Button
              NeoButton(
                label: _isSaving ? 'Menyimpan...' : 'Sinkronkan Saldo Riil Sekarang',
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.mintGreen,
                onPressed: _realBalanceController.text.isEmpty || _isSaving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isSaving = true);
                        final txProv = Provider.of<TransactionProvider>(
                            context,
                            listen: false);

                        DateTime? recordDate;
                        if (widget.initialMonthDate != null) {
                          final now = DateTime.now();
                          if (widget.initialMonthDate!.year == now.year &&
                              widget.initialMonthDate!.month == now.month) {
                            recordDate = now;
                          } else {
                            final daysInMonth = DateTime(
                              widget.initialMonthDate!.year,
                              widget.initialMonthDate!.month + 1,
                              0,
                            ).day;
                            recordDate = DateTime(
                              widget.initialMonthDate!.year,
                              widget.initialMonthDate!.month,
                              daysInMonth,
                              23,
                              59,
                            );
                          }
                        }

                        await txProv.reconcileWalletBalance(
                          walletId: _selectedWalletId,
                          actualBalance: _realBalance,
                          subType: _selectedSubType,
                          customNote: _noteController.text.trim().isNotEmpty
                              ? _noteController.text.trim()
                              : null,
                          transactionDate: recordDate,
                        );

                        await walletProv.loadWallets();

                        if (mounted) {
                          setState(() => _isSaving = false);
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.borderBlack,
                              content: Text(
                                'Saldo berhasil diselaraskan ke ${CurrencyFormatter.format(_realBalance)}!',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
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
