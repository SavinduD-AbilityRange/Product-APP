import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Android Emulator Network Test ===');

  // Test different URLs that Android emulator should be able to reach
  final testUrls = [
    'http://10.0.2.2:8000', // Standard Android emulator host mapping
    'http://192.168.8.132:8000', // Your computer's actual IP
    'http://localhost:8000', // Sometimes works on newer emulators
    'http://127.0.0.1:8000', // Local loopback
  ];

  for (String url in testUrls) {
    print('\n🧪 Testing: $url');

    try {
      // Test basic connectivity
      final pingUrl = '$url/ping';
      print('  Attempting ping to: $pingUrl');

      final response = await http
          .get(
            Uri.parse(pingUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      print('  ✅ Status: ${response.statusCode}');
      print('  ✅ Response: ${response.body}');

      // Test products endpoint
      final productsUrl = '$url/products';
      print('  Attempting products fetch from: $productsUrl');

      final productsResponse = await http
          .get(
            Uri.parse(productsUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      print('  ✅ Products Status: ${productsResponse.statusCode}');

      if (productsResponse.statusCode == 200) {
        final data = json.decode(productsResponse.body);
        if (data is Map && data.containsKey('products')) {
          print('  ✅ Products found: ${data['products'].length}');
        }
      }

      print('  🎉 SUCCESS: $url is reachable!');
    } catch (e) {
      print('  ❌ FAILED: $e');

      if (e.toString().contains('TimeoutException')) {
        print(
          '     Connection timed out - server might not be running or reachable',
        );
      } else if (e.toString().contains('SocketException')) {
        print(
          '     Network error - check if server is accessible from this network',
        );
      } else {
        print('     Unknown error - $e');
      }
    }
  }

  print('\n=== Network Test Complete ===');
  print('\nFor Android Emulator troubleshooting:');
  print('1. Make sure your backend server is running on port 8000');
  print('2. The server should bind to 0.0.0.0:8000 (not just localhost)');
  print('3. Check firewall settings - port 8000 should be open');
  print('4. On macOS, try: lsof -i :8000 to see if server is listening');
  print('5. The working URL above should be used in your Android emulator');
}
