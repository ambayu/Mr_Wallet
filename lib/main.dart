import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/services/ai_service.dart';
import 'core/services/notification_service.dart';
import 'presentation/providers/ai_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/wallet_provider.dart';
import 'presentation/screens/auth/landing_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar and system navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize background services
  await NotificationService.instance.initialize();
  await AIService.instance.initialize();

  runApp(const SmartFlowApp());
}

class SmartFlowApp extends StatelessWidget {
  const SmartFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider()..loadWallets(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadInitialData(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider()..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => AIProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'SmartFlow Ledger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          if (kIsWeb) {
            return Container(
              color: const Color(0xFFE9ECEF),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 8),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: ClipRect(child: child),
                ),
              ),
            );
          }
          return child ?? const SizedBox();
        },
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isInitialized) {
              return const Scaffold(
                backgroundColor: Color(0xFFFFF0B3),
                body: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            }
            return auth.isLoggedIn
                ? const MainNavigationScreen()
                : const LandingScreen();
          },
        ),
      ),
    );
  }
}
