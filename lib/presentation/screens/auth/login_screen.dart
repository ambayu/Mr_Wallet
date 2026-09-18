import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/neo_button.dart';
import '../../widgets/neo_text_field.dart';
import '../main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController =
      TextEditingController(text: 'andi.pratama@mail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '1234');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan Password/PIN tidak boleh kosong!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.login(identifier, password);

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
          _errorMessage = 'Password salah! (Gunakan default: 1234 atau daftar akun baru)';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Mascot Peeking & Greeting Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 12),
                        Text(
                          'Halo\nKembali!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Senang melihatmu lagi! 👋',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppAssets.mascotHappy,
                    width: 105,
                    height: 105,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Inputs matching UI Showcase Screen 2
              NeoTextField(
                controller: _identifierController,
                hintText: 'Email atau Nomor HP',
                prefixIcon: Icons.mail_outline_rounded,
                backgroundColor: AppColors.cardWhite,
              ),
              const SizedBox(height: 16),

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

              // Remember me & Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _rememberMe ? AppColors.primaryYellow : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderBlack, width: 1.6),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 14, color: AppColors.textBlack)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ingat saya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gunakan PIN default: 1234 untuk login demo'),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
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
              const SizedBox(height: 24),

              // Yellow Submit Button: "Masuk"
              NeoButton(
                label: _isLoading ? 'Memproses...' : 'Masuk',
                backgroundColor: AppColors.primaryYellow,
                textColor: AppColors.textBlack,
                height: 52,
                borderRadius: 26,
                onPressed: _isLoading ? null : _handleLogin,
              ),
              const SizedBox(height: 24),

              // "atau masuk dengan"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.borderLight, thickness: 1.2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau masuk dengan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.borderLight, thickness: 1.2)),
                ],
              ),
              const SizedBox(height: 18),

              // Social Login Buttons: Google & Apple
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'G',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEA4335),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.apple, size: 26, color: AppColors.textBlack),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Switch to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
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
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
