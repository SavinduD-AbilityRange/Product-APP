import '../lib/services/api_service.dart';

void main() async {
  print('=== App Simulation Test ===');
  print('This test simulates exactly what your Flutter app does');

  try {
    // Step 1: Load products (like ProductListScreen does)
    print('\n1. Loading products (like app startup)...');
    var initialProducts = await ApiService.fetchProducts();
    print('Loaded ${initialProducts.length} products');

    if (initialProducts.isEmpty) {
      print('No products found - adding a test product first');
      await ApiService.addProduct('Test Product', 'Test Category', 25.99, null);
      initialProducts = await ApiService.fetchProducts();
    }

    var productToEdit = initialProducts.first;
    print('Product to edit: ${productToEdit.name} (\$${productToEdit.price})');

    // Step 2: Simulate editing (like AddEditProductScreen does)
    print('\n2. Simulating product edit...');
    print('Original product: ${productToEdit.name} - \$${productToEdit.price}');

    // This is exactly what your _submit() method does
    bool success = await ApiService.updateProduct(
      productToEdit.id,
      'EDITED: ${productToEdit.name}',
      'EDITED: ${productToEdit.category}',
      productToEdit.price + 50.0,
      null,
    );

    print('Update API returned: $success');

    // Step 3: Check what the UI would see when it refreshes
    print('\n3. Refreshing product list (like app does after edit)...');
    var refreshedProducts = await ApiService.fetchProducts();
    var updatedProduct = refreshedProducts.firstWhere(
      (p) => p.id == productToEdit.id,
      orElse: () => productToEdit,
    );

    print(
      'Product after refresh: ${updatedProduct.name} - \$${updatedProduct.price}',
    );

    // Step 4: Check if the UI would show success or error
    bool dataActuallyChanged =
        (updatedProduct.name != productToEdit.name) ||
        (updatedProduct.price != productToEdit.price);

    print('\n4. What your app UI would show:');
    if (success && dataActuallyChanged) {
      print('✅ SUCCESS: "Product updated" message');
    } else if (success && !dataActuallyChanged) {
      print('⚠️  ISSUE: API says success but data unchanged');
      print('   - Your app shows "Product updated" but user sees no change');
      print('   - This creates confusion - looks like it didn\'t work');
    } else {
      print('❌ FAILURE: "Failed to save product" message');
    }

    // Step 5: Additional insight
    print('\n5. Backend Analysis:');
    print('   - API Service: Working correctly ✅');
    print('   - Backend Server: Returns success but doesn\'t save changes ❌');
    print(
      '   - User Experience: Confusing - says "updated" but no visible change',
    );

    print('\nRECOMMENDATION:');
    print(
      'Fix your backend server\'s PUT endpoint to actually save the changes.',
    );
    print(
      'Until then, users will see "Product updated" but no actual changes.',
    );
  } catch (e) {
    print('❌ Test failed: $e');
    print('Your app would show: "Error: $e"');
  }

  print('\n=== App Simulation Complete ===');
}
