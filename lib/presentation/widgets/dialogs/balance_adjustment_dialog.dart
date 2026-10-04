import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late DateTime _selectedPeriod;
  final TextEditingController _realBalanceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final NumberFormat _currencyFormatter = NumberFormat.decimalPattern('id_ID');
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
    _selectedPeriod = widget.initialMonthDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _realBalanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    String cleanText = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      setState(() {
        _realBalance = 0.0;
      });
      return;
    }

    final numVal = double.tryParse(cleanText) ?? 0.0;
    final formatted = _currencyFormatter.format(numVal);

    if (_realBalanceController.text != formatted) {
      _realBalanceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    setState(() {
      _realBalance = numVal;
    });
  }

  Future<void> _pickMonthYear() async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _AdjustmentMonthYearPickerDialog(initialDate: _selectedPeriod),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedPeriod = result;
      });
    }
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
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(_selectedPeriod);

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
              const SizedBox(height: 16),

              // Baris Pemilih Periode Bulan/Tahun
              const Text(
                'Periode Rekonsiliasi:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickMonthYear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.textBlack),
                          const SizedBox(width: 8),
                          Text(
                            monthName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down_rounded, size: 24, color: AppColors.textBlack),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Wallet Selector Dropdown (Wadah Rekening)
              const Text(
                'Pilih Wadah Rekening:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 6),
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
                          CurrencyFormatter.formatRupiah(systemBalance),
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
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.account_balance_wallet,
                      onChanged: _onAmountChanged,
                    ),
                    const SizedBox(height: 14),

                    // Delta Badge Output (Multi-Row / Responsive agar bebas overflow)
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
                            Expanded(
                              child: Text(
                                delta < 0 ? '⚠️ Selisih Kurang (Hilang):' : '✨ Selisih Lebih:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${delta < 0 ? "-" : "+"} ${CurrencyFormatter.formatRupiah(absDelta)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
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

                        DateTime recordDate;
                        final now = DateTime.now();
                        if (_selectedPeriod.year == now.year &&
                            _selectedPeriod.month == now.month) {
                          recordDate = now;
                        } else {
                          final daysInMonth = DateTime(
                            _selectedPeriod.year,
                            _selectedPeriod.month + 1,
                            0,
                          ).day;
                          recordDate = DateTime(
                            _selectedPeriod.year,
                            _selectedPeriod.month,
                            daysInMonth,
                            23,
                            59,
                          );
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
                                'Saldo berhasil diselaraskan ke ${CurrencyFormatter.formatRupiah(_realBalance)}!',
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

/// Dialog Pemilih Bulan & Tahun untuk Rekonsiliasi
class _AdjustmentMonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _AdjustmentMonthYearPickerDialog({required this.initialDate});

  @override
  State<_AdjustmentMonthYearPickerDialog> createState() => _AdjustmentMonthYearPickerDialogState();
}

class _AdjustmentMonthYearPickerDialogState extends State<_AdjustmentMonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
      ),
      title: Column(
        children: [
          const Text(
            'Pilih Periode Rekonsiliasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          // Pemilih Tahun
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.butterYellow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderBlack, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 24, color: AppColors.textBlack),
                  onPressed: () => setState(() => _selectedYear--),
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 24, color: AppColors.textBlack),
                  onPressed: () => setState(() => _selectedYear++),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        height: 240,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (ctx, idx) {
            final monthNum = idx + 1;
            final isSelected = monthNum == _selectedMonth;

            return GestureDetector(
              onTap: () => setState(() => _selectedMonth = monthNum),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.skyBlue : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.borderBlack,
                    width: isSelected ? 2.0 : 1.2,
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
                alignment: Alignment.center,
                child: Text(
                  _months[idx],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mintGreen,
            foregroundColor: AppColors.textBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderBlack, width: 1.5),
            ),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.pop(context, DateTime(_selectedYear, _selectedMonth, 1));
          },
          child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
