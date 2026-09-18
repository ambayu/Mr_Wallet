import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background_scaffold.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Nama dan Password wajib diisi!';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Konfirmasi Password tidak cocok!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.register(
      username: name,
      email: email.isNotEmpty ? email : '$name@mrwallet.app',
      pin: password,
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
    return AppBackgroundScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header matching Showcase Screen 3
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mulai perjalanan finansial lebih baik bersama Mr Wallet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              NeoTextField(
                controller: _nameController,
                hintText: 'Nama Lengkap',
                prefixIcon: Icons.person_outline_rounded,
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 14),

              NeoTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 14),

              NeoTextField(
                controller: _phoneController,
                hintText: 'Nomor HP',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 14),

              NeoTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 14),

              NeoTextField(
                controller: _confirmPasswordController,
                hintText: 'Konfirmasi Password',
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icons.lock_reset_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                backgroundColor: AppColors.cardWhite,
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bubblePink,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.dangerRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Motivational mascot badge matching showcase
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderBlack, width: 1.8),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.mascotLaptop,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Langkah kecil menuju masa depan besar bersama Mr Wallet!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Yellow Submit Button: "Daftar"
              NeoButton(
                label: _isLoading ? 'Mendaftarkan...' : 'Daftar',
                backgroundColor: AppColors.primaryYellow,
                textColor: AppColors.textBlack,
                height: 52,
                borderRadius: 26,
                onPressed: _isLoading ? null : _handleRegister,
              ),
              const SizedBox(height: 20),

              // Switch to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
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
                      'Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
