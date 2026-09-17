import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../neo_badge.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class AddWalletDialog extends StatefulWidget {
  const AddWalletDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddWalletDialog(),
    );
  }

  @override
  State<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends State<AddWalletDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _selectedType = 'BANK'; // CASH, BANK, EWALLET
  String _selectedColor = '#FFF0B3'; // Default Pastel Yellow
  bool _isSaving = false;

  final List<String> _colorOptions = [
    '#FFF0B3', // Yellow
    '#BFF2A5', // Green
    '#FFBEE3', // Pink
    '#A594F9', // Lavender
    '#C4D7FF', // Sky Blue
    '#FFD6A5', // Peach
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);

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
                    'Tambah Wadah Rekening',
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
                        border: Border.all(color: AppColors.borderBlack, width: 2),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Wallet Name
              NeoTextField(
                controller: _nameController,
                labelText: 'Nama Rekening / Dompet',
                hintText: 'Misal: ATM BSI / ShopeePay / Tabungan Nikah',
                prefixIcon: Icons.account_balance_wallet,
              ),
              const SizedBox(height: 14),

              // Type Selector
              const Text(
                'Tipe Wadah:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip('CASH', 'Tunai / Fisik'),
                  const SizedBox(width: 8),
                  _buildTypeChip('BANK', 'Rekening Bank'),
                  const SizedBox(width: 8),
                  _buildTypeChip('EWALLET', 'E-Wallet'),
                ],
              ),
              const SizedBox(height: 14),

              // Initial Balance
              NeoTextField(
                controller: _balanceController,
                labelText: 'Saldo Awal (Rp)',
                hintText: 'Contoh: 500000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 14),

              // Color Theme Palette Selector
              const Text(
                'Warna Kartu Neo-Brutalist:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: _colorOptions.map((hex) {
                  final isSelected = _selectedColor == hex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.fromHex(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderBlack,
                            width: isSelected ? 3.0 : 2.0,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: AppColors.shadowBlack,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 20, color: AppColors.textBlack)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save Button
              NeoButton(
                label: _isSaving ? 'Menyimpan...' : 'Simpan Wadah Baru',
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.mintGreen,
                onPressed: _nameController.text.trim().isEmpty || _isSaving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        setState(() => _isSaving = true);

                        final initialBal = double.tryParse(_balanceController
                                .text
                                .replaceAll('.', '')
                                .replaceAll(',', '')) ??
                            0.0;

                        final newWallet = WalletModel(
                          id: 'w_${const Uuid().v4().substring(0, 8)}',
                          name: _nameController.text.trim(),
                          type: _selectedType,
                          balance: initialBal,
                          icon: _selectedType == 'BANK'
                              ? 'account_balance'
                              : _selectedType == 'EWALLET'
                                  ? 'phone_android'
                                  : 'payments',
                          color: _selectedColor,
                          isDefault: false,
                        );

                        await walletProv.addWallet(newWallet);

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

  Widget _buildTypeChip(String key, String label) {
    final isSelected = _selectedType == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = key),
        child: NeoBadge(
          text: label,
          backgroundColor: isSelected ? AppColors.bubblePink : AppColors.cardWhite,
          borderWidth: isSelected ? 2.5 : 1.5,
        ),
      ),
    );
  }
}
