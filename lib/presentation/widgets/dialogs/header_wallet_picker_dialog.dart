import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/wallet_icon_helper.dart';
import '../../../data/models/wallet_model.dart';

class HeaderWalletPickerDialog extends StatefulWidget {
  final List<WalletModel> allWallets;
  final List<String> currentSelectedIds;
  final ValueChanged<List<String>> onSaved;

  const HeaderWalletPickerDialog({
    super.key,
    required this.allWallets,
    required this.currentSelectedIds,
    required this.onSaved,
  });

  static const String prefsKey = 'header_wallet_ids';

  static Future<void> show(
    BuildContext context, {
    required List<WalletModel> allWallets,
    required List<String> currentSelectedIds,
    required ValueChanged<List<String>> onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HeaderWalletPickerDialog(
        allWallets: allWallets,
        currentSelectedIds: currentSelectedIds,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<HeaderWalletPickerDialog> createState() =>
      _HeaderWalletPickerDialogState();
}

class _HeaderWalletPickerDialogState extends State<HeaderWalletPickerDialog> {
  late List<String> _selectedIds;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.currentSelectedIds);
  }

  void _toggleWallet(String id) {
    setState(() {
      _errorMessage = null;
      if (_selectedIds.contains(id)) {
        if (_selectedIds.length == 1) {
          _errorMessage = 'Minimal pilih 1 dompet untuk header';
          return;
        }
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length >= 3) {
          _errorMessage = 'Maksimal 3 dompet untuk header';
          return;
        }
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      HeaderWalletPickerDialog.prefsKey,
      jsonEncode(_selectedIds),
    );
    widget.onSaved(_selectedIds);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _resetToDefault() async {
    final defaultIds = widget.allWallets.take(3).map((w) => w.id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(HeaderWalletPickerDialog.prefsKey);
    widget.onSaved(defaultIds);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 150),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.5),
              left: BorderSide(color: AppColors.borderBlack, width: 2.5),
              right: BorderSide(color: AppColors.borderBlack, width: 2.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header Modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atur Dompet Header',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Text(
                    'Pilih maksimal 3 dompet (${_selectedIds.length}/3 dipilih)',
                    style: const TextStyle(
                      fontSize: 12,
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
                    color: AppColors.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderBlack, width: 1.6),
                  ),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textBlack),
                ),
              ),
            ],
          ),

          // Pesan Error jika melebihi/kurang
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dangerRed, width: 1.4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.dangerRed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dangerRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Daftar Dompet yang bisa dipilih
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.allWallets.length,
              itemBuilder: (context, idx) {
                final wallet = widget.allWallets[idx];
                final isChecked = _selectedIds.contains(wallet.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: GestureDetector(
                    onTap: () => _toggleWallet(wallet.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.mintGreen : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderBlack,
                          width: isChecked ? 2.2 : 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            offset: Offset(1.5, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Ikon Wadah
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.fromHex(wallet.color),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderBlack, width: 1.5),
                            ),
                            child: Icon(
                              WalletIconHelper.resolve(wallet.icon),
                              size: 18,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Nama & Saldo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        wallet.name,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textBlack,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (wallet.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryYellow,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.borderBlack, width: 0.8),
                                        ),
                                        child: const Text(
                                          'Utama',
                                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatRupiah(wallet.balance),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Neo-Brutal Checkbox
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: isChecked ? AppColors.textBlack : AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderBlack, width: 1.8),
                            ),
                            child: isChecked
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Tombol Aksi Bawah: Reset & Simpan
          Row(
            children: [
              // Tombol Reset
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _resetToDefault,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
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
                      'Default',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Tombol Simpan
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
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
                      'Simpan Tampilan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}
