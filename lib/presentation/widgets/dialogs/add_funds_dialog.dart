import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../providers/savings_goal_provider.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class AddFundsDialog extends StatefulWidget {
  final SavingsGoalModel goal;

  const AddFundsDialog({super.key, required this.goal});

  static Future<void> show(BuildContext context, SavingsGoalModel goal) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddFundsDialog(goal: goal),
    );
  }

  @override
  State<AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<AddFundsDialog> {
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');
  bool _isWithdraw = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
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
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = Provider.of<SavingsGoalProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.addFunds(widget.goal.id, _isWithdraw ? -amount : amount);
      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(_isWithdraw
                ? 'Dana berhasil ditarik 🤍'
                : 'Dana berhasil ditambahkan! 🎉'),
            backgroundColor: AppColors.textBlack,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Dana',
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
                          border:
                              Border.all(color: AppColors.borderBlack, width: 2),
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Info Goal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        offset: Offset(1.5, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${CurrencyFormatter.formatShort(goal.savedAmount)} / ${CurrencyFormatter.formatShort(goal.targetAmount)} (${goal.progressPercent}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Toggle Tambah / Tarik
                Row(
                  children: [
                    Expanded(
                      child: _buildModeChip(
                        label: 'Tambah',
                        icon: Icons.add_rounded,
                        isActive: !_isWithdraw,
                        onTap: () => setState(() => _isWithdraw = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeChip(
                        label: 'Tarik',
                        icon: Icons.remove_rounded,
                        isActive: _isWithdraw,
                        onTap: () => setState(() => _isWithdraw = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Nominal
                NeoTextField(
                  controller: _amountController,
                  labelText: 'Nominal (Rp)',
                  hintText: 'Misal: 500.000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money_rounded,
                  onChanged: _onAmountChanged,
                ),
                const SizedBox(height: 24),

                NeoButton(
                  label: _isSaving
                      ? 'Menyimpan...'
                      : (_isWithdraw ? 'Tarik Dana' : 'Tambah Dana'),
                  icon: _isWithdraw
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  backgroundColor:
                      _isWithdraw ? AppColors.bubblePink : AppColors.mintGreen,
                  onPressed: _amountController.text.trim().isEmpty || _isSaving
                      ? null
                      : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryYellow : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderBlack,
            width: isActive ? 2.2 : 1.5,
          ),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: AppColors.shadowBlack,
                    offset: Offset(1.5, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textBlack),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
