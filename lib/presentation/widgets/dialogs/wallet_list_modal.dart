import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/wallet_icon_helper.dart';
import '../../providers/wallet_provider.dart';
import '../../screens/wallet_detail_screen.dart';
import 'add_wallet_dialog.dart';

class WalletListModal extends StatelessWidget {
  final String selectedWalletId;
  final ValueChanged<String> onSelectWallet;

  const WalletListModal({
    super.key,
    required this.selectedWalletId,
    required this.onSelectWallet,
  });

  static Future<void> show(
    BuildContext context, {
    required String selectedWalletId,
    required ValueChanged<String> onSelectWallet,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WalletListModal(
        selectedWalletId: selectedWalletId,
        onSelectWallet: onSelectWallet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = Provider.of<WalletProvider>(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 150),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.5),
              left: BorderSide(color: AppColors.borderBlack, width: 2.5),
              right: BorderSide(color: AppColors.borderBlack, width: 2.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header Modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Wadah Dompet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Text(
                    'Total Saldo: ${CurrencyFormatter.formatRupiah(walletProv.totalBalance)}',
                    style: const TextStyle(
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
                    border: Border.all(color: AppColors.borderBlack, width: 1.6),
                  ),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textBlack),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List Wadah Dompet
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...walletProv.wallets.map((wallet) {
                  final isCurrentSelected = selectedWalletId == wallet.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentSelected ? AppColors.mintGreen : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderBlack,
                          width: isCurrentSelected ? 2.2 : 1.6,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            offset: Offset(1.5, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.fromHex(wallet.color),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderBlack, width: 1.6),
                          ),
                          child: Icon(
                            WalletIconHelper.resolve(wallet.icon),
                            size: 22,
                            color: AppColors.textBlack,
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                wallet.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textBlack,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (wallet.isDefault) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderBlack, width: 0.8),
                                ),
                                child: const Text(
                                  'Utama',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          CurrencyFormatter.formatRupiah(wallet.balance),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBlack,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Pilih untuk Filter
                            GestureDetector(
                              onTap: () {
                                onSelectWallet(wallet.id);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isCurrentSelected ? AppColors.textBlack : AppColors.butterYellow,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderBlack, width: 1.2),
                                ),
                                child: Text(
                                  isCurrentSelected ? 'Aktif' : 'Pilih',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isCurrentSelected ? Colors.white : AppColors.textBlack,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tombol Buka Detail Page Dompet
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WalletDetailScreen(wallet: wallet),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderBlack, width: 1.2),
                                ),
                                child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textBlack),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Tambah Wadah Baru
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              AddWalletDialog.show(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.textBlack),
                  SizedBox(width: 6),
                  Text(
                    '+ Tambah Wadah Rekening Baru',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
