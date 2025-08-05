import '../lib/services/api_service.dart';

void main() async {
  print('=== EMULATOR CONNECTIVITY TEST ===');
  print('This test uses the same URLs your Android emulator will try');

  try {
    print('\n🧪 Testing server ping...');
    bool pingResult = await ApiService.pingServer();
    print('Ping result: $pingResult');

    if (pingResult) {
      print('✅ Server is reachable!');

      print('\n🧪 Testing product fetching...');
      var products = await ApiService.fetchProducts();
      print('✅ Successfully fetched ${products.length} products');

      if (products.isNotEmpty) {
        print('\n🧪 Testing product operations...');

        // Test adding a product
        bool addResult = await ApiService.addProduct(
          'Emulator Test Product ${DateTime.now().millisecondsSinceEpoch}',
          'Test Category',
          99.99,
          null,
        );

        if (addResult) {
          print('✅ Successfully added product');

          // Verify by fetching again
          var updatedProducts = await ApiService.fetchProducts();
          print('✅ Products after add: ${updatedProducts.length}');

          print('\n🎉 ALL TESTS PASSED!');
          print('🎯 Your Android emulator should work perfectly!');
        } else {
          print('❌ Failed to add product');
        }
      }
    } else {
      print('❌ Server not reachable - check backend configuration');
    }
  } catch (e) {
    print('❌ Test failed: $e');

    if (e.toString().contains('SocketException')) {
      print('\n🔧 SOLUTION: Your backend server needs to bind to 0.0.0.0:8000');
      print('   Try: php artisan serve --host=0.0.0.0 --port=8000');
    } else if (e.toString().contains('TimeoutException')) {
      print('\n🔧 SOLUTION: Server is too slow or not running');
      print('   Check if your backend server is running on port 8000');
    }
  }

  print('\n=== Test Complete ===');
  print('If tests passed, your Android emulator app should work!');
}
