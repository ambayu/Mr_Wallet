import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class EditGoalDialog extends StatefulWidget {
  final double currentGoal;

  const EditGoalDialog({super.key, required this.currentGoal});

  static Future<double?> show(BuildContext context, double currentGoal) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditGoalDialog(currentGoal: currentGoal),
    );
  }

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(
      text: widget.currentGoal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Atur Target Finansial',
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
            NeoTextField(
              controller: _goalController,
              labelText: 'Target Tabungan (Rp)',
              hintText: 'Misal: 10000000',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.track_changes_rounded,
            ),
            const SizedBox(height: 20),
            NeoButton(
              label: 'Simpan Target',
              icon: Icons.check,
              backgroundColor: AppColors.butterYellow,
              onPressed: () async {
                final navigator = Navigator.of(context);
                final val = double.tryParse(_goalController.text
                        .replaceAll('.', '')
                        .replaceAll(',', '')) ??
                    10000000.0;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('savings_goal_target', val);
                if (mounted) {
                  navigator.pop(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
