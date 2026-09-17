import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/ai_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_badge.dart';
import '../neo_button.dart';
import '../neo_card.dart';
import '../neo_text_field.dart';

class CameraBillSnapModal extends StatefulWidget {
  const CameraBillSnapModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CameraBillSnapModal(),
    );
  }

  @override
  State<CameraBillSnapModal> createState() => _CameraBillSnapModalState();
}

class _CameraBillSnapModalState extends State<CameraBillSnapModal> {
  final ImagePicker _picker = ImagePicker();
  String? _capturedImagePath;
  late String _selectedWalletId;
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rawOcrController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    _selectedWalletId = walletProv.selectedWalletId ??
        (walletProv.wallets.isNotEmpty ? walletProv.wallets.first.id : 'w_cash');
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _rawOcrController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _capturedImagePath = photo.path;
        });

        if (mounted) {
          final aiProv = Provider.of<AIProvider>(context, listen: false);
          await aiProv.processBillImage(
            imagePath: photo.path,
            rawOCRText: _rawOcrController.text.isNotEmpty
                ? _rawOcrController.text
                : 'TOTAL RP 45.000\nKAFE MEDAN\n1 KOPI SUSU 25.000\n1 ROTI BAKAR 20.000',
          );

          if (aiProv.lastOCRResult != null) {
            _merchantController.text = aiProv.lastOCRResult!.merchantName;
            _amountController.text =
                aiProv.lastOCRResult!.totalAmount.toStringAsFixed(0);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProv = Provider.of<AIProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

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
                        'Camera Bill Snap',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        'Ekstraksi Struk Belanja dengan OCR + Vision AI',
                        style: TextStyle(
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
                        border: Border.all(color: AppColors.borderBlack, width: 2),
                      ),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Image Capture Buttons
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Buka Kamera',
                      icon: Icons.camera_alt_rounded,
                      backgroundColor: AppColors.mintGreen,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoButton(
                      label: 'Dari Galeri',
                      icon: Icons.photo_library_rounded,
                      backgroundColor: AppColors.bubblePink,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Raw OCR Simulation Input (Useful for Testing on Desktop / Fallback)
              NeoTextField(
                controller: _rawOcrController,
                labelText: 'Teks OCR Struk (Opsional / Manual Test)',
                hintText: 'Contoh: KOPI SHOP TOTAL: 35000',
              ),
              const SizedBox(height: 10),
              NeoButton(
                label: 'Proses Ekstraksi OCR Teks',
                icon: Icons.document_scanner_outlined,
                backgroundColor: AppColors.skyBlue,
                height: 44,
                onPressed: () async {
                  await aiProv.processBillImage(
                    imagePath: _capturedImagePath ?? '',
                    rawOCRText: _rawOcrController.text.isNotEmpty
                        ? _rawOcrController.text
                        : 'KASIR INDOMARET\nROTI TAWAR 18.000\nSUSU KOTAK 12.000\nTOTAL RP 30.000',
                  );

                  if (aiProv.lastOCRResult != null) {
                    _merchantController.text =
                        aiProv.lastOCRResult!.merchantName;
                    _amountController.text =
                        aiProv.lastOCRResult!.totalAmount.toStringAsFixed(0);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Extracted Bill Result Form
              if (aiProv.isProcessing) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppColors.borderBlack),
                  ),
                ),
              ] else if (aiProv.lastOCRResult != null) ...[
                NeoCard(
                  backgroundColor: AppColors.cardWhite,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hasil Ekstraksi Struk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          NeoBadge(
                            text: 'Vision Verified',
                            backgroundColor: AppColors.mintGreen,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderBlack, height: 18),
                      NeoTextField(
                        controller: _merchantController,
                        labelText: 'Nama Toko / Merchant',
                        prefixIcon: Icons.storefront,
                      ),
                      const SizedBox(height: 10),
                      NeoTextField(
                        controller: _amountController,
                        labelText: 'Total Tagihan (Rp)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                      ),
                      const SizedBox(height: 12),

                      // Wallet Choice
                      const Text(
                        'Bayar Menggunakan Rekening:',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: walletProv.wallets.map((w) {
                            final isSelected = w.id == _selectedWalletId;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedWalletId = w.id),
                                child: NeoBadge(
                                  text: w.name,
                                  backgroundColor: isSelected
                                      ? AppColors.lavenderPurple
                                      : AppColors.cardWhite,
                                  borderWidth: isSelected ? 2.5 : 1.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Confirm & Save
                      NeoButton(
                        label: _isSaving
                            ? 'Menyimpan...'
                            : 'Konfirmasi & Masukkan ke Buku Kas',
                        icon: Icons.check_circle_outline,
                        backgroundColor: AppColors.mintGreen,
                        onPressed: _isSaving
                            ? null
                            : () async {
                                final total = double.tryParse(_amountController
                                        .text
                                        .replaceAll('.', '')
                                        .replaceAll(',', '')) ??
                                    0.0;
                                if (total <= 0) return;

                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isSaving = true);
                                await txProv.addTransaction(
                                  walletId: _selectedWalletId,
                                  type: 'EXPENSE',
                                  amount: total,
                                  description: _merchantController.text.isNotEmpty
                                      ? 'Belanja Struk: ${_merchantController.text}'
                                      : 'Belanja Struk Kasir',
                                  receiptImagePath: _capturedImagePath,
                                );

                                await walletProv.loadWallets();

                                if (mounted) {
                                  setState(() => _isSaving = false);
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.borderBlack,
                                      content: Text(
                                        'Struk ${CurrencyFormatter.format(total)} berhasil dicatat!',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
