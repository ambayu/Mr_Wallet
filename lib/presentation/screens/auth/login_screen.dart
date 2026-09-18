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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Top Mascot Peeking & Greeting Header with Overlap Stack
                      SizedBox(
                        height: 165,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Text Column (Bawah Kiri)
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Halo\nKembali!',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBlack,
                                      height: 0.95,
                                      letterSpacing: -1.2,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.textBlack,
                                          offset: Offset(0.3, 0.3),
                                          blurRadius: 0,
                                        ),
                                        Shadow(
                                          color: AppColors.textBlack,
                                          offset: Offset(-0.3, -0.3),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Senang melihatmu lagi! 👋',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBlack,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Big Mascot Overlapping without pushing or wrapping text
                            Positioned(
                              right: -14,
                              bottom: -8,
                              child: Image.asset(
                                AppAssets.mascotLogin,
                                width: 205,
                                height: 205,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

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
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF1E3A8A),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        backgroundColor: AppColors.cardWhite,
                      ),
                      const SizedBox(height: 16),

                      // Remember me & Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _rememberMe ? const Color(0xFFFFD54F) : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.borderBlack, width: 2),
                                  ),
                                  child: _rememberMe
                                      ? const Icon(Icons.check, size: 16, color: AppColors.textBlack)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ingat saya',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
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
                      const SizedBox(height: 24),

                      // Yellow Submit Button: "Masuk"
                      NeoButton(
                        label: _isLoading ? 'Memproses...' : 'Masuk',
                        backgroundColor: const Color(0xFFFFEB7D),
                        textColor: AppColors.textBlack,
                        height: 54,
                        borderRadius: 28,
                        onPressed: _isLoading ? null : _handleLogin,
                      ),
                      const SizedBox(height: 24),

                      // "atau masuk dengan"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1.2)),
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
                          const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1.2)),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Social Login Button: Masuk dengan Google
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur Masuk dengan Google segera hadir! ✨'),
                            ),
                          );
                        },
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
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
                              SizedBox(width: 10),
                              Text(
                                'Masuk dengan Google',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Switch to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                              'Daftar Sekarang',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
