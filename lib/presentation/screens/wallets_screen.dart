import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/wallet_provider.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/dialogs/add_wallet_dialog.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/neo_badge.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import 'transaction_history_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lavenderPurple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wadah Rekening',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => AddWalletDialog.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 2.2),
                          ),
                          child: const Icon(Icons.add, color: AppColors.textBlack),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => BalanceAdjustmentDialog.show(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.butterYellow,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderBlack, width: 2.2),
                          ),
                          child: const Icon(Icons.sync_alt, color: AppColors.textBlack),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Multi-Account Financial Ledger & Rekonsiliasi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 18),

              // Total Net Worth Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Akumulasi Seluruh Rekening',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(walletProv.totalBalance),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            NeoBadge(
                              text: 'ACID Transactions',
                              backgroundColor: AppColors.mintGreen,
                              fontSize: 10,
                            ),
                            SizedBox(width: 6),
                            NeoBadge(
                              text: 'Local SQLite',
                              backgroundColor: AppColors.skyBlue,
                              fontSize: 10,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => AddTransactionDialog.show(context, initialType: 'TRANSFER'),
                          child: const NeoBadge(
                            text: 'Transfer ➔',
                            backgroundColor: AppColors.bubblePink,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: '+ Tambah Wadah',
                      icon: Icons.account_balance_wallet_outlined,
                      backgroundColor: AppColors.butterYellow,
                      height: 48,
                      onPressed: () => AddWalletDialog.show(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoButton(
                      label: 'Transfer Dana',
                      icon: Icons.swap_horiz_rounded,
                      backgroundColor: AppColors.mintGreen,
                      height: 48,
                      onPressed: () => AddTransactionDialog.show(context, initialType: 'TRANSFER'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Wallets List
              const Text(
                'Daftar Wadah & Rekonsiliasi Saldo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),

              ...walletProv.wallets.map((wallet) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: NeoCard(
                    backgroundColor: AppColors.fromHex(wallet.color),
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionHistoryScreen(
                            initialWalletFilter: wallet.id,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardWhite,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.borderBlack, width: 2),
                                  ),
                                  child: Icon(
                                    _getWalletIcon(wallet.type),
                                    size: 20,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    Text(
                                      '${wallet.type} • Ketuk untuk lihat riwayat',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (wallet.isDefault)
                              const NeoBadge(
                                text: 'Utama',
                                backgroundColor: AppColors.cardWhite,
                                fontSize: 10,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(wallet.balance),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Row(
                              children: [
                                NeoButton(
                                  label: 'Cek Sisa',
                                  backgroundColor: AppColors.cardWhite,
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  onPressed: () => BalanceAdjustmentDialog.show(
                                    context,
                                    initialWalletId: wallet.id,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWalletIcon(String type) {
    switch (type) {
      case 'BANK':
        return Icons.account_balance_rounded;
      case 'EWALLET':
        return Icons.phone_android_rounded;
      case 'CASH':
      default:
        return Icons.payments_rounded;
    }
  }
}
