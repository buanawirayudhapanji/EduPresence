class UserModel {
  final String? id;
  final String username;
  final String email;
  final String password;
  final String role; // 'admin' or 'user'
  final bool isActive;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'is_active': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String? ?? '',
      role: map['role'] as String,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
