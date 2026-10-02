import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/utils/category_icon_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/ai_parsed_result.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_button.dart';

/// Modal AI Text Command canggih (Ditenagai Gemini 3.7 / Route9 API).
/// Memiliki:
/// 1. Kolom input teks alami.
/// 2. Riwayat teks perintah yang tersimpan rapi.
/// 3. Menu Konfirmasi Tindakan yang jelas sebelum commit ke database.
class AITextModal extends StatefulWidget {
  final String? initialText;

  const AITextModal({super.key, this.initialText});

  static Future<bool?> show(BuildContext context, {String? initialText}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AITextModal(initialText: initialText),
    );
  }

  @override
  State<AITextModal> createState() => _AITextModalState();
}

class _AITextModalState extends State<AITextModal> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isCommitting = false;
  AIParsedResult? _parsedResult;
  List<String> _promptHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
    }
    _loadHistory();
    // Auto focus saat modal pertama kali terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialText == null) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await AIService.instance.getPromptHistory();
    if (mounted) {
      setState(() {
        _promptHistory = history;
      });
    }
  }

  Future<void> _processText(String prompt) async {
    final clean = prompt.trim();
    if (clean.isEmpty) return;

    _focusNode.unfocus();
    setState(() {
      _isLoading = true;
      _parsedResult = null;
    });

    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);

    final walletNames = walletProv.wallets.map((w) => w.name).toList();
    final categoryNames = txProv.categories.map((c) => c.name).toList();

    try {
      final result = await AIService.instance.parseNaturalCommand(
        userInput: clean,
        availableWallets: walletNames,
        availableCategories: categoryNames,
      );

      if (mounted) {
        setState(() {
          _parsedResult = result;
          _isLoading = false;
        });
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses dengan AI: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndCommit() async {
    if (_parsedResult == null) return;

    setState(() => _isCommitting = true);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    try {
      // 1. Eksekusi seluruh transaksi yang terdeteksi
      for (final tx in _parsedResult!.transactions) {
        // Cocokkan dompet
        WalletModel? matchedWallet;
        for (final w in walletProv.wallets) {
          if (w.name.toLowerCase() == tx.walletName.toLowerCase() ||
              tx.walletName.toLowerCase().contains(w.name.toLowerCase())) {
            matchedWallet = w;
            break;
          }
        }
        matchedWallet ??= walletProv.wallets.isNotEmpty
            ? walletProv.wallets.first
            : null;

        if (matchedWallet == null) continue;

        // Cocokkan kategori
        CategoryModel? matchedCategory;
        for (final c in txProv.categories) {
          if (c.name.toLowerCase() == tx.category.toLowerCase() ||
              tx.category.toLowerCase().contains(c.name.toLowerCase()) ||
              c.name.toLowerCase().contains(tx.category.toLowerCase())) {
            matchedCategory = c;
            break;
          }
        }
        matchedCategory ??= txProv.categories.isNotEmpty
            ? txProv.categories.first
            : null;

        if (tx.type == 'TRANSFER') {
          await txProv.addTransaction(
            walletId: matchedWallet.id,
            type: 'TRANSFER',
            amount: tx.amount,
            description: tx.notes.isNotEmpty ? tx.notes : 'Transfer AI',
            transactionDate: DateTime.now(),
          );
        } else if (tx.type == 'ADJUSTMENT') {
          await txProv.reconcileWalletBalance(
            walletId: matchedWallet.id,
            actualBalance: tx.targetActualBalance ?? tx.amount,
            subType: 'LOST_MONEY',
            customNote: tx.notes,
          );
        } else {
          await txProv.addTransaction(
            walletId: matchedWallet.id,
            categoryId: matchedCategory?.id,
            type: tx.type,
            amount: tx.amount,
            description: tx.notes.isNotEmpty
                ? tx.notes
                : (matchedCategory?.name ?? 'Transaksi AI'),
            transactionDate: DateTime.now(),
          );
        }
      }

      // 2. Eksekusi pengingat / tugas jika terdeteksi
      for (final t in _parsedResult!.tasks) {
        await taskProv.addTask(
          title: t.title,
          dueDate: t.dueDate,
          priority: t.priority,
          estimatedAmount: t.estimatedAmount,
        );
      }

      await walletProv.loadWallets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perintah AI berhasil dieksekusi & disimpan! 🎉'),
            backgroundColor: AppColors.textBlack,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCommitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
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
              // Header Modal
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.borderBlack, width: 1.8),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        size: 20, color: AppColors.textBlack),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catat Cepat dengan AI',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Ketik bebas, AI akan mengekstrak otomatis.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.borderBlack, width: 1),
                    ),
                    child: const Text(
                      'gemini-3.7',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.textBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kolom Input Teks AI
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderBlack, width: 2),
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
                    const Padding(
                      padding: EdgeInsets.only(left: 14, right: 6),
                      child: Icon(Icons.chat_bubble_outline_rounded,
                          size: 20, color: AppColors.textMuted),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _processText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Misal: Beli makan siang 25rb pakai Tunai...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_textController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _textController.clear();
                          setState(() {});
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.cancel_rounded,
                              size: 18, color: AppColors.textMuted),
                        ),
                      ),
                    // Tombol Kirim / Proses
                    GestureDetector(
                      onTap: () => _processText(_textController.text),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.borderBlack, width: 1.8),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textBlack,
                                ),
                              )
                            : const Icon(Icons.arrow_upward_rounded,
                                size: 18, color: AppColors.textBlack),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // KONDISI 1: Sedang Memproses Loading
              // ==========================================
              if (_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 1.8),
                  ),
                  child: const Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.textBlack),
                      SizedBox(height: 12),
                      Text(
                        'AI sedang mengekstrak transaksi...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                )

              // ==========================================
              // KONDISI 2: Hasil Ekstraksi & Menu Konfirmasi Tindakan
              // ==========================================
              else if (_parsedResult != null)
                _buildActionConfirmationSection(walletProv, txProv)

              // ==========================================
              // KONDISI 3: Riwayat Teks & Saran Perintah
              // ==========================================
              else
                _buildHistoryAndSuggestionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionConfirmationSection(
    WalletProvider walletProv,
    TransactionProvider txProv,
  ) {
    final transactions = _parsedResult!.transactions;
    final tasks = _parsedResult!.tasks;
    final hasActions = transactions.isNotEmpty || tasks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Feedback Response Bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_outlined,
                  size: 20, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _parsedResult!.naturalResponse,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Section Title: Menu Konfirmasi Tindakan
        const Row(
          children: [
            Icon(Icons.checklist_rounded, size: 18, color: AppColors.textBlack),
            SizedBox(width: 6),
            Text(
              'Menu Konfirmasi Tindakan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (!hasActions)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 1.6),
            ),
            child: const Text(
              'Tidak ada aksi transaksi yang terdeteksi dari teks ini. Coba tuliskan nominal atau nama barang lebih spesifik.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

        // Kartu Konfirmasi Tiap Transaksi
        ...transactions.map((tx) {
          final isIncome = tx.type == 'INCOME';
          final isTransfer = tx.type == 'TRANSFER';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderBlack, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack,
                  offset: Offset(2, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isIncome
                            ? AppColors.mintGreen
                            : (isTransfer
                                ? AppColors.skyBlue
                                : AppColors.bubblePink),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: Icon(
                        CategoryIconHelper.resolve(tx.category),
                        size: 18,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.category,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Text(
                            tx.notes.isNotEmpty ? tx.notes : 'Tanpa catatan',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isIncome
                            ? AppColors.mintGreen
                            : (isTransfer
                                ? AppColors.skyBlue
                                : AppColors.bubblePink),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderBlack, width: 1.2),
                      ),
                      child: Text(
                        isIncome
                            ? 'Pemasukan'
                            : (isTransfer ? 'Transfer' : 'Pengeluaran'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          tx.walletName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(tx.amount),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isIncome
                            ? const Color(0xFF16A34A)
                            : (isTransfer
                                ? AppColors.textBlack
                                : const Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        // Kartu Tugas / Jadwal Terdeteksi (jika ada)
        ...tasks.map((t) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBlack, width: 1.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.notification_important_rounded,
                    color: Color(0xFFEAB308), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengingat: ${t.title}',
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Jatuh tempo: ${DateFormat('d MMM yyyy, HH:mm').format(t.dueDate)}',
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 14),

        // Tombol Aksi Konfirmasi
        Row(
          children: [
            Expanded(
              flex: 1,
              child: NeoButton(
                label: 'Ulangi',
                icon: Icons.refresh_rounded,
                backgroundColor: AppColors.cardWhite,
                textColor: AppColors.textBlack,
                height: 48,
                onPressed: () {
                  setState(() => _parsedResult = null);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: NeoButton(
                label: _isCommitting ? 'Menyimpan...' : 'Konfirmasi & Simpan',
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.mintGreen,
                textColor: AppColors.textBlack,
                height: 48,
                onPressed: hasActions && !_isCommitting ? _confirmAndCommit : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryAndSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Riwayat Teks Perintah
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.history_rounded,
                    size: 16, color: AppColors.textBlack),
                SizedBox(width: 6),
                Text(
                  'Riwayat Perintah Terakhir',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            if (_promptHistory.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  await AIService.instance.clearPromptHistory();
                  _loadHistory();
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (_promptHistory.isEmpty)
          const Text(
            'Belum ada riwayat perintah.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _promptHistory.take(6).map((prompt) {
              return GestureDetector(
                onTap: () {
                  _textController.text = prompt;
                  _processText(prompt);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.borderBlack, width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        offset: Offset(1, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.north_west_rounded,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          prompt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
