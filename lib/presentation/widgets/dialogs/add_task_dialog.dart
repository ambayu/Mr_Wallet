import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/task_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_badge.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddTaskDialog(),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(hours: 4));
  String _priority = 'MEDIUM'; // LOW, MEDIUM, HIGH
  String? _selectedWalletId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final taskProv = Provider.of<TaskProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bubblePink,
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
                        'Tambah Jadwal & Target',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        'Task Scheduler dengan Alarm Lokal',
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
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 2),
                      ),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title
              NeoTextField(
                controller: _titleController,
                labelText: 'Judul Aktivitas / Tagihan',
                hintText: 'Misal: Bayar Listrik PLN / Servis Motor',
                prefixIcon: Icons.task_alt,
              ),
              const SizedBox(height: 14),

              // Description
              NeoTextField(
                controller: _descController,
                labelText: 'Deskripsi / Detail Tambahan',
                hintText: 'Misal: Bawa struk bulan lalu',
              ),
              const SizedBox(height: 14),

              // Priority Selector
              const Text(
                'Prioritas:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('LOW', 'Rendah', AppColors.mintGreen),
                  const SizedBox(width: 8),
                  _buildPriorityChip('MEDIUM', 'Sedang', AppColors.butterYellow),
                  const SizedBox(width: 8),
                  _buildPriorityChip('HIGH', 'Tinggi 🔥', AppColors.coralOrange),
                ],
              ),
              const SizedBox(height: 14),

              // Date Picker
              const Text(
                'Batas Waktu (Due Date & Alarm):',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null && mounted) {
                    final pickedTime = await showTimePicker(
                      context: navigator.context,
                      initialTime: TimeOfDay.fromDateTime(_dueDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _dueDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderBlack, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        offset: Offset(2.5, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alarm, color: AppColors.textBlack),
                          const SizedBox(width: 10),
                          Text(
                            DateFormatter.formatDateTime(_dueDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const NeoBadge(
                        text: 'Ubah Waktu',
                        backgroundColor: AppColors.butterYellow,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Financial Binding Section (PRD 3.2)
              const Text(
                'Hubungkan Finansial (Opsional):',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              NeoTextField(
                controller: _amountController,
                labelText: 'Estimasi Nominal (Rp)',
                hintText: 'Misal: 250000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.monetization_on_outlined,
              ),
              const SizedBox(height: 10),

              // Wallet choice for financial binding
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: walletProv.wallets.map((w) {
                    final isSelected = w.id == _selectedWalletId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWalletId = isSelected ? null : w.id;
                          });
                        },
                        child: NeoBadge(
                          text: isSelected ? 'Sumber: ${w.name}' : w.name,
                          backgroundColor:
                              isSelected ? AppColors.skyBlue : AppColors.cardWhite,
                          borderWidth: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              NeoButton(
                label: _isSaving ? 'Menyimpan...' : 'Jadwalkan Tugas & Set Alarm',
                icon: Icons.add_alert_rounded,
                backgroundColor: AppColors.butterYellow,
                onPressed: _titleController.text.isEmpty || _isSaving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        setState(() => _isSaving = true);
                        final amt = _amountController.text.isNotEmpty
                            ? double.tryParse(_amountController.text
                                .replaceAll('.', '')
                                .replaceAll(',', ''))
                            : null;

                        await taskProv.addTask(
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          priority: _priority,
                          dueDate: _dueDate,
                          estimatedAmount: amt,
                          walletId: _selectedWalletId,
                        );

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

  Widget _buildPriorityChip(String key, String label, Color color) {
    final isSelected = _priority == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = key),
        child: NeoBadge(
          text: label,
          backgroundColor: isSelected ? color : AppColors.cardWhite,
          borderWidth: isSelected ? 2.5 : 1.5,
        ),
      ),
    );
  }
}
