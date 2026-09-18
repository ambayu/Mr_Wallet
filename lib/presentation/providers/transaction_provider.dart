import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  List<TransactionModel> _recentTransactions = [];
  List<CategoryModel> _categories = [];
  double _monthlySpending = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyGrowthPercentage = 0.0;
  List<Map<String, dynamic>> _categorySpending = [];
  List<Map<String, dynamic>> _monthlyTrend = [];
  bool _isLoading = false;

  TransactionProvider({
    TransactionRepository? transactionRepository,
    CategoryRepository? categoryRepository,
  })  : _transactionRepository =
            transactionRepository ?? TransactionRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository();

  List<TransactionModel> get recentTransactions => _recentTransactions;
  List<TransactionModel> get transactions => _recentTransactions;
  List<CategoryModel> get categories => _categories;
  double get monthlySpending => _monthlySpending;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyGrowthPercentage => _monthlyGrowthPercentage;
  List<Map<String, dynamic>> get categorySpending => _categorySpending;
  List<Map<String, dynamic>> get monthlyTrend => _monthlyTrend;
  bool get isLoading => _isLoading;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getAllCategories();
      await refreshTransactions();
    } catch (e) {
      debugPrint('Error loading transactions data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTransactions() async {
    final now = DateTime.now();
    _recentTransactions = await _transactionRepository.getRecentTransactions(limit: 30);
    _monthlySpending = await _transactionRepository.getMonthlySpending(now);
    _monthlyIncome = await _transactionRepository.getMonthlyIncome(now);
    _categorySpending = await _transactionRepository.getCategorySpending(now);
    _monthlyTrend = await _transactionRepository.getMonthlyTrend(now.year);

    // Hitung pertumbuhan real net balance / income dibanding bulan lalu
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthIncome = await _transactionRepository.getMonthlyIncome(lastMonth);
    final lastMonthExpense = await _transactionRepository.getMonthlySpending(lastMonth);
    final lastMonthNet = lastMonthIncome - lastMonthExpense;
    final thisMonthNet = _monthlyIncome - _monthlySpending;

    if (lastMonthNet > 0) {
      _monthlyGrowthPercentage = ((thisMonthNet - lastMonthNet) / lastMonthNet) * 100.0;
    } else if (lastMonthIncome > 0) {
      _monthlyGrowthPercentage = ((_monthlyIncome - lastMonthIncome) / lastMonthIncome) * 100.0;
    } else if (thisMonthNet > 0) {
      _monthlyGrowthPercentage = 100.0;
    } else {
      _monthlyGrowthPercentage = 0.0;
    }

    notifyListeners();
  }

  Future<void> addTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String description,
    DateTime? date,
  }) async {
    await addTransaction(
      walletId: fromWalletId,
      toWalletId: toWalletId,
      type: 'TRANSFER',
      amount: amount,
      description: description,
      transactionDate: date,
    );
  }

  // ACID Add Transaction
  Future<void> addTransaction({
    required String walletId,
    String? toWalletId,
    String? categoryId,
    required String type, // INCOME, EXPENSE, TRANSFER, ADJUSTMENT
    required double amount,
    required String description,
    String? receiptImagePath,
    DateTime? transactionDate,
    String subType = 'REGULAR',
  }) async {
    final newTx = TransactionModel(
      id: 'tx_${const Uuid().v4().substring(0, 8)}',
      walletId: walletId,
      toWalletId: toWalletId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      subType: subType,
      description: description,
      receiptImagePath: receiptImagePath,
      transactionDate: transactionDate ?? DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _transactionRepository.addTransaction(newTx);
    await refreshTransactions();
  }

  // Core Feature: Deteksi Uang Hilang & Penyesuaian Saldo Riil
  Future<TransactionModel> reconcileWalletBalance({
    required String walletId,
    required double actualBalance,
    required String subType, // LOST_MONEY, ADMIN_FEE, INTEREST, REGULAR
    String? customNote,
  }) async {
    final txId = 'adj_${const Uuid().v4().substring(0, 8)}';
    final result = await _transactionRepository.reconcileWalletBalance(
      transactionId: txId,
      walletId: walletId,
      actualBalance: actualBalance,
      subType: subType,
      customNote: customNote,
    );

    await refreshTransactions();
    return result;
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    await _transactionRepository.deleteTransaction(transaction);
    await refreshTransactions();
  }
}
