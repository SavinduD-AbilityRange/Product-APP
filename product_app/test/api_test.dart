import 'dart:io';
import '../lib/services/api_service.dart';
import '../lib/config/api_config.dart';

void main() async {
  print('=== API Service Test ===');

  // Test 1: Check if server is reachable
  print('\n1. Testing server connection...');
  bool serverReachable = await ApiService.pingServer();
  print('Server reachable: $serverReachable');

  if (!serverReachable) {
    print('❌ Server is not reachable. Please check:');
    print('- Is your backend server running?');
    print('- Are you using the correct IP address?');
    print('- Check the fallback URLs in api_config.dart');
    return;
  }

  // Test 2: Check environment
  print('\n2. Checking server environment...');
  var envInfo = await ApiService.checkEnvironment();
  print('Environment info: $envInfo');

  // Test 3: Fetch existing products
  print('\n3. Fetching existing products...');
  try {
    var products = await ApiService.fetchProducts();
    print('✅ Successfully fetched ${products.length} products');
    for (var product in products) {
      print('  - ${product.name} (${product.category}) - \$${product.price}');
    }
  } catch (e) {
    print('❌ Failed to fetch products: $e');
  }

  // Test 4: Add a test product
  print('\n4. Adding a test product...');
  try {
    bool success = await ApiService.addProduct(
      'Test Product ${DateTime.now().millisecondsSinceEpoch}', // Unique name
      'Test Category',
      29.99,
      null, // No image file
    );

    if (success) {
      print('✅ Product added successfully!');

      // Fetch products again to see if it was added
      print('\n5. Verifying product was added...');
      var updatedProducts = await ApiService.fetchProducts();
      print('Updated product count: ${updatedProducts.length}');
    } else {
      print('❌ Failed to add product (returned false)');
    }
  } catch (e) {
    print('❌ Exception while adding product: $e');
    print('Exception type: ${e.runtimeType}');

    // Check if it's a specific type of error
    if (e.toString().contains('SocketException')) {
      print('🔍 Network issue - check server connectivity');
    } else if (e.toString().contains('TimeoutException')) {
      print('🔍 Request timed out - server might be slow');
    } else if (e.toString().contains('FormatException')) {
      print('🔍 Response format issue - check server response');
    } else {
      print('🔍 Unknown error - check server logs');
    }
  }

  print('\n=== Test Complete ===');
  print('Current platform: ${Platform.operatingSystem}');
  print('Fallback URLs being used: ${ApiConfig.fallbackUrls}');
}
