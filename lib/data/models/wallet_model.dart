class WalletModel {
  final String id;
  final String name;
  final String type; // CASH, BANK, EWALLET
  final double balance;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WalletModel copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? icon,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String? ?? 'CASH',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      icon: map['icon'] as String? ?? 'account_balance_wallet',
      color: map['color'] as String? ?? '#FFF0B3',
      isDefault: (map['is_default'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
