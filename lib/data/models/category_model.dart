class CategoryModel {
  final String id;
  final String name;
  final String type; // INCOME, EXPENSE, ADJUSTMENT
  final String icon;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    String? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String? ?? 'EXPENSE',
      icon: map['icon'] as String? ?? 'category',
      color: map['color'] as String? ?? '#BFF2A5',
    );
  }
}
