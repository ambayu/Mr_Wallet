import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ai_service.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/mascot_art.dart';
import '../widgets/neo_badge.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_text_field.dart';
import 'auth/landing_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isSaved = false;
  String _currentKey = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final key = await AIService.instance.getApiKey();
    setState(() {
      _currentKey = key;
      _apiKeyController.text = key;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.currentUser;
    final isOnlineAI = _currentKey.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.butterYellow,
      appBar: AppBar(
        backgroundColor: AppColors.butterYellow,
        elevation: 0,
        title: const Text(
          'Pengaturan & Profil',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Neo Card
              NeoCard(
                backgroundColor: AppColors.skyBlue,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 2.2),
                      ),
                      child: const Center(
                        child: CrabMascotWidget(
                          mood: MascotMood.coolSkater,
                          size: 42,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'Bang Bayu',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Text(
                            user?.email ?? 'bayu@smartflow.app',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const NeoBadge(
                            text: 'Status: Aktif (PIN Terproteksi)',
                            backgroundColor: AppColors.mintGreen,
                            fontSize: 9,
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Gemini AI Settings Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gemini 1.5 Flash AI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                        ),
                        NeoBadge(
                          text: isOnlineAI ? 'Cloud AI Aktif' : 'Offline Engine',
                          backgroundColor: isOnlineAI
                              ? AppColors.mintGreen
                              : AppColors.butterYellow,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masukkan Google Gemini API Key untuk inferensi natural voice dan vision OCR struk mutakhir. Jika kosong, SmartFlow tetap bekerja 100% offline dengan aturan deterministik.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    NeoTextField(
                      controller: _apiKeyController,
                      labelText: 'Google Gemini API Key',
                      hintText: 'AIzaSy...',
                      prefixIcon: Icons.key_rounded,
                    ),
                    const SizedBox(height: 14),
                    NeoButton(
                      label: _isSaved ? 'Tersimpan!' : 'Simpan API Key',
                      icon: Icons.save_rounded,
                      backgroundColor: AppColors.mintGreen,
                      onPressed: () async {
                        final key = _apiKeyController.text.trim();
                        await AIService.instance.setApiKey(key);
                        setState(() {
                          _currentKey = key;
                          _isSaved = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _isSaved = false);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Data Management & Storage Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manajemen Data Local-First',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Semua data mutasi dan tugas disimpan di SQLite lokal perangkat Anda dengan integritas ACID.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    NeoButton(
                      label: 'Sinkronkan Ulang Data',
                      icon: Icons.refresh_rounded,
                      backgroundColor: AppColors.skyBlue,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final walletProv = Provider.of<WalletProvider>(
                            context,
                            listen: false);
                        final txProv = Provider.of<TransactionProvider>(
                            context,
                            listen: false);
                        final taskProv = Provider.of<TaskProvider>(
                            context,
                            listen: false);

                        await walletProv.loadWallets();
                        await txProv.refreshTransactions();
                        await taskProv.loadTasks();

                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.borderBlack,
                              content: Text(
                                'Data lokal berhasil disegarkan!',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Logout Action
              NeoButton(
                label: 'Keluar dari Akun (Logout)',
                icon: Icons.logout_rounded,
                backgroundColor: const Color(0xFFFF8A8A),
                textColor: AppColors.textBlack,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await authProv.logout();
                  if (mounted) {
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LandingScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 18),

              // App Info
              NeoCard(
                backgroundColor: AppColors.bubblePink,
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SmartFlow Ledger v1.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        NeoBadge(
                          text: 'Flutter 3.x',
                          backgroundColor: AppColors.cardWhite,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dibuat dengan filosofi local-first deterministik, multi-account ledger, dan tema Playful Neo-Brutalism.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
