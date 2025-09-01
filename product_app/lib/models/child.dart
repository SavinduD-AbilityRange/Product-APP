class Child {
  final int id;
  final int userId;
  final String username;
  final String email;
  final DateTime? dob;

  Child({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.dob,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
    );
  }
}