import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/category_icon_helper.dart';
import '../../../data/models/category_model.dart';
import '../../providers/transaction_provider.dart';
import '../neo_button.dart';
import '../neo_text_field.dart';

class AddCategoryDialog extends StatefulWidget {
  final String? initialType;

  const AddCategoryDialog({
    super.key,
    this.initialType,
  });

  static Future<CategoryModel?> show(
    BuildContext context, {
    String? initialType,
  }) {
    return showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCategoryDialog(initialType: initialType),
    );
  }

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  late String _selectedType;
  String _selectedIcon = 'restaurant';
  String _selectedColor = '#FFE86C';
  bool _isSaving = false;

  final List<String> _colorOptions = [
    '#FFE86C', // Pastel Yellow
    '#CEF8BA', // Mint Green
    '#FFCCD5', // Bubble Pink
    '#D2EEFC', // Sky Blue
    '#E4DBFA', // Lavender
    '#FFDEB5', // Soft Peach
    '#FF7A59', // Coral
    '#BFF2A5', // Lime
  ];

  @override
  void initState() {
    super.initState();
    // Kategori dibuat fleksibel (bisa dipakai pengeluaran maupun pemasukan)
    _selectedType = widget.initialType ?? 'EXPENSE';
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);

    try {
      final newCategory = CategoryModel(
        id: 'c_${const Uuid().v4().substring(0, 8)}',
        name: name,
        type: _selectedType,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      await txProv.addCategory(newCategory);

      if (mounted) {
        Navigator.pop(context, newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori "$name" berhasil dibuat! 🎉'),
            backgroundColor: AppColors.textBlack,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat kategori: $e'),
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
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
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
                  const Text(
                    'Tambah Kategori Baru',
                    style: TextStyle(
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
                        border: Border.all(color: AppColors.borderBlack, width: 1.6),
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Kategori baru dapat digunakan untuk pengeluaran maupun pemasukan.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Category Name Field
              NeoTextField(
                controller: _nameController,
                labelText: 'Nama Kategori',
                hintText: 'Misal: Belanja Bulanan / Pulsa / Kopi',
                prefixIcon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: 16),

              // Icon Grid Picker (Katalog 45+ Ikon Terkurasi)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Icon Kategori:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Text(
                    CategoryIconHelper.getLabel(_selectedIcon),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 180,
                padding: const EdgeInsets.all(10),
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
                child: Scrollbar(
                  thumbVisibility: true,
                  child: GridView.builder(
                    itemCount: CategoryIconHelper.catalog.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, idx) {
                      final item = CategoryIconHelper.catalog[idx];
                      final isSelected = _selectedIcon == item.key;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = item.key;
                            if (_nameController.text.trim().isEmpty) {
                              _nameController.text = item.label;
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.fromHex(_selectedColor)
                                : const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderBlack,
                              width: isSelected ? 2.2 : 1.2,
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
                            item.icon,
                            size: 20,
                            color: AppColors.textBlack,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color Palette Picker
              const Text(
                'Warna Aksen:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _colorOptions.map((hex) {
                  final isSelected = _selectedColor == hex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.fromHex(hex),
                          shape: BoxShape.circle,
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
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: AppColors.textBlack)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Save Button
              NeoButton(
                label: _isSaving ? 'Menyimpan...' : 'Simpan Kategori Baru',
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: AppColors.mintGreen,
                onPressed: _nameController.text.trim().isEmpty || _isSaving
                    ? null
                    : _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
