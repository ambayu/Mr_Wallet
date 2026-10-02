import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../providers/savings_goal_provider.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class AddSavingsGoalDialog extends StatefulWidget {
  /// Jika diisi, dialog berjalan dalam mode edit.
  final SavingsGoalModel? existing;

  const AddSavingsGoalDialog({super.key, this.existing});

  static Future<void> show(BuildContext context, {SavingsGoalModel? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddSavingsGoalDialog(existing: existing),
    );
  }

  @override
  State<AddSavingsGoalDialog> createState() => _AddSavingsGoalDialogState();
}

class _AddSavingsGoalDialogState extends State<AddSavingsGoalDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');

  DateTime? _deadline;
  String _selectedIcon = 'savings';
  String _selectedColor = '#D6F0FF';
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  static const List<String> _iconOptions = [
    'savings',
    'flight_takeoff',
    'laptop_mac',
    'shield',
    'home',
    'directions_car',
    'school',
    'favorite',
    'celebration',
    'watch',
  ];

  static const Map<String, IconData> _iconMap = {
    'savings': Icons.savings_rounded,
    'flight_takeoff': Icons.flight_takeoff_rounded,
    'laptop_mac': Icons.laptop_mac_rounded,
    'shield': Icons.shield_rounded,
    'home': Icons.home_rounded,
    'directions_car': Icons.directions_car_rounded,
    'school': Icons.school_rounded,
    'favorite': Icons.favorite_rounded,
    'celebration': Icons.celebration_rounded,
    'watch': Icons.watch_rounded,
  };

  static const List<String> _colorOptions = [
    '#D6F0FF', // Sky
    '#FFF0B3', // Yellow
    '#BFF2A5', // Green
    '#FFBEE3', // Pink
    '#A594F9', // Lavender
    '#FFD6A5', // Peach
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _targetController.text = _currencyFormat.format(existing.targetAmount);
      _deadline = existing.deadline;
      _selectedIcon = existing.icon;
      _selectedColor = existing.color;
    }
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _onTargetChanged(String val) {
    if (val.isEmpty) return;
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      _targetController.value = const TextEditingValue(text: '');
      return;
    }
    final number = int.tryParse(clean) ?? 0;
    final formatted = _currencyFormat.format(number);
    _targetController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _handleSave() async {
    final rawTarget =
        _targetController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final targetAmount = double.tryParse(rawTarget) ?? 0;

    if (targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target dana harus lebih dari 0!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = Provider.of<SavingsGoalProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_isEdit) {
        final updated = widget.existing!.copyWith(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          deadline: _deadline,
          clearDeadline: _deadline == null,
          icon: _selectedIcon,
          color: _selectedColor,
        );
        await provider.updateGoal(updated);
      } else {
        await provider.addGoal(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          deadline: _deadline,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      }

      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Pencapaian berhasil diperbarui! 🤍'
                : 'Pencapaian baru berhasil dibuat! 🎉'),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEdit ? 'Edit Pencapaian' : 'Pencapaian Baru',
                      style: const TextStyle(
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
                const SizedBox(height: 6),
                const Text(
                  'Mau beli / capai apa? Tentukan target dananya.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),

                // Nama Pencapaian
                NeoTextField(
                  controller: _nameController,
                  labelText: 'Mau Beli / Capai Apa?',
                  hintText: 'Misal: Liburan ke Jepang, Beli Laptop',
                  prefixIcon: Icons.flag_rounded,
                ),
                const SizedBox(height: 14),

                // Target Dana
                NeoTextField(
                  controller: _targetController,
                  labelText: 'Target Dana (Rp)',
                  hintText: 'Misal: 15.000.000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.savings_rounded,
                  onChanged: _onTargetChanged,
                ),
                const SizedBox(height: 14),

                // Tenggat (opsional)
                const Text(
                  'Tenggat (Opsional):',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.borderBlack, width: 1.8),
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
                        const Icon(Icons.event_rounded,
                            size: 20, color: AppColors.textBlack),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _deadline != null
                                ? DateFormat('d MMMM yyyy', 'id_ID')
                                    .format(_deadline!)
                                : 'Pilih tanggal (opsional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _deadline != null
                                  ? AppColors.textBlack
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (_deadline != null)
                          GestureDetector(
                            onTap: () => setState(() => _deadline = null),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Pilih Ikon
                const Text(
                  'Ikon Pencapaian:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((iconKey) {
                    final isSelected = _selectedIcon == iconKey;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = iconKey),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mintGreen
                              : AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderBlack,
                            width: isSelected ? 2.5 : 1.5,
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
                        child: Icon(
                          _iconMap[iconKey] ?? Icons.savings_rounded,
                          size: 20,
                          color: AppColors.textBlack,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Pilih Warna
                const Text(
                  'Warna Kartu:',
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
                              ? const Icon(Icons.check,
                                  size: 20, color: AppColors.textBlack)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                NeoButton(
                  label: _isSaving
                      ? 'Menyimpan...'
                      : (_isEdit ? 'Simpan Perubahan' : 'Simpan Pencapaian'),
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.mintGreen,
                  onPressed: _nameController.text.trim().isEmpty || _isSaving
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
}
