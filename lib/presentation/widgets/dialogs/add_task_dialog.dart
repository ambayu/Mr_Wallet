import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/wallet_icon_helper.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class AddTaskDialog extends StatefulWidget {
  final String? initialType;
  final TaskModel? existing;

  const AddTaskDialog({super.key, this.initialType, this.existing});

  static Future<void> show(BuildContext context, {String? initialType, TaskModel? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskDialog(initialType: initialType, existing: existing),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');

  late String _selectedType; // EXPENSE, INCOME
  String _selectedRecurrence = 'MONTHLY'; // NONE, WEEKLY, MONTHLY
  String _priority = 'MEDIUM'; // LOW, MEDIUM, HIGH
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedWalletId;
  String? _selectedCategoryId;
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _descController.text = existing.description;
      if (existing.estimatedAmount != null && existing.estimatedAmount! > 0) {
        _amountController.text = _currencyFormat.format(existing.estimatedAmount);
      }
      _selectedType = existing.type;
      _selectedRecurrence = existing.recurrence;
      _priority = existing.priority;
      _dueDate = existing.dueDate;
      _selectedWalletId = existing.walletId;
      _selectedCategoryId = existing.categoryId;
    } else {
      _selectedType = widget.initialType ?? 'EXPENSE';

      final walletProv = Provider.of<WalletProvider>(context, listen: false);
      if (walletProv.wallets.isNotEmpty) {
        final def = walletProv.wallets.firstWhere(
          (w) => w.isDefault,
          orElse: () => walletProv.wallets.first,
        );
        _selectedWalletId = def.id;
      }

      final txProv = Provider.of<TransactionProvider>(context, listen: false);
      if (txProv.categories.isNotEmpty) {
        _selectedCategoryId = txProv.categories.first.id;
      }
    }

    _titleController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      setState(() {
        _dueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _dueDate.hour,
          pickedTime?.minute ?? _dueDate.minute,
        );
      });
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(rawAmount) ?? 0.0;

    setState(() => _isSaving = true);
    final taskProv = Provider.of<TaskProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_isEdit) {
        final updated = widget.existing!.copyWith(
          title: title,
          description: _descController.text.trim(),
          priority: _priority,
          type: _selectedType,
          recurrence: _selectedRecurrence,
          categoryId: _selectedCategoryId,
          dueDate: _dueDate,
          estimatedAmount: amount > 0 ? amount : null,
          walletId: _selectedWalletId,
          clearWalletId: _selectedWalletId == null,
        );
        await taskProv.updateTask(updated);
      } else {
        await taskProv.addTask(
          title: title,
          description: _descController.text.trim(),
          priority: _priority,
          type: _selectedType,
          recurrence: _selectedRecurrence,
          categoryId: _selectedCategoryId,
          dueDate: _dueDate,
          estimatedAmount: amount > 0 ? amount : null,
          walletId: _selectedWalletId,
        );
      }

      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Jadwal task berhasil diperbarui! 🤍'
                  : (_selectedType == 'INCOME'
                      ? 'Jadwal pemasukan gaji berhasil ditambahkan! 💰'
                      : 'Jadwal pengeluaran rutin berhasil ditambahkan! 📝'),
            ),
            backgroundColor: AppColors.textBlack,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menyimpan task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);

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
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEdit ? 'Edit Jadwal Finansial' : 'Jadwal Finansial Rutin',
                      style: const TextStyle(
                        fontSize: 19,
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
                          border: Border.all(color: AppColors.borderBlack, width: 1.8),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textBlack),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 1. Toggle Tipe Transaksi [Pengeluaran Rutin] [Pemasukan (Gaji)]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderBlack, width: 2),
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
                      _buildTypeToggle('EXPENSE', '💸 Pengeluaran Rutin', AppColors.bubblePink),
                      _buildTypeToggle('INCOME', '💰 Pemasukan (Gaji)', AppColors.mintGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Input Judul / Nama Task
                NeoTextField(
                  controller: _titleController,
                  labelText: _selectedType == 'INCOME' ? 'Nama Pemasukan / Gaji' : 'Nama Tagihan / Pengeluaran',
                  hintText: _selectedType == 'INCOME' ? 'Misal: Gaji Kantor, Bonus Bulanan' : 'Misal: Bayar WiFi, Listrik PLN, Cicilan',
                  prefixIcon: _selectedType == 'INCOME' ? Icons.monetization_on_rounded : Icons.receipt_long_rounded,
                ),
                const SizedBox(height: 12),

                // 3. Estimasi Nominal
                NeoTextField(
                  controller: _amountController,
                  labelText: 'Estimasi Nominal (Rp)',
                  hintText: 'Misal: 5.000.000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_rounded,
                  onChanged: _onAmountChanged,
                ),
                const SizedBox(height: 14),

                // 4. Frekuensi Pengulangan (Recurrence)
                const Text(
                  'Frekuensi Pengulangan:',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildRecurrenceChip('NONE', 'Sekali Saja'),
                    const SizedBox(width: 8),
                    _buildRecurrenceChip('WEEKLY', 'Mingguan'),
                    const SizedBox(width: 8),
                    _buildRecurrenceChip('MONTHLY', 'Bulanan'),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. Dompet Acuan (Sumber/Tujuan)
                Text(
                  _selectedType == 'INCOME' ? 'Masuk ke Rekening / Dompet:' : 'Potong dari Rekening / Dompet:',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                ),
                const SizedBox(height: 6),
                _buildWalletDropdown(walletProv),
                const SizedBox(height: 14),

                // 6. Tanggal Jatuh Tempo / Eksekusi
                Row(
                  children: [
                    const Text(
                      'Jadwal Tanggal / Jam:',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textBlack),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _pickDueDate,
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
                            const Icon(Icons.event_rounded, size: 15, color: AppColors.textBlack),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_dueDate),
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

                // 7. Catatan Tambahan (Opsional)
                NeoTextField(
                  controller: _descController,
                  labelText: 'Catatan Tambahan (Opsional)',
                  hintText: 'Misal: Jangan sampai telat bayar sebelum tgl 20',
                  prefixIcon: Icons.notes_rounded,
                ),
                const SizedBox(height: 22),

                // Tombol Simpan
                NeoButton(
                  label: _isSaving
                      ? 'Menyimpan...'
                      : (_isEdit ? 'Simpan Perubahan' : 'Simpan Jadwal Task'),
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.primaryYellow,
                  onPressed: _titleController.text.trim().isEmpty || _isSaving ? null : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String type, String label, Color activeBg) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.borderBlack, width: 1.6) : null,
          ),
          alignment: Alignment.center,
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
    );
  }

  Widget _buildRecurrenceChip(String key, String label) {
    final isSelected = _selectedRecurrence == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRecurrence = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textBlack : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
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
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(WalletProvider walletProv) {
    if (walletProv.wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderBlack, width: 1.6),
        ),
        child: const Text('Belum ada wadah dompet.', style: TextStyle(fontSize: 12)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: walletProv.wallets.any((w) => w.id == _selectedWalletId)
              ? _selectedWalletId
              : walletProv.wallets.first.id,
          items: walletProv.wallets.map((w) {
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
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedWalletId = val);
          },
        ),
      ),
    );
  }
}
