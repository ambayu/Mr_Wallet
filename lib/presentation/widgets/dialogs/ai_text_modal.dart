import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/ai_parsed_result.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../providers/ai_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../neo_button.dart';

/// Model pesan dalam dialog chat percakapan dengan AI
class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;
  final AIParsedResult? parsedResult;
  final bool isCommitted;

  _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imagePath,
    this.parsedResult,
    this.isCommitted = false,
  }) : timestamp = timestamp ?? DateTime.now();

  _ChatMessage copyWith({
    bool? isCommitted,
  }) {
    return _ChatMessage(
      id: id,
      text: text,
      isUser: isUser,
      timestamp: timestamp,
      imagePath: imagePath,
      parsedResult: parsedResult,
      isCommitted: isCommitted ?? this.isCommitted,
    );
  }
}

/// Modal Percakapan Interaktif AI (Gaya Balas-Berbalas Chat / WhatsApp / ChatGPT + Fitur Kamera/Foto Struk).
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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _committingMessageId;
  final Map<String, String> _selectedWalletOverrides = {}; // key: messageId_txIndex, value: walletId

  final List<String> _quickSuggestions = [
    'Beli kopi 25rb pakai Dompet Tunai',
    'Gaji masuk 5.000.000 ke ATM BCA',
    'Transfer 500rb dari Tunai ke BCA',
    'Beli bensin 30rb tunai dan ingatkan servis lusa',
  ];

  @override
  void initState() {
    super.initState();

    // Pesan sambutan awal dari Mr. Wallet
    _messages.add(
      _ChatMessage(
        id: 'welcome',
        text: 'Halo! Aku Mr. Wallet, si kepiting pecinta cuan dan penjaga setia dompetmu! 🦀💰 Ceritakan transaksi belanja, uang masuk, atau kirim foto struk di sini ya!',
        isUser: false,
      ),
    );

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSend();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? customText]) async {
    final rawText = customText ?? _textController.text;
    final clean = rawText.trim();
    if (clean.isEmpty || _isLoading) return;

    _textController.clear();

    final userMsgId = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = _ChatMessage(
      id: userMsgId,
      text: clean,
      isUser: true,
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

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

      final aiMsgId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
      final aiMsg = _ChatMessage(
        id: aiMsgId,
        text: result.naturalResponse.isNotEmpty
            ? result.naturalResponse
            : 'Siap, ini rincian yang berhasil aku pahami:',
        isUser: false,
        parsedResult: result,
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMsg);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _ChatMessage(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Waduh, koneksi ke server Mr. Wallet bermasalah: $e. Coba cek internet atau ulangi lagi ya!',
          isUser: false,
        );
        setState(() {
          _messages.add(errorMsg);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showMediaPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.5),
              left: BorderSide(color: AppColors.borderBlack, width: 2.5),
              right: BorderSide(color: AppColors.borderBlack, width: 2.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderBlack.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Kirim Gambar / Struk Belanja',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickAndProcessImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
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
                          child: const Column(
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 28, color: AppColors.textBlack),
                              SizedBox(height: 6),
                              Text(
                                'Buka Kamera',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickAndProcessImage(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue,
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
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_rounded, size: 28, color: AppColors.textBlack),
                              SizedBox(height: 6),
                              Text(
                                'Pilih Galeri',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (photo == null) return;

      final userMsgId = 'img_${DateTime.now().millisecondsSinceEpoch}';
      final userMsg = _ChatMessage(
        id: userMsgId,
        text: source == ImageSource.camera ? 'Foto struk via Kamera' : 'Foto struk dari Galeri',
        isUser: true,
        imagePath: photo.path,
      );

      setState(() {
        _messages.add(userMsg);
        _isLoading = true;
      });
      _scrollToBottom();

      if (!mounted) return;
      final aiProv = Provider.of<AIProvider>(context, listen: false);
      final walletProv = Provider.of<WalletProvider>(context, listen: false);

      await aiProv.processBillImage(
        imagePath: photo.path,
        rawOCRText: 'TOTAL RP 45.000\nKAFE MEDAN\n1 KOPI SUSU 25.000\n1 ROTI BAKAR 20.000',
      );

      final ocr = aiProv.lastOCRResult;
      final defaultWallet = walletProv.wallets.isNotEmpty ? walletProv.wallets.first.name : 'Dompet Tunai';

      final txList = <AIParsedTransaction>[];
      if (ocr != null) {
        txList.add(
          AIParsedTransaction(
            walletName: defaultWallet,
            type: 'EXPENSE',
            amount: ocr.totalAmount,
            category: ocr.category.isNotEmpty ? ocr.category : 'Belanja',
            notes: 'Struk: ${ocr.merchantName}',
          ),
        );
      }

      final parsedResult = AIParsedResult(
        intent: 'TRANSACTION_ENTRY',
        transactions: txList,
        naturalResponse: ocr != null
            ? 'Struk ${ocr.merchantName} sebesar ${CurrencyFormatter.formatRupiah(ocr.totalAmount)} berhasil dibaca.'
            : 'Foto struk diterima.',
      );

      final aiMsg = _ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: parsedResult.naturalResponse,
        isUser: false,
        parsedResult: parsedResult,
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMsg);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _ChatMessage(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Gagal membaca struk: $e',
          isUser: false,
        );
        setState(() {
          _messages.add(errorMsg);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _commitTransactions(String messageId, AIParsedResult result) async {
    setState(() => _committingMessageId = messageId);

    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    try {
      for (int i = 0; i < result.transactions.length; i++) {
        final tx = result.transactions[i];
        final overrideWalletId = _selectedWalletOverrides['${messageId}_$i'];

        WalletModel? matchedWallet;
        if (overrideWalletId != null) {
          matchedWallet = walletProv.wallets.firstWhere(
            (w) => w.id == overrideWalletId,
            orElse: () => walletProv.wallets.first,
          );
        } else {
          for (final w in walletProv.wallets) {
            if (w.name.toLowerCase() == tx.walletName.toLowerCase() ||
                tx.walletName.toLowerCase().contains(w.name.toLowerCase())) {
              matchedWallet = w;
              break;
            }
          }
          matchedWallet ??= walletProv.wallets.isNotEmpty
              ? walletProv.wallets.firstWhere((w) => w.isDefault, orElse: () => walletProv.wallets.first)
              : null;
        }

        if (matchedWallet == null) continue;

        CategoryModel? matchedCategory;
        for (final c in txProv.categories) {
          if (c.name.toLowerCase() == tx.category.toLowerCase() ||
              tx.category.toLowerCase().contains(c.name.toLowerCase()) ||
              c.name.toLowerCase().contains(tx.category.toLowerCase())) {
            matchedCategory = c;
            break;
          }
        }
        matchedCategory ??= txProv.categories.isNotEmpty ? txProv.categories.first : null;

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
            description: tx.notes.isNotEmpty ? tx.notes : (matchedCategory?.name ?? 'Transaksi'),
            transactionDate: DateTime.now(),
          );
        }
      }

      for (final task in result.tasks) {
        String? matchedWalletId;
        if (task.walletName != null) {
          final matched = walletProv.wallets.firstWhere(
            (w) => w.name.toLowerCase() == task.walletName!.toLowerCase() ||
                task.walletName!.toLowerCase().contains(w.name.toLowerCase()),
            orElse: () => walletProv.wallets.first,
          );
          matchedWalletId = matched.id;
        }

        await taskProv.addTask(
          title: task.title,
          dueDate: task.dueDate,
          priority: task.priority,
          estimatedAmount: task.estimatedAmount,
          walletId: matchedWalletId,
          type: task.type,
          recurrence: task.recurrence,
        );
      }

      await walletProv.loadWallets();
      await txProv.refreshTransactions();

      if (mounted) {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          setState(() {
            _messages[index] = _messages[index].copyWith(isCommitted: true);
            _messages.add(
              _ChatMessage(
                id: 'success_${DateTime.now().millisecondsSinceEpoch}',
                text: 'Berhasil dicatat ke catatan keuanganmu! 🎉 Ada lagi yang mau kamu catat?',
                isUser: false,
              ),
            );
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _committingMessageId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: screenHeight * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.butterYellow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.borderBlack, width: 2.5),
            left: BorderSide(color: AppColors.borderBlack, width: 2.5),
            right: BorderSide(color: AppColors.borderBlack, width: 2.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header Chat
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderBlack, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 1.8),
                      ),
                      child: const Center(
                        child: Text(
                          '🦀',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teman Keuangan (Mr. Wallet)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                              SizedBox(width: 4),
                              Text(
                                'Online • Siap Bantu Kamu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlack, width: 1.5),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textBlack),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return _buildAILoadingBubble();
                    }
                    final msg = _messages[index];
                    return _buildChatBubble(msg);
                  },
                ),
              ),

              // Quick Suggestions (Jika masih sedikit pesan)
              if (_messages.length <= 2)
                Container(
                  height: 36,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickSuggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final item = _quickSuggestions[i];
                      return GestureDetector(
                        onTap: () => _handleSend(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderBlack, width: 1.4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryYellow),
                              const SizedBox(width: 4),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Chat Input Bar (Gaya WA/ChatGPT + Lampiran Foto/Kamera)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.cardWhite,
                  border: Border(
                    top: BorderSide(color: AppColors.borderBlack, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    // Tombol Upload Foto / Kamera
                    GestureDetector(
                      onTap: _showMediaPickerSheet,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlack, width: 1.8),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowBlack,
                              offset: Offset(1.5, 1.5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Input Text Area
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderBlack, width: 1.6),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (v) => _handleSend(),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Ketik transaksi atau foto struk...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Kirim
                    GestureDetector(
                      onTap: () => _handleSend(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlack, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowBlack,
                              offset: Offset(1.5, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (msg.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(msg.imagePath!),
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      msg.text,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('HH:mm').format(msg.timestamp),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.skyBlue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderBlack, width: 1.6),
              ),
              child: const Icon(Icons.person_rounded, size: 18, color: AppColors.textBlack),
            ),
          ],
        ),
      );
    }

    // AI Response Bubble
    final hasActions = msg.parsedResult != null &&
        (msg.parsedResult!.transactions.isNotEmpty || msg.parsedResult!.tasks.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 1.6),
            ),
            child: const Center(
              child: Text('🦀', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
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
                        msg.text,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('HH:mm').format(msg.timestamp),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Jika AI menghasilkan tindakan transaksi/task
                if (hasActions) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderBlack, width: 1.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.textBlack),
                            SizedBox(width: 6),
                            Text(
                              'Konfirmasi Aksi Sistem',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 14, color: AppColors.borderBlack),
                        ...msg.parsedResult!.transactions.asMap().entries.map((entry) {
                          final txIndex = entry.key;
                          final t = entry.value;
                          final isIncome = t.type == 'INCOME';
                          final isTransfer = t.type == 'TRANSFER';

                          final walletProv = Provider.of<WalletProvider>(context, listen: false);
                          final overrideKey = '${msg.id}_$txIndex';
                          final currentSelectedWalletId = _selectedWalletOverrides[overrideKey] ??
                              (() {
                                final matched = walletProv.wallets.firstWhere(
                                  (w) => w.name.toLowerCase() == t.walletName.toLowerCase() ||
                                      t.walletName.toLowerCase().contains(w.name.toLowerCase()),
                                  orElse: () => walletProv.wallets.isNotEmpty
                                      ? walletProv.wallets.firstWhere((w) => w.isDefault, orElse: () => walletProv.wallets.first)
                                      : WalletModel(id: 'w_cash', name: 'Dompet Tunai', type: 'CASH', balance: 0, icon: 'account_balance_wallet', color: 'primaryYellow'),
                                );
                                return matched.id;
                              })();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isIncome
                                            ? AppColors.mintGreen
                                            : isTransfer
                                                ? AppColors.skyBlue
                                                : AppColors.bubblePink,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.borderBlack, width: 0.8),
                                      ),
                                      child: Text(
                                        isIncome ? 'Masuk' : (isTransfer ? 'Transfer' : 'Keluar'),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t.notes.isNotEmpty ? t.notes : t.category,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatRupiah(t.amount),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!msg.isCommitted && walletProv.wallets.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        isIncome ? 'Masuk ke:' : 'Potong dari:',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Container(
                                          height: 28,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F4F5),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.borderBlack, width: 1),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: walletProv.wallets.any((w) => w.id == currentSelectedWalletId)
                                                  ? currentSelectedWalletId
                                                  : walletProv.wallets.first.id,
                                              isExpanded: true,
                                              isDense: true,
                                              icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textBlack),
                                              items: walletProv.wallets.map((w) {
                                                return DropdownMenuItem(
                                                  value: w.id,
                                                  child: Text(
                                                    '${w.name} (${CurrencyFormatter.formatShort(w.balance)})',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textBlack,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (newId) {
                                                if (newId != null) {
                                                  setState(() {
                                                    _selectedWalletOverrides[overrideKey] = newId;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        ...msg.parsedResult!.tasks.map((task) {
                          final isIncome = task.type == 'INCOME';
                          final amount = task.estimatedAmount ?? 0.0;
                          final recurrenceText = task.recurrence == 'MONTHLY'
                              ? 'Tiap Bulan'
                              : (task.recurrence == 'WEEKLY' ? 'Tiap Minggu' : 'Sekali');

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderBlack, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isIncome ? Icons.monetization_on_rounded : Icons.alarm_rounded,
                                    size: 16,
                                    color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${isIncome ? 'Jadwal Gaji' : 'Jadwal Tagihan'}: ${task.title}',
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                                        ),
                                        Text(
                                          'Pengulangan: $recurrenceText',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (amount > 0)
                                    Text(
                                      '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(amount)}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                        color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        if (msg.isCommitted)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.mintGreen,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderBlack, width: 1.2),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 14, color: AppColors.textBlack),
                                SizedBox(width: 6),
                                Text(
                                  'Sudah Tersimpan di Database',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          )
                        else
                          NeoButton(
                            label: _committingMessageId == msg.id ? 'Menyimpan...' : 'Simpan Transaksi',
                            icon: Icons.check_rounded,
                            backgroundColor: AppColors.primaryYellow,
                            height: 44,
                            borderRadius: 14,
                            onPressed: _committingMessageId == msg.id
                                ? null
                                : () => _commitTransactions(msg.id, msg.parsedResult!),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAILoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 1.6),
            ),
            child: const Center(
              child: Text('🦀', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderBlack, width: 1.6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textBlack),
                ),
                SizedBox(width: 8),
                Text(
                  'Mr. Wallet sedang mengetik...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
