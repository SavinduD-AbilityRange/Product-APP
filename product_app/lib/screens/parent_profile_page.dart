import 'package:flutter/material.dart';

class ParentProfilePage extends StatefulWidget {
  @override
  _ParentProfilePageState createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _parentEmailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _checkParentAndSendOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    await Future.delayed(Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    Navigator.pushNamed(
      context,
      '/otp',
      arguments: {'email': _parentEmailController.text, 'isParent': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect Parent Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _parentEmailController,
                decoration: InputDecoration(labelText: 'Parent Email'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter parent email'
                            : null,
              ),
              SizedBox(height: 24),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 12),
              ],
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _checkParentAndSendOTP();
                      }
                    },
                    child: Text('Send OTP'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
