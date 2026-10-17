import 'dart:io';
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
  bool _isSaving = false;
  String? _errorMessage;

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
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (photo != null && mounted) {
        setState(() {
          _capturedImagePath = photo.path;
          _merchantController.clear();
          _amountController.clear();
        });

        final aiProv = Provider.of<AIProvider>(context, listen: false);
        await aiProv.processBillImage(imagePath: photo.path);

        if (!mounted) return;

        if (aiProv.errorMessage.isNotEmpty) {
          setState(() => _errorMessage = aiProv.errorMessage);
        } else if (aiProv.lastOCRResult != null) {
          setState(() {
            _merchantController.text = aiProv.lastOCRResult!.merchantName;
            _amountController.text =
                aiProv.lastOCRResult!.totalAmount.toStringAsFixed(0);
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Gagal membaca gambar. Coba lagi.');
      }
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
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Struk',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        'Foto struk → AI baca otomatis',
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

              // ── Tombol Ambil Foto ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Buka Kamera',
                      icon: Icons.camera_alt_rounded,
                      backgroundColor: AppColors.mintGreen,
                      onPressed: aiProv.isProcessing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoButton(
                      label: 'Dari Galeri',
                      icon: Icons.photo_library_rounded,
                      backgroundColor: AppColors.bubblePink,
                      onPressed: aiProv.isProcessing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Preview Gambar ───────────────────────────────────────────
              if (_capturedImagePath != null && !aiProv.isProcessing) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderBlack, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.file(
                      File(_capturedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Loading State ────────────────────────────────────────────
              if (aiProv.isProcessing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderBlack, width: 1.8),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadowBlack, offset: Offset(3, 3)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          color: AppColors.borderBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AI sedang membaca struk...',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mohon tunggu, proses ini memerlukan beberapa detik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.textBlack.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Shimmer rows
                      _ShimmerBar(width: double.infinity, height: 12),
                      const SizedBox(height: 8),
                      _ShimmerBar(width: 200, height: 12),
                      const SizedBox(height: 8),
                      _ShimmerBar(width: 160, height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Error State ──────────────────────────────────────────────
              if (_errorMessage != null && !aiProv.isProcessing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.dangerRed, width: 1.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.dangerRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Hasil Ekstraksi ──────────────────────────────────────────
              if (aiProv.lastOCRResult != null && !aiProv.isProcessing) ...[
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
                            text: 'AI Verified',
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

                      // Pilih Dompet
                      const Text(
                        'Bayar Menggunakan:',
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

                      // Konfirmasi & Simpan
                      NeoButton(
                        label: _isSaving
                            ? 'Menyimpan...'
                            : 'Konfirmasi & Catat Transaksi',
                        icon: Icons.check_circle_outline,
                        backgroundColor: AppColors.mintGreen,
                        onPressed: _isSaving
                            ? null
                            : () async {
                                final total = double.tryParse(
                                        _amountController.text
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
                                      ? 'Struk: ${_merchantController.text}'
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

              // ── Empty State (belum ada foto) ─────────────────────────────
              if (_capturedImagePath == null && !aiProv.isProcessing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.borderBlack.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada foto struk',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Buka Kamera" atau "Dari Galeri" di atas',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shimmer Bar Widget ─────────────────────────────────────────────────────────
class _ShimmerBar extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerBar({required this.width, required this.height});

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.borderBlack.withValues(alpha: 0.08 * _anim.value + 0.04),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
