class TaskModel {
  final String id;
  final String? transactionId;
  final String title;
  final String description;
  final String priority; // LOW, MEDIUM, HIGH
  final String status; // PENDING, IN_PROGRESS, COMPLETED
  final String type; // EXPENSE, INCOME
  final String recurrence; // NONE, WEEKLY, MONTHLY
  final String? categoryId;
  final DateTime dueDate;
  final DateTime? reminderAt;
  final DateTime? completedAt;
  final double? estimatedAmount;
  final String? walletId;
  final DateTime createdAt;

  // Additional joined/display fields
  final String? walletName;
  final String? categoryName;

  TaskModel({
    required this.id,
    this.transactionId,
    required this.title,
    this.description = '',
    this.priority = 'MEDIUM',
    this.status = 'PENDING',
    this.type = 'EXPENSE',
    this.recurrence = 'NONE',
    this.categoryId,
    required this.dueDate,
    this.reminderAt,
    this.completedAt,
    this.estimatedAmount,
    this.walletId,
    DateTime? createdAt,
    this.walletName,
    this.categoryName,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => status == 'COMPLETED';
  bool get isIncome => type == 'INCOME';
  bool get isExpense => type != 'INCOME';
  bool get isRecurring => recurrence != 'NONE';

  TaskModel copyWith({
    String? id,
    String? transactionId,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? type,
    String? recurrence,
    String? categoryId,
    bool clearCategoryId = false,
    DateTime? dueDate,
    DateTime? reminderAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    double? estimatedAmount,
    String? walletId,
    bool clearWalletId = false,
    DateTime? createdAt,
    String? walletName,
    String? categoryName,
  }) {
    return TaskModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      createdAt: createdAt ?? this.createdAt,
      walletName: walletName ?? this.walletName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'type': type,
      'recurrence': recurrence,
      'category_id': categoryId,
      'due_date': dueDate.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'estimated_amount': estimatedAmount,
      'wallet_id': walletId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      transactionId: map['transaction_id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priority: map['priority'] as String? ?? 'MEDIUM',
      status: map['status'] as String? ?? 'PENDING',
      type: map['type'] as String? ?? 'EXPENSE',
      recurrence: map['recurrence'] as String? ?? 'NONE',
      categoryId: map['category_id'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      reminderAt: map['reminder_at'] != null
          ? DateTime.tryParse(map['reminder_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      estimatedAmount: (map['estimated_amount'] as num?)?.toDouble(),
      walletId: map['wallet_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      walletName: map['wallet_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }
}
