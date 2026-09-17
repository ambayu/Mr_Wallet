import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/ai_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../mascot_art.dart';
import '../neo_badge.dart';
import '../neo_button.dart';
import '../neo_card.dart';
import '../neo_text_field.dart';

class AIVoiceModal extends StatefulWidget {
  const AIVoiceModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AIVoiceModal(),
    );
  }

  @override
  State<AIVoiceModal> createState() => _AIVoiceModalState();
}

class _AIVoiceModalState extends State<AIVoiceModal> {
  final TextEditingController _textPromptController = TextEditingController();
  bool _isCommitting = false;

  @override
  void dispose() {
    _textPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiProv = Provider.of<AIProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);

    final walletNames = walletProv.wallets.map((w) => w.name).toList();
    final categoryNames = txProv.categories.map((c) => c.name).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.lavenderPurple,
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
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.textBlack),
                      SizedBox(width: 8),
                      Text(
                        'Smart AI Assistant',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      aiProv.clearResults();
                      Navigator.pop(context);
                    },
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
              const SizedBox(height: 16),

              // Cute Mascot Centerpiece
              CrabMascotWidget(
                mood: aiProv.isListening
                    ? MascotMood.happy
                    : aiProv.isProcessing
                        ? MascotMood.thinking
                        : aiProv.lastParsedResult != null
                            ? MascotMood.holdingCoin
                            : MascotMood.peeking,
                size: 76,
                speechBubbleText: aiProv.isListening
                    ? 'Mendengarkan suara...'
                    : aiProv.isProcessing
                        ? 'Menganalisis kalimatmu...'
                        : aiProv.lastParsedResult != null
                            ? 'Hasil ekstraksi siap!'
                            : 'Katakan perintahmu!',
              ),
              const SizedBox(height: 16),

              // Voice Action Button
              GestureDetector(
                onTap: () async {
                  if (aiProv.isListening) {
                    await aiProv.stopAndProcessVoice(
                      walletNames: walletNames,
                      categoryNames: categoryNames,
                    );
                  } else {
                    await aiProv.startVoiceRecording();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: aiProv.isListening
                        ? AppColors.coralOrange
                        : AppColors.butterYellow,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.borderBlack, width: 2.8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowBlack,
                        offset: Offset(3, 3.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        aiProv.isListening ? Icons.stop_circle : Icons.mic_rounded,
                        color: AppColors.textBlack,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        aiProv.isListening
                            ? 'Tekan Selesai Bicara'
                            : 'Ketuk Untuk Bicara (Voice AI)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Text Prompt Input Alternative
              Row(
                children: [
                  Expanded(
                    child: NeoTextField(
                      controller: _textPromptController,
                      hintText: 'Atau ketik: Beli kopi 25rb & besok servis jam 2',
                      prefixIcon: Icons.keyboard_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeoButton(
                    width: 54,
                    height: 52,
                    backgroundColor: AppColors.mintGreen,
                    icon: Icons.send_rounded,
                    onPressed: () {
                      if (_textPromptController.text.trim().isNotEmpty) {
                        aiProv.processTextCommand(
                          _textPromptController.text.trim(),
                          walletNames: walletNames,
                          categoryNames: categoryNames,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Suggestion Prompt Chips
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Coba Contoh Perintah Cepat:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSuggestionChip(
                      'Beli kopi 25rb uang dompet & meeting jam 3',
                      aiProv,
                      walletNames,
                      categoryNames,
                    ),
                    const SizedBox(width: 6),
                    _buildSuggestionChip(
                      'Uang dompet sisa 30 ribu',
                      aiProv,
                      walletNames,
                      categoryNames,
                    ),
                    const SizedBox(width: 6),
                    _buildSuggestionChip(
                      'Berapa total pengeluaranku bulan ini?',
                      aiProv,
                      walletNames,
                      categoryNames,
                    ),
                    const SizedBox(width: 6),
                    _buildSuggestionChip(
                      'Beli bensin 30rb pakai ATM BCA dan servis motor besok',
                      aiProv,
                      walletNames,
                      categoryNames,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Preview Section (PRD 3.4 & 7.3: Konfirmasi Transparan)
              if (aiProv.lastParsedResult != null) ...[
                _buildParsedPreviewCard(aiProv, walletProv, txProv),
              ],

              if (aiProv.errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD4D4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBlack, width: 2),
                  ),
                  child: Text(
                    aiProv.errorMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC0392B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParsedPreviewCard(
    AIProvider aiProv,
    WalletProvider walletProv,
    TransactionProvider txProv,
  ) {
    final result = aiProv.lastParsedResult!;
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    return NeoCard(
      backgroundColor: AppColors.cardWhite,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pratinjau Hasil AI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textBlack,
                ),
              ),
              NeoBadge(
                text: result.intent,
                backgroundColor: AppColors.mintGreen,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.naturalResponse,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textBlack,
            ),
          ),
          const Divider(color: AppColors.borderBlack, height: 20),

          // Extracted Transactions
          if (result.transactions.isNotEmpty) ...[
            const Text(
              'Transaksi yang terdeteksi:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(height: 6),
            ...result.transactions.map((tx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.butterYellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tx.category} • ${tx.walletName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          tx.notes,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(tx.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Extracted Tasks
          if (result.tasks.isNotEmpty) ...[
            const Text(
              'Jadwal/Target yang terdeteksi:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(height: 6),
            ...result.tasks.map((tsk) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bubblePink,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tsk.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Batas: ${DateFormatter.formatDateTime(tsk.dueDate)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    NeoBadge(
                      text: tsk.priority,
                      backgroundColor: AppColors.cardWhite,
                      fontSize: 10,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Summary Query Response Insight
          if (result.summaryRequest?.isRequested == true) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.skyBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderBlack, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.query_stats, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Ringkasan Keuangan Saat Ini:',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total Seluruh Saldo: ${CurrencyFormatter.format(walletProv.totalBalance)}\n'
                    'Pengeluaran Bulan Ini: ${CurrencyFormatter.format(txProv.monthlySpending)}\n'
                    'Pemasukan Bulan Ini: ${CurrencyFormatter.format(txProv.monthlyIncome)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Confirmation Commit Button
          if (result.transactions.isNotEmpty || result.tasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            NeoButton(
              label: _isCommitting ? 'Menyimpan...' : 'Konfirmasi & Simpan ke DB',
              icon: Icons.check_circle_outline,
              backgroundColor: AppColors.mintGreen,
              onPressed: _isCommitting
                  ? null
                  : () async {
                      setState(() => _isCommitting = true);

                      // Save extracted transactions
                      for (final tx in result.transactions) {
                        final matchedWallet = walletProv.wallets.firstWhere(
                          (w) => w.name.toLowerCase().contains(tx.walletName.toLowerCase()),
                          orElse: () => walletProv.wallets.first,
                        );

                        final matchedCat = txProv.categories.firstWhere(
                          (c) => c.name.toLowerCase().contains(tx.category.toLowerCase()),
                          orElse: () => txProv.categories.first,
                        );

                        if (tx.type == 'ADJUSTMENT' && tx.targetActualBalance != null) {
                          await txProv.reconcileWalletBalance(
                            walletId: matchedWallet.id,
                            actualBalance: tx.targetActualBalance!,
                            subType: 'LOST_MONEY',
                            customNote: tx.notes,
                          );
                        } else {
                          await txProv.addTransaction(
                            walletId: matchedWallet.id,
                            categoryId: matchedCat.id,
                            type: tx.type,
                            amount: tx.amount,
                            description: tx.notes.isNotEmpty ? tx.notes : tx.category,
                          );
                        }
                      }

                      // Save extracted tasks
                      for (final tsk in result.tasks) {
                        String? boundWalletId;
                        if (tsk.walletName != null) {
                          final w = walletProv.wallets.firstWhere(
                            (w) => w.name.toLowerCase().contains(tsk.walletName!.toLowerCase()),
                            orElse: () => walletProv.wallets.first,
                          );
                          boundWalletId = w.id;
                        }

                        await taskProv.addTask(
                          title: tsk.title,
                          dueDate: tsk.dueDate,
                          priority: tsk.priority,
                          estimatedAmount: tsk.estimatedAmount,
                          walletId: boundWalletId,
                        );
                      }

                      await walletProv.loadWallets();

                      if (mounted) {
                        setState(() => _isCommitting = false);
                        aiProv.clearResults();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.borderBlack,
                            content: Text(
                              'Hasil AI berhasil diverifikasi & disimpan!',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    String prompt,
    AIProvider aiProv,
    List<String> walletNames,
    List<String> categoryNames,
  ) {
    return GestureDetector(
      onTap: () {
        _textPromptController.text = prompt;
        aiProv.processTextCommand(
          prompt,
          walletNames: walletNames,
          categoryNames: categoryNames,
        );
      },
      child: NeoBadge(
        text: prompt,
        backgroundColor: AppColors.cardWhite,
        fontSize: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
