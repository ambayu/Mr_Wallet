import 'package:flutter/foundation.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletProvider extends ChangeNotifier {
  final WalletRepository _walletRepository;

  List<WalletModel> _wallets = [];
  double _totalBalance = 0.0;
  bool _isLoading = false;
  String? _selectedWalletId;

  WalletProvider({WalletRepository? walletRepository})
      : _walletRepository = walletRepository ?? WalletRepository();

  List<WalletModel> get wallets => _wallets;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  String? get selectedWalletId => _selectedWalletId;

  WalletModel? get selectedWallet {
    if (_wallets.isEmpty) return null;
    if (_selectedWalletId == null) return _wallets.first;
    return _wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
      orElse: () => _wallets.first,
    );
  }

  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await _walletRepository.getAllWallets();
      _totalBalance = await _walletRepository.getTotalBalance();
      if (_selectedWalletId == null && _wallets.isNotEmpty) {
        final def = _wallets.firstWhere((w) => w.isDefault, orElse: () => _wallets.first);
        _selectedWalletId = def.id;
      }
    } catch (e) {
      debugPrint('Error loading wallets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectWallet(String walletId) {
    _selectedWalletId = walletId;
    notifyListeners();
  }

  Future<void> addWallet(WalletModel wallet) async {
    await _walletRepository.insertWallet(wallet);
    await loadWallets();
  }

  Future<void> updateWallet(WalletModel wallet) async {
    await _walletRepository.updateWallet(wallet);
    await loadWallets();
  }
}
