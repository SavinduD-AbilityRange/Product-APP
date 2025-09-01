import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? _jwtToken;

  ApiService({required this.baseUrl});

  void setToken(String token) {
    _jwtToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
  };

  Future<http.Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String address,
    required String dob,
    File? profileImage,
  }) async {
    var uri = Uri.parse('$baseUrl/register');
    var request = http.MultipartRequest('POST', uri);
    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['address'] = address;
    request.fields['dob'] = dob;
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', profileImage.path),
      );
    }
    request.headers.addAll(_headers);
    var streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    var uri = Uri.parse('$baseUrl/login');
    return await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> sendOtp({
    required String email,
    bool isParent = false,
  }) async {
    var uri = Uri.parse('$baseUrl/send-otp');
    return await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'email': email, 'is_parent': isParent}),
    );
  }

  Future<http.Response> verifyOtp({
    required String email,
    required String otp,
    bool isParent = false,
  }) async {
    var uri = Uri.parse('$baseUrl/verify-otp');
    return await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'email': email, 'otp': otp, 'is_parent': isParent}),
    );
  }
}
