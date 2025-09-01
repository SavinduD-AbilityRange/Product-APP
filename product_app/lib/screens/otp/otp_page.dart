import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../product_table_page.dart';

class OTPPage extends StatefulWidget {
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;
  String? _error;

  void _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // TODO: Call backend API to verify OTP
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => ProductTablePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(counterText: ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '';
                        if (!RegExp(r'^[0-9]$').hasMatch(value)) return '';
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      inputFormatters: [
                        
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  );
                }),
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
                        _verifyOTP();
                      }
                    },
                    child: Text('Verify'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
