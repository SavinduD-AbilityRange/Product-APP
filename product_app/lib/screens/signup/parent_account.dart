import 'package:flutter/material.dart';

class ParentAccountScreen extends StatelessWidget {
  final String childUsername;
  final String childEmail;
  final DateTime childDob;

  const ParentAccountScreen({
    Key? key,
    required this.childUsername,
    required this.childEmail,
    required this.childDob,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Account'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Parent/Guardian Account Setup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text('Child Username: $childUsername'),
              Text('Child Email: $childEmail'),
              Text(
                'Child DOB: ${childDob.year}-${childDob.month}-${childDob.day}',
              ),
              const SizedBox(height: 24),
              const Text('Implement parent account creation here.'),
            ],
          ),
        ),
      ),
    );
  }
}
