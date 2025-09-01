import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  PasswordStrengthMeter({required this.password});

  int _strengthLevel(String pw) {
    if (pw.length < 6) return 0;
    bool hasUpper = pw.contains(RegExp(r'[A-Z]'));
    bool hasLower = pw.contains(RegExp(r'[a-z]'));
    bool hasDigit = pw.contains(RegExp(r'[0-9]'));
    bool hasSpecial = pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    int score =
        [hasUpper, hasLower, hasDigit, hasSpecial].where((b) => b).length;
    if (score <= 1) return 1;
    if (score == 2) return 2;
    if (score >= 3) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    int level = _strengthLevel(password);
    String label = '';
    Color color = Colors.red;
    switch (level) {
      case 0:
        label = 'Too short';
        color = Colors.red;
        break;
      case 1:
        label = 'Weak';
        color = Colors.orange;
        break;
      case 2:
        label = 'Medium';
        color = Colors.yellow[700]!;
        break;
      case 3:
        label = 'Strong';
        color = Colors.green;
        break;
    }
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: level / 3,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 6,
          ),
        ),
        SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
