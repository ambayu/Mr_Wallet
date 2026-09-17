class UserModel {
  final String username;
  final String email;
  final String pin;
  final String avatar;
  final DateTime createdAt;

  UserModel({
    required this.username,
    required this.email,
    required this.pin,
    this.avatar = 'crab_happy',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'pin': pin,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      pin: map['pin'] as String? ?? '1234',
      avatar: map['avatar'] as String? ?? 'crab_happy',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
