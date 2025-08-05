import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // 🔧 YOUR ACTUAL BACKEND CONFIGURATION
  // Backend is running through Apache/XAMPP at localhost/product_app/api
  static const String baseUrl = 'http://localhost/product_app/api';

  // Get platform-specific base URLs
  static List<String> get fallbackUrls {
    if (kIsWeb) {
      // Web platform - use localhost
      return [
        'http://localhost/product_app/api/index.php',
        'http://127.0.0.1/product_app/api/index.php',
      ];
    } else if (Platform.isAndroid) {
      // Android platform - use 10.0.2.2 for emulator and local IP for physical devices
      return [
        'http://10.0.2.2/product_app/api/index.php', // Android emulator
        'http://10.0.2.2:80/product_app/api/index.php', // Android emulator with port
        'http://192.168.8.121/product_app/api/index.php', // Your local IP for physical devices
        'http://192.168.8.121:80/product_app/api/index.php', // Your local IP with port
        'http://localhost/product_app/api/index.php', // Fallback (won't work in emulator)
        'http://127.0.0.1/product_app/api/index.php', // Fallback
      ];
    } else if (Platform.isIOS) {
      // iOS platform - use localhost for simulator, local IP for physical devices
      return [
        'http://localhost/product_app/api/index.php', // iOS Simulator
        'http://127.0.0.1/product_app/api/index.php', // iOS Simulator fallback
        'http://192.168.8.121/product_app/api/index.php', // Physical iOS device
      ];
    } else {
      // Desktop platforms (Windows, macOS, Linux)
      return [
        'http://localhost/product_app/api/index.php',
        'http://127.0.0.1/product_app/api/index.php',
        'http://192.168.8.121/product_app/api/index.php', // Local network access
      ];
    }
  }

  // API Endpoints
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static String get productsUrl => '$baseUrl/products';

  // Request timeout
  static const Duration timeout = Duration(seconds: 30);

  // Headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Enable/disable debug logging
  static const bool enableDebugLogs = true;

  static String get platformInfo {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  static void logDebug(String message) {
    if (enableDebugLogs) {
      print('🔍 API Debug [$platformInfo]: $message');
    }
  }
}
