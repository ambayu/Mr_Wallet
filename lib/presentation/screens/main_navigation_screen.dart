import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/dialogs/ai_voice_modal.dart';
import '../widgets/dialogs/balance_adjustment_dialog.dart';
import '../widgets/dialogs/camera_bill_snap_modal.dart';
import '../widgets/neo_bottom_nav.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';
import 'track_screen.dart';
import 'transaction_history_screen.dart';
import 'wallets_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _showActionHub() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
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
                  'Aksi Cepat SmartFlow',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bubblePink,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlack, width: 2),
                    ),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textBlack),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    ctx: ctx,
                    title: 'Voice AI',
                    subtitle: 'Bicara perintah',
                    icon: Icons.mic_rounded,
                    bgColor: AppColors.lavenderPurple,
                    onTap: () {
                      Navigator.pop(ctx);
                      AIVoiceModal.show(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    ctx: ctx,
                    title: 'Snap Struk',
                    subtitle: 'OCR & Vision AI',
                    icon: Icons.camera_alt_rounded,
                    bgColor: AppColors.mintGreen,
                    onTap: () {
                      Navigator.pop(ctx);
                      CameraBillSnapModal.show(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    ctx: ctx,
                    title: 'Uang Hilang',
                    subtitle: 'Cek selisih saku',
                    icon: Icons.search_rounded,
                    bgColor: AppColors.butterYellow,
                    onTap: () {
                      Navigator.pop(ctx);
                      BalanceAdjustmentDialog.show(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    ctx: ctx,
                    title: 'Catat Manual',
                    subtitle: 'Pemasukan/Keluar',
                    icon: Icons.edit_note_rounded,
                    bgColor: AppColors.bubblePink,
                    onTap: () {
                      Navigator.pop(ctx);
                      AddTransactionDialog.show(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              ctx: ctx,
              title: 'Jadwal & Target Baru',
              subtitle: 'Atur task dengan alarm pengingat deterministik',
              icon: Icons.alarm_add_rounded,
              bgColor: AppColors.skyBlue,
              onTap: () {
                Navigator.pop(ctx);
                AddTaskDialog.show(context);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    ctx: ctx,
                    title: 'Riwayat Lengkap',
                    subtitle: 'Audit & filter',
                    icon: Icons.history_rounded,
                    bgColor: AppColors.butterYellow,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    ctx: ctx,
                    title: 'Pengaturan & AI',
                    subtitle: 'API key & sistem',
                    icon: Icons.settings_rounded,
                    bgColor: AppColors.cardWhite,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderBlack, width: 2),
              ),
              child: Icon(icon, size: 20, color: AppColors.textBlack),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSeeAllTransactions: () {
          setState(() {
            _currentIndex = 1; // Go to Track/Transactions
          });
        },
      ),
      const TrackScreen(),
      const WalletsScreen(),
      const TasksScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NeoBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onSmartAITap: _showActionHub,
            ),
          ),
        ],
      ),
    );
  }
}
