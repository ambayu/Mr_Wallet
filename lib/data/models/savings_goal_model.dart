class SavingsGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;
  final String icon;
  final String color;
  final String? walletId; // Dompet acuan pengumpulan dana
  final String? walletName; // Nama dompet acuan (joined/display)
  final String? walletIcon; // Ikon dompet acuan (joined/display)
  final double? currentWalletBalance; // Saldo aktual dompet acuan saat ini
  final bool isCompleted; // Status selesai/arsip
  final DateTime? completedAt; // Tanggal diselesaikan
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.deadline,
    this.icon = 'savings',
    this.color = '#D6F0FF',
    this.walletId,
    this.walletName,
    this.walletIcon,
    this.currentWalletBalance,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Progres ketercapaian (0.0 - 1.0)
  /// Jika ada walletId dan currentWalletBalance diisi, gunakan saldo aktual dompet acuan
  double get effectiveSavedAmount => currentWalletBalance ?? savedAmount;

  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (effectiveSavedAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).toInt();

  double get remaining => (targetAmount - effectiveSavedAmount).clamp(0.0, targetAmount);

  bool get isAchieved => isCompleted || (targetAmount > 0 && effectiveSavedAmount >= targetAmount);

  SavingsGoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    bool clearDeadline = false,
    String? icon,
    String? color,
    String? walletId,
    bool clearWalletId = false,
    String? walletName,
    String? walletIcon,
    double? currentWalletBalance,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? createdAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      icon: icon ?? this.icon,
      color: color ?? this.color,
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      walletName: walletName ?? this.walletName,
      walletIcon: walletIcon ?? this.walletIcon,
      currentWalletBalance: currentWalletBalance ?? this.currentWalletBalance,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
      'color': color,
      'wallet_id': walletId,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (map['saved_amount'] as num?)?.toDouble() ?? 0.0,
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'] as String)
          : null,
      icon: map['icon'] as String? ?? 'savings',
      color: map['color'] as String? ?? '#D6F0FF',
      walletId: map['wallet_id'] as String?,
      walletName: map['wallet_name'] as String?,
      walletIcon: map['wallet_icon'] as String?,
      currentWalletBalance: (map['current_wallet_balance'] as num?)?.toDouble() ??
          (map['wallet_balance'] as num?)?.toDouble(),
      isCompleted: map['is_completed'] == 1 || map['is_completed'] == true,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
