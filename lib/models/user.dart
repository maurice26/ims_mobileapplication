enum Role { admin, sales, user }

class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString().toLowerCase() ?? 'user';
    return User(
      id: (json['userId'] ?? json['id'])?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: roleStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role};
  }

  String get roleDisplay => role.capitalize();

  Role get roleEnum {
    switch (role.toLowerCase()) {
      case 'admin':
        return Role.admin;
      case 'sales':
        return Role.sales;
      default:
        return Role.user;
    }
  }

  bool canAccess(String requiredRoleStr) {
    const roleLevels = {'admin': 3, 'sales': 2, 'user': 1};
    final userLevel = roleLevels[role.toLowerCase()] ?? 1;
    final reqLevel = roleLevels[requiredRoleStr.toLowerCase()] ?? 1;
    return userLevel >= reqLevel;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
