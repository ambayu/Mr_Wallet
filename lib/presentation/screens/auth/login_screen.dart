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
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'Bang Bayu');
  final TextEditingController _pinController =
      TextEditingController(text: '1234');
  bool _obscurePin = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      setState(() {
        _errorMessage = 'Username dan PIN tidak boleh kosong!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.login(username, pin);

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
          _errorMessage = 'PIN salah! Coba gunakan PIN 1234 atau registrasi baru.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.butterYellow,
      appBar: AppBar(
        backgroundColor: AppColors.butterYellow,
        elevation: 0,
        title: const Text(
          'Masuk ke SmartFlow',
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
              // Mascot Greeting
              const Center(
                child: CrabMascotWidget(
                  mood: MascotMood.holdingCoin,
                  size: 110,
                  speechBubbleText: 'Selamat Datang!',
                ),
              ),
              const SizedBox(height: 18),

              // Login Form Card
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
                          'Autentikasi Akun',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                          ),
                        ),
                        NeoBadge(
                          text: 'PIN Aman',
                          backgroundColor: AppColors.mintGreen,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Username Input
                    NeoTextField(
                      controller: _usernameController,
                      labelText: 'Nama Pengguna / Email',
                      hintText: 'Misal: Bang Bayu / bayu@mail.com',
                      prefixIcon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 14),

                    // PIN Input
                    NeoTextField(
                      controller: _pinController,
                      labelText: 'Security PIN / Password',
                      hintText: '4-6 digit PIN (Default: 1234)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.lock_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePin
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textBlack,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePin = !_obscurePin);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Demo Login helper chip
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _usernameController.text = 'Bang Bayu';
                          _pinController.text = '1234';
                        });
                      },
                      child: const NeoBadge(
                        text: '⚡ Isi Cepat Demo: Bang Bayu (PIN: 1234)',
                        backgroundColor: AppColors.butterYellow,
                        fontSize: 10,
                      ),
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
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 18, color: Color(0xFFC0392B)),
                            const SizedBox(width: 8),
                            Expanded(
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
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Submit Button
                    NeoButton(
                      label: _isLoading ? 'Memverifikasi...' : 'Masuk Sekarang ➔',
                      icon: Icons.login_rounded,
                      backgroundColor: AppColors.mintGreen,
                      height: 52,
                      onPressed: _isLoading ? null : _handleLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Switch to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
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
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar Baru',
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
