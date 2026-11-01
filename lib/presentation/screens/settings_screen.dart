import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import '../providers/auth_provider.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/task_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
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
  String _currentLanguage = 'Bahasa Indonesia';

  void _showPersonalDataDialog(BuildContext context, AuthProvider authProv) {
    final user = authProv.currentUser;
    final nameCtrl = TextEditingController(text: user?.username ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.butterYellow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: AppColors.borderBlack, width: 2.5),
                left: BorderSide(color: AppColors.borderBlack, width: 2.5),
                right: BorderSide(color: AppColors.borderBlack, width: 2.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ubah Data Pribadi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                NeoTextField(
                  controller: nameCtrl,
                  labelText: 'Nama Lengkap',
                  hintText: 'Nama panggilanmu',
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                NeoTextField(
                  controller: emailCtrl,
                  labelText: 'Alamat Email',
                  hintText: 'email@example.com',
                  prefixIcon: Icons.email_rounded,
                ),
                const SizedBox(height: 20),
                NeoButton(
                  label: 'Simpan Perubahan',
                  icon: Icons.check_rounded,
                  backgroundColor: AppColors.mintGreen,
                  textColor: AppColors.textBlack,
                  onPressed: () async {
                    await authProv.updateProfile(
                      username: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil berhasil diperbarui! ✨')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSecurityDialog(BuildContext context, AuthProvider authProv) {
    final user = authProv.currentUser;
    final pinCtrl = TextEditingController(text: user?.pin ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.butterYellow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: AppColors.borderBlack, width: 2.5),
                left: BorderSide(color: AppColors.borderBlack, width: 2.5),
                right: BorderSide(color: AppColors.borderBlack, width: 2.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Keamanan & PIN Akun',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'PIN digunakan untuk mengamankan data dan memverifikasi akses mutasi kas penting.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                NeoTextField(
                  controller: pinCtrl,
                  labelText: 'Kode PIN Baru (4-6 Angka)',
                  hintText: 'Misal: 1234',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: 20),
                NeoButton(
                  label: 'Simpan PIN Baru',
                  icon: Icons.shield_rounded,
                  backgroundColor: AppColors.skyBlue,
                  textColor: AppColors.textBlack,
                  onPressed: () async {
                    if (pinCtrl.text.trim().length < 4) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('PIN minimal harus 4 angka!')),
                      );
                      return;
                    }
                    await authProv.updateProfile(pin: pinCtrl.text.trim());
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN keamanan berhasil diperbarui! 🔒')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.butterYellow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.borderBlack, width: 2.5),
              left: BorderSide(color: AppColors.borderBlack, width: 2.5),
              right: BorderSide(color: AppColors.borderBlack, width: 2.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Bahasa Aplikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              ListTile(
                tileColor: _currentLanguage == 'Bahasa Indonesia' ? AppColors.primaryYellow : AppColors.cardWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderBlack, width: 1.8),
                ),
                leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                title: const Text('Bahasa Indonesia', style: TextStyle(fontWeight: FontWeight.w800)),
                trailing: _currentLanguage == 'Bahasa Indonesia' ? const Icon(Icons.check_circle, color: AppColors.textBlack) : null,
                onTap: () {
                  setState(() => _currentLanguage = 'Bahasa Indonesia');
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: _currentLanguage == 'English (US)' ? AppColors.primaryYellow : AppColors.cardWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderBlack, width: 1.8),
                ),
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English (US)', style: TextStyle(fontWeight: FontWeight.w800)),
                trailing: _currentLanguage == 'English (US)' ? const Icon(Icons.check_circle, color: AppColors.textBlack) : null,
                onTap: () {
                  setState(() => _currentLanguage = 'English (US)');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.butterYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
          ),
          title: Row(
            children: const [
              Icon(Icons.help_center_rounded, color: AppColors.textBlack),
              SizedBox(width: 8),
              Text(
                'Pusat Bantuan FAQ',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '💡 Bagaimana mencatat transaksi cepat?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                SizedBox(height: 3),
                Text(
                  'Gunakan fitur AI Chat atau Voice di bagian bawah layar. Cukup ketik atau bicara: "Beli kopi 25rb pakai Tunai".',
                  style: TextStyle(fontSize: 12, color: AppColors.textBlack),
                ),
                Divider(height: 18),
                Text(
                  '🎯 Bagaimana sistem target tabungan?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                SizedBox(height: 3),
                Text(
                  'Setiap target tabungan dapat dihubungkan ke dompet riil. Saat uang masuk ke dompet tersebut, progres target otomatis bertambah!',
                  style: TextStyle(fontSize: 12, color: AppColors.textBlack),
                ),
                Divider(height: 18),
                Text(
                  '⚖️ Apa itu fitur Rekonsiliasi Saldo?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                SizedBox(height: 3),
                Text(
                  'Jika uang di dompet fisikmu berselisih dengan catatan aplikasi, gunakan tombol Penyesuaian Saldo untuk mencatat Uang Hilang atau Selisih kas otomatis.',
                  style: TextStyle(fontSize: 12, color: AppColors.textBlack),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBlack)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.butterYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.borderBlack, width: 2.2),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_rounded, color: AppColors.textBlack),
              SizedBox(width: 8),
              Text(
                'Tentang Mr. Wallet',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.mascotSelfie, width: 75, height: 75),
              const SizedBox(height: 10),
              const Text(
                'Mr. Wallet (SmartFlow)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const Text(
                'Versi 2.0.0 (Production Build)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aplikasi manajemen keuangan pribadi pintar bergaya Neo-Brutalism dengan maskot kepiting sahabat setia cuan dan kantongmu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBlack)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmFactoryReset(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final walletProv = Provider.of<WalletProvider>(context, listen: false);
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final goalProv = Provider.of<SavingsGoalProvider>(context, listen: false);
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF0F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.dangerRed, width: 2.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hapus Seluruh Data?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.dangerRed),
                ),
              ),
            ],
          ),
          content: const Text(
            'Tindakan ini akan menghapus permanen semua catatan transaksi, dompet kustom, target tabungan, dan jadwal tugas.\n\nData tidak dapat dikembalikan lagi setelah dihapus!',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBlack),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textBlack)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderBlack, width: 1.5),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Hapus Semua Data', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // Eksekusi Factory Reset
      await AppDatabase.instance.resetAllData();

      if (mounted) {
        // Refresh semua provider ke data awal
        await walletProv.loadWallets();
        await txProv.loadInitialData();
        await goalProv.loadGoals();
        await taskProv.loadTasks();

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Seluruh data berhasil dibersihkan & direset ke kondisi awal! 🧹'),
            backgroundColor: AppColors.textBlack,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.currentUser;
    final userName = user?.username.isNotEmpty == true ? user!.username : 'Andi Pratama';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'andi.pratama@mail.com';

    return Scaffold(
      backgroundColor: const Color(0xFFFEF8A7),
      appBar: const NeoHeaderCard(
        title: 'Profil & Pengaturan',
        subtitle: 'Konfigurasi akun dan sistem',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Avatar with Crab Mascot matching Showcase Screen 10
              Center(
                child: GestureDetector(
                  onTap: () => _showPersonalDataDialog(context, authProv),
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
                      subtitle: 'Edit nama & email akun',
                      onTap: () => _showPersonalDataDialog(context, authProv),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Keamanan',
                      subtitle: 'Atur PIN kunci aplikasi',
                      onTap: () => _showSecurityDialog(context, authProv),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      subtitle: 'Pengingat transaksi harian',
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
                      subtitle: _currentLanguage,
                      onTap: () => _showLanguageSelector(context),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Pusat Bantuan',
                      subtitle: 'Pertanyaan umum (FAQ)',
                      onTap: () => _showHelpCenterDialog(context),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Mr Wallet',
                      subtitle: 'Versi & informasi pengembang',
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.delete_forever_rounded,
                      title: 'Reset & Hapus Seluruh Data',
                      subtitle: 'Kembalikan aplikasi ke awal',
                      iconColor: AppColors.dangerRed,
                      titleColor: AppColors.dangerRed,
                      onTap: () => _confirmFactoryReset(context),
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
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor != null ? iconColor.withValues(alpha: 0.15) : AppColors.pillGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.textBlack),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: titleColor ?? AppColors.textBlack,
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
