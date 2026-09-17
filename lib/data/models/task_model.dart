class TaskModel {
  final String id;
  final String? transactionId;
  final String title;
  final String description;
  final String priority; // LOW, MEDIUM, HIGH
  final String status; // PENDING, IN_PROGRESS, COMPLETED
  final DateTime dueDate;
  final DateTime? reminderAt;
  final double? estimatedAmount;
  final String? walletId;
  final DateTime createdAt;

  // Additional joined field
  final String? walletName;

  TaskModel({
    required this.id,
    this.transactionId,
    required this.title,
    this.description = '',
    this.priority = 'MEDIUM',
    this.status = 'PENDING',
    required this.dueDate,
    this.reminderAt,
    this.estimatedAmount,
    this.walletId,
    DateTime? createdAt,
    this.walletName,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => status == 'COMPLETED';

  TaskModel copyWith({
    String? id,
    String? transactionId,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? reminderAt,
    double? estimatedAmount,
    String? walletId,
    DateTime? createdAt,
    String? walletName,
  }) {
    return TaskModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      walletId: walletId ?? this.walletId,
      createdAt: createdAt ?? this.createdAt,
      walletName: walletName ?? this.walletName,
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
      'due_date': dueDate.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
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
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      reminderAt: map['reminder_at'] != null
          ? DateTime.tryParse(map['reminder_at'] as String)
          : null,
      estimatedAmount: (map['estimated_amount'] as num?)?.toDouble(),
      walletId: map['wallet_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      walletName: map['wallet_name'] as String?,
    );
  }
}
