import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ai_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_header_card.dart';
import '../widgets/neo_text_field.dart';
import 'auth/landing_screen.dart';
import 'notification_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  String _currentKey = '';

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
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

  void _showApiKeyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.2),
              left: BorderSide(color: AppColors.borderBlack, width: 2.2),
              right: BorderSide(color: AppColors.borderBlack, width: 2.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gemini AI API Key',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Digunakan untuk Vision OCR struk belanja & Voice AI Assistant tingkat lanjut.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              NeoTextField(
                controller: _apiKeyController,
                hintText: 'AIzaSy...',
                prefixIcon: Icons.key_rounded,
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 18),
              NeoButton(
                label: 'Simpan API Key',
                backgroundColor: AppColors.primaryYellow,
                height: 48,
                borderRadius: 24,
                onPressed: () async {
                  await AIService.instance.saveApiKey(_apiKeyController.text.trim());
                  await _loadApiKey();
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API Key berhasil disimpan!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.currentUser;
    final userName = user?.username.isNotEmpty == true ? user!.username : 'Andi Pratama';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'andi.pratama@mail.com';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NeoHeaderCard(
        title: 'Profil & Pengaturan',
        subtitle: 'Konfigurasi akun dan sistem',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textBlack),
            onPressed: _showApiKeyDialog,
            tooltip: 'Konfigurasi AI',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // User Avatar with Crab Mascot matching Showcase Screen 10
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlack, width: 2.2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowBlack,
                            offset: Offset(2.5, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.mascotSelfie,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlack, width: 1.5),
                        ),
                        child: const Icon(Icons.edit, size: 14, color: AppColors.textBlack),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Name & Email
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),

              // Badge: Member Premium matching Screen 10
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(1.5, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star_rounded, size: 16, color: AppColors.textBlack),
                    SizedBox(width: 4),
                    Text(
                      'Member Premium',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Menu Card matching Showcase Screen 10
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                borderRadius: 22,
                borderWidth: 1.8,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Data Pribadi',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Keamanan',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      title: 'Bahasa',
                      subtitle: 'Bahasa Indonesia',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.smart_toy_outlined,
                      title: 'Koneksi Cloud AI',
                      subtitle: _currentKey.isNotEmpty ? 'Aktif (Gemini Flash)' : 'Belum Dikonfigurasi',
                      onTap: _showApiKeyDialog,
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Pusat Bantuan',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Mr Wallet',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Speech / Quote Banner matching Showcase Screen 10
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.butterYellow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderBlack, width: 1.8),
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
                    Image.asset(
                      AppAssets.mascotHearts,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Keuangan baik, hidup lebih baik! 🦀❤️',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pink "Keluar" Button matching Showcase Screen 10
              NeoButton(
                label: 'Keluar',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.bubblePink,
                textColor: AppColors.textBlack,
                height: 50,
                borderRadius: 25,
                onPressed: () async {
                  await authProv.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LandingScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.pillGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.textBlack),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textBlack,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 22,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
