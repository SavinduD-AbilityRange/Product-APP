class ApiConfig {
  // 🔧 YOUR ACTUAL BACKEND CONFIGURATION
  // Backend is running through Apache/XAMPP at localhost/product_app/api
  static const String baseUrl = 'http://localhost/product_app/api';

  // Fallback URLs for connection attempts
  static const List<String> fallbackUrls = [
    'http://localhost/product_app/api/index.php',
    'http://127.0.0.1/product_app/api/index.php',
  ];

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

  static void logDebug(String message) {
    if (enableDebugLogs) {
      print('🔍 API Debug: $message');
    }
  }
}
