import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mascot_art.dart';
import '../../widgets/neo_badge.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/neo_text_field.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      setState(() {
        _errorMessage = 'Nama dan PIN wajib diisi!';
      });
      return;
    }

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'Konfirmasi PIN tidak cocok!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.register(
      username: username,
      email: email.isNotEmpty ? email : '$username@smartflow.app',
      pin: pin,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'Gagal mendaftarkan akun. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintGreen,
      appBar: AppBar(
        backgroundColor: AppColors.mintGreen,
        elevation: 0,
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mascot
              const Center(
                child: CrabMascotWidget(
                  mood: MascotMood.peeking,
                  size: 100,
                  speechBubbleText: 'Gabung SmartFlow!',
                ),
              ),
              const SizedBox(height: 18),

              // Register Card
              NeoCard(
                backgroundColor: AppColors.cardWhite,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Data Pengguna',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                        ),
                        NeoBadge(
                          text: 'Lokal 100%',
                          backgroundColor: AppColors.butterYellow,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name Suggestions (Teman Fattah)
                    const Text(
                      'Pilih Profil Teman atau Buat Sendiri:',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Bang Bayu',
                          'Bang Lofty',
                          'Kak Desi',
                          'Kemal',
                          'Ryan',
                        ].map((name) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _usernameController.text = name;
                                  _emailController.text =
                                      '${name.toLowerCase().replaceAll(" ", "")}@smartflow.app';
                                  _pinController.text = '1234';
                                  _confirmPinController.text = '1234';
                                });
                              },
                              child: NeoBadge(
                                text: name,
                                backgroundColor: AppColors.skyBlue,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Username Input
                    NeoTextField(
                      controller: _usernameController,
                      labelText: 'Nama Lengkap / Panggilan',
                      hintText: 'Misal: Bang Bayu / Sarah',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Email Input
                    NeoTextField(
                      controller: _emailController,
                      labelText: 'Email (Opsional)',
                      hintText: 'bayu@smartflow.app',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 14),

                    // PIN Input
                    NeoTextField(
                      controller: _pinController,
                      labelText: 'Buat 4-Digit Security PIN',
                      hintText: 'Misal: 1234',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 14),

                    // Confirm PIN Input
                    NeoTextField(
                      controller: _confirmPinController,
                      labelText: 'Ulangi PIN',
                      hintText: 'Masukkan 4 digit PIN yang sama',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.lock_reset_rounded,
                    ),

                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD4D4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderBlack, width: 1.5),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC0392B),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Submit Button
                    NeoButton(
                      label: _isLoading ? 'Membuat Akun...' : 'Buat Akun & Masuk ➔',
                      icon: Icons.check_circle_outline,
                      backgroundColor: AppColors.butterYellow,
                      height: 52,
                      onPressed: _isLoading ? null : _handleRegister,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Switch to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Masuk ke Akun',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.borderBlack,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
