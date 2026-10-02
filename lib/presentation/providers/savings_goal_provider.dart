import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/repositories/savings_goal_repository.dart';

class SavingsGoalProvider extends ChangeNotifier {
  final SavingsGoalRepository _repository;

  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;

  SavingsGoalProvider({SavingsGoalRepository? repository})
      : _repository = repository ?? SavingsGoalRepository();

  List<SavingsGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  double get totalTarget =>
      _goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get totalSaved => _goals.fold(0.0, (sum, g) => sum + g.savedAmount);

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _repository.getAllGoals();
    } catch (e) {
      debugPrint('Error loading savings goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    double savedAmount = 0.0,
    DateTime? deadline,
    String icon = 'savings',
    String color = '#D6F0FF',
  }) async {
    final goal = SavingsGoalModel(
      id: 'sg_${const Uuid().v4().substring(0, 8)}',
      name: name,
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      deadline: deadline,
      icon: icon,
      color: color,
    );
    await _repository.insertGoal(goal);
    await loadGoals();
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    await _repository.updateGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await loadGoals();
  }

  Future<void> addFunds(String id, double amount) async {
    await _repository.addFunds(id, amount);
    await loadGoals();
  }
}
