import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final NotificationService _notificationService;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  TaskProvider({
    TaskRepository? taskRepository,
    NotificationService? notificationService,
  })  : _taskRepository = taskRepository ?? TaskRepository(),
        _notificationService =
            notificationService ?? NotificationService.instance;

  List<TaskModel> get tasks => _tasks;
  
  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => t.status != 'COMPLETED').toList();

  List<TaskModel> get pendingExpenses =>
      _tasks.where((t) => t.status != 'COMPLETED' && t.isExpense).toList();

  List<TaskModel> get pendingIncomes =>
      _tasks.where((t) => t.status != 'COMPLETED' && t.isIncome).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.status == 'COMPLETED').toList();

  double get totalPendingExpense =>
      pendingExpenses.fold(0.0, (sum, t) => sum + (t.estimatedAmount ?? 0.0));

  double get totalPendingIncome =>
      pendingIncomes.fold(0.0, (sum, t) => sum + (t.estimatedAmount ?? 0.0));

  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _taskRepository.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String description = '',
    String priority = 'MEDIUM',
    String type = 'EXPENSE',
    String recurrence = 'NONE',
    String? categoryId,
    required DateTime dueDate,
    DateTime? reminderAt,
    double? estimatedAmount,
    String? walletId,
  }) async {
    final id = 'tsk_${const Uuid().v4().substring(0, 8)}';
    final task = TaskModel(
      id: id,
      title: title,
      description: description,
      priority: priority,
      type: type,
      recurrence: recurrence,
      categoryId: categoryId,
      dueDate: dueDate,
      reminderAt: reminderAt ?? dueDate,
      estimatedAmount: estimatedAmount,
      walletId: walletId,
    );

    await _taskRepository.addTask(task);

    // Schedule notification if reminderAt is set
    if (reminderAt != null || dueDate.isAfter(DateTime.now())) {
      final alarmTime = reminderAt ?? dueDate;
      await _notificationService.scheduleTaskAlarm(
        id: id.hashCode,
        title: 'Pengingat Mr. Wallet: $title',
        body: estimatedAmount != null
            ? '${type == 'INCOME' ? 'Pemasukan' : 'Tagihan'}: Rp ${estimatedAmount.toStringAsFixed(0)} • $description'
            : description.isNotEmpty
                ? description
                : 'Batas waktu tugas keuangan Anda sudah tiba!',
        scheduledDate: alarmTime,
      );
    }

    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskRepository.updateTask(task);
    await loadTasks();
  }

  /// Eksekusi Finansial saat task dicentang (langsung potong/tambah saldo dompet & catat transaksi)
  Future<void> completeTaskWithFinancialAction({
    required TaskModel task,
    required String walletId,
    double? customAmount,
  }) async {
    await _taskRepository.executeTaskCompletion(
      task: task,
      walletId: walletId,
      customAmount: customAmount,
    );
    await loadTasks();
  }

  /// Membatalkan penyelesaian task (revert saldo & hapus transaksi)
  Future<void> revertTask(TaskModel task) async {
    await _taskRepository.revertTaskCompletion(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await _notificationService.cancelAlarm(id.hashCode);
    await loadTasks();
  }
}
