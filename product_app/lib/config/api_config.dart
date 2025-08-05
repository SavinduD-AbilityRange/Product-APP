import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // For Android Emulator - use 10.0.2.2 (standard Android emulator host)
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000';
  // For iOS Simulator and other platforms
  static const String defaultUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    if (kIsWeb) {
      print('Platform detected: Web');
      print('Using web URL: http://localhost:8000');
      return 'http://localhost:8000';
    }

    print('Platform detected: ${Platform.operatingSystem}');
    print('Is Android: ${Platform.isAndroid}');

    if (Platform.isAndroid) {
      print('Using Android emulator URL: $androidEmulatorUrl');
      return androidEmulatorUrl;
    } else if (Platform.isIOS) {
      print('Using iOS simulator URL: $defaultUrl');
      return defaultUrl;
    } else {
      print('Using fallback URL: $defaultUrl');
      return defaultUrl;
    }
  }

  // Fallback URLs to try if primary fails
  static List<String> get fallbackUrls {
    if (kIsWeb) {
      return [
        'http://localhost:8000', // Primary for web
        'http://127.0.0.1:8000',
        'http://192.168.8.132:8000', // Your computer's actual IP
      ];
    } else if (Platform.isAndroid) {
      return [
        'http://192.168.8.132:8000', // Your computer's actual IP (priority for Android)
        'http://10.0.2.2:8000', // Standard Android emulator host
        'http://localhost:8000', // Sometimes works on newer emulators
      ];
    } else {
      return [
        'http://localhost:8000', // Primary for iOS/Desktop
        'http://127.0.0.1:8000',
        'http://192.168.8.132:8000', // Your computer's actual IP
      ];
    }
  }

  // Product endpoints
  static String get productsUrl => '$baseUrl/products';
  static String get pingUrl => '$baseUrl/ping';
  static String get checkEnvUrl => '$baseUrl/check-env';
}
