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
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.status == 'COMPLETED').toList();
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
        title: 'Pengingat SmartFlow: $title',
        body: estimatedAmount != null
            ? 'Estimasi: Rp ${estimatedAmount.toStringAsFixed(0)} • $description'
            : description.isNotEmpty
                ? description
                : 'Batas waktu tugas Anda sudah tiba!',
        scheduledDate: alarmTime,
      );
    }

    await loadTasks();
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    final isNowCompleted = task.status != 'COMPLETED';
    await _taskRepository.toggleTaskStatus(task.id, isNowCompleted);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await _notificationService.cancelAlarm(id.hashCode);
    await loadTasks();
  }
}
