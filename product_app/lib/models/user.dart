import 'package:product_app/models/child.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String password;
  final DateTime? dob;
  final List<Child> children;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.dob,
    this.children = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => Child.fromJson(c))
              .toList() ??
          [],
    );
  }
}

