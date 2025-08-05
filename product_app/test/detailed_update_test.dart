import '../lib/services/api_service.dart';

void main() async {
  print('=== Detailed Update Analysis ===');

  // Test with server response analysis
  print('\n1. Testing direct server communication...');

  try {
    // First add a product to test with
    print('Adding a test product...');
    bool addSuccess = await ApiService.addProduct(
      'Test Product ${DateTime.now().millisecondsSinceEpoch}',
      'Test Category',
      50.00,
      null,
    );
    print('Add result: $addSuccess');

    if (!addSuccess) {
      print('❌ Cannot proceed without adding a product first');
      return;
    }

    // Get the products to find our new one
    var products = await ApiService.fetchProducts();
    if (products.isEmpty) {
      print('❌ No products found after adding');
      return;
    }

    var testProduct = products.last; // Get the most recent one
    print(
      'Test product: ID=${testProduct.id}, Name="${testProduct.name}", Price=\$${testProduct.price}',
    );

    // Now test update with detailed analysis
    print('\n2. Testing update with detailed server response analysis...');

    bool updateResult = await ApiService.updateProduct(
      testProduct.id,
      'UPDATED: ${testProduct.name}',
      'UPDATED: ${testProduct.category}',
      testProduct.price + 100.0,
      null,
    );

    print('Update API result: $updateResult');

    // Check what actually happened on the server
    print('\n3. Checking server state after update...');
    var updatedProducts = await ApiService.fetchProducts();
    var updatedProduct = updatedProducts.firstWhere(
      (p) => p.id == testProduct.id,
      orElse: () => testProduct,
    );

    print('Product after update attempt:');
    print(
      '  Original: ID=${testProduct.id}, Name="${testProduct.name}", Price=\$${testProduct.price}',
    );
    print(
      '  Current:  ID=${updatedProduct.id}, Name="${updatedProduct.name}", Price=\$${updatedProduct.price}',
    );

    bool actuallyUpdated =
        updatedProduct.name != testProduct.name ||
        updatedProduct.price != testProduct.price;

    if (updateResult && actuallyUpdated) {
      print('✅ SUCCESS: Update worked correctly');
    } else if (updateResult && !actuallyUpdated) {
      print(
        '⚠️  WARNING: API returned success but product was not actually updated on server',
      );
      print(
        '   This indicates a backend issue - the server is saying "success" but not saving changes',
      );
    } else {
      print('❌ FAILED: Update API returned false');
    }
  } catch (e) {
    print('❌ Test failed with exception: $e');
    print('Full error details: ${e.toString()}');
  }

  print('\n=== Analysis Complete ===');
  print('If you see "WARNING" above, the issue is in your backend server,');
  print(
    'not in the Flutter code. The server needs to actually save the updates.',
  );
}
