import 'dart:io';

class ApiConfig {
  
  static const String androidEmulatorUrl =
      'http://10.0.2.2:8000'; 
  
  static const String defaultUrl = 'http://10.0.2.2:8000'; 

  static bool get _isWeb {
    try {
      return identical(0, 0.0) == false; 
    } catch (e) {
      return false;
    }
  }

  static String get baseUrl {
    if (_isWeb) {
      print('Platform detected: Web');
      print('Using web URL: http://localhost:8000');
      return 'http://localhost:8000';
    }

    try {
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
    } catch (e) {
      
      print('Platform detection failed, using localhost: $e');
      return 'http://localhost:8000';
    }
  }

  
  static List<String> get fallbackUrls {
    if (_isWeb) {
      return [
        'http://10.0.2.2:8000',
        'http://localhost:8000',
        'http://127.0.0.1:8000',
      ];
    }

    try {
      if (Platform.isAndroid) {
        return [
          'http://10.0.2.2:8000', 
          'http://10.0.2.2:8000',
          'http://localhost:8000',
        ];
      } else {
        return [
          'http://10.0.2.2:8000', 
          'http://localhost:8000',
          'http://127.0.0.1:8000',
        ];
      }
    } catch (e) {
      
      return [
        'http://192.168.8.105:8000', 
        'http://localhost:8000',
        'http://127.0.0.1:8000',
      ];
    }
  } 

  static String get productsUrl => '$baseUrl/products';
  static String get pingUrl => '$baseUrl/ping';
  static String get checkEnvUrl => '$baseUrl/check-env';
}
