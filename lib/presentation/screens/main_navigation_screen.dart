import 'package:flutter/material.dart';
import '../widgets/app_background_scaffold.dart';
import '../widgets/neo_bottom_nav.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSeeAllTransactions: () {
          setState(() => _currentIndex = 1);
        },
        onNavigateTab: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      const TransactionHistoryScreen(),
      const TrackScreen(),
      const WalletsScreen(),
      const SettingsScreen(),
    ];

    return AppBackgroundScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NeoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

