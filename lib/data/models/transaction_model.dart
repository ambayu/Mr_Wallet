class TransactionModel {
  final String id;
  final String walletId;
  final String? toWalletId;
  final String? categoryId;
  final String type; // INCOME, EXPENSE, TRANSFER, ADJUSTMENT
  final double amount;
  final double? actualBalanceSnapshot;
  final String subType; // LOST_MONEY, ADMIN_FEE, INTEREST, REGULAR
  final String description;
  final String? receiptImagePath;
  final DateTime transactionDate;
  final DateTime createdAt;

  // Joined/display fields
  final String? walletName;
  final String? toWalletName;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  TransactionModel({
    required this.id,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.actualBalanceSnapshot,
    this.subType = 'REGULAR',
    required this.description,
    this.receiptImagePath,
    DateTime? transactionDate,
    DateTime? createdAt,
    this.walletName,
    this.toWalletName,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  })  : transactionDate = transactionDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  TransactionModel copyWith({
    String? id,
    String? walletId,
    String? toWalletId,
    String? categoryId,
    String? type,
    double? amount,
    double? actualBalanceSnapshot,
    String? subType,
    String? description,
    String? receiptImagePath,
    DateTime? transactionDate,
    DateTime? createdAt,
    String? walletName,
    String? toWalletName,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      toWalletId: toWalletId ?? this.toWalletId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      actualBalanceSnapshot:
          actualBalanceSnapshot ?? this.actualBalanceSnapshot,
      subType: subType ?? this.subType,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      walletName: walletName ?? this.walletName,
      toWalletName: toWalletName ?? this.toWalletName,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_id': walletId,
      'to_wallet_id': toWalletId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'actual_balance_snapshot': actualBalanceSnapshot,
      'sub_type': subType,
      'description': description,
      'receipt_image_path': receiptImagePath,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      walletId: map['wallet_id'] as String,
      toWalletId: map['to_wallet_id'] as String?,
      categoryId: map['category_id'] as String?,
      type: map['type'] as String? ?? 'EXPENSE',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      actualBalanceSnapshot:
          (map['actual_balance_snapshot'] as num?)?.toDouble(),
      subType: map['sub_type'] as String? ?? 'REGULAR',
      description: map['description'] as String? ?? '',
      receiptImagePath: map['receipt_image_path'] as String?,
      transactionDate: map['transaction_date'] != null
          ? DateTime.tryParse(map['transaction_date'] as String) ??
              DateTime.now()
          : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      walletName: map['wallet_name'] as String?,
      toWalletName: map['to_wallet_name'] as String?,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as String?,
    );
  }
}
