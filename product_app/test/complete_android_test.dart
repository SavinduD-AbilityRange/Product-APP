import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Complete Android Emulator Setup Test ===');

  // Test URLs that should work for Android emulator
  final testUrls = [
    'http://10.0.2.2:8000', // Standard Android emulator mapping
    'http://192.168.8.132:8000', // Your computer's IP (if server binds to 0.0.0.0)
  ];

  print('1. Testing your backend server accessibility...\n');

  for (String baseUrl in testUrls) {
    print('🧪 Testing: $baseUrl');

    // Test the exact URLs your Flutter app will use
    final endpoints = ['/ping', '/products', '/check-env'];

    bool allEndpointsWork = true;

    for (String endpoint in endpoints) {
      final fullUrl = '$baseUrl$endpoint';
      try {
        print('  📡 Testing: $fullUrl');

        final response = await http
            .get(
              Uri.parse(fullUrl),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          print('  ✅ SUCCESS: Status ${response.statusCode}');

          // Parse response to check structure
          try {
            final data = json.decode(response.body);
            if (endpoint == '/products' &&
                data is Map &&
                data.containsKey('products')) {
              print(
                '  ✅ Products format: Found ${data['products'].length} products',
              );
            } else if (endpoint == '/ping') {
              print('  ✅ Ping response: ${data['message'] ?? 'OK'}');
            }
          } catch (e) {
            print(
              '  ⚠️  Response not JSON: ${response.body.substring(0, 50)}...',
            );
          }
        } else {
          print('  ❌ HTTP Error: Status ${response.statusCode}');
          allEndpointsWork = false;
        }
      } catch (e) {
        print('  ❌ Connection failed: $e');
        allEndpointsWork = false;

        if (e.toString().contains('TimeoutException')) {
          print('     → Server not reachable or too slow');
        } else if (e.toString().contains('SocketException')) {
          print('     → Network connection failed');
        }
      }
    }

    if (allEndpointsWork) {
      print('  🎉 ALL ENDPOINTS WORK! Use this URL: $baseUrl');
      print('  📱 Your Android emulator should work with this URL\n');
    } else {
      print('  ❌ Some endpoints failed for: $baseUrl\n');
    }
  }

  print('2. Backend Server Configuration Check...\n');

  // Check if server is binding correctly
  print('For your backend server to work with Android emulator:');
  print('');
  print('🔧 Server Configuration Required:');
  print('   • Server must bind to 0.0.0.0:8000 (not localhost:8000)');
  print('   • Firewall must allow connections on port 8000');
  print('   • No /api prefix needed (your Flutter app is correct)');
  print('');
  print('🛠️  Common Server Start Configurations:');
  print('   PHP: php -S 0.0.0.0:8000');
  print('   Laravel: php artisan serve --host=0.0.0.0 --port=8000');
  print('   Node.js: app.listen(8000, "0.0.0.0")');
  print('   Django: python manage.py runserver 0.0.0.0:8000');
  print('');

  print('3. Network Verification Commands...\n');
  print('Run these commands to verify your server setup:');
  print('');
  print('   # Check what\'s listening on port 8000:');
  print('   lsof -i :8000');
  print('');
  print('   # Test from command line:');
  print('   curl http://localhost:8000/ping');
  print('   curl http://192.168.8.132:8000/ping');
  print('   curl http://10.0.2.2:8000/ping  # This might fail on host machine');
  print('');

  print('=== Test Complete ===');

  print('\n📱 NEXT STEPS:');
  print('1. Fix your backend server to bind to 0.0.0.0:8000');
  print('2. Test the working URL from the results above');
  print('3. Run your Flutter app on Android emulator');
  print('4. Product adding/editing should now work!');
}
