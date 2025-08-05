import '../lib/services/api_service.dart';

void main() async {
  print('=== Update Product Test ===');

  // First, let's fetch existing products to get an ID to update
  print('\n1. Fetching existing products to get an ID...');
  try {
    var products = await ApiService.fetchProducts();
    print('Found ${products.length} products');

    if (products.isEmpty) {
      print('No products found. Adding a test product first...');

      // Add a product first
      bool addSuccess = await ApiService.addProduct(
        'Test Product for Update',
        'Test Category',
        25.99,
        null,
      );

      if (addSuccess) {
        print('✅ Test product added successfully');
        // Fetch again to get the new product
        products = await ApiService.fetchProducts();
      } else {
        print('❌ Failed to add test product');
        return;
      }
    }

    if (products.isNotEmpty) {
      var productToUpdate = products.first;
      print(
        'Product to update: ID=${productToUpdate.id}, Name=${productToUpdate.name}',
      );

      // Test updating the product
      print('\n2. Testing product update...');
      try {
        bool updateSuccess = await ApiService.updateProduct(
          productToUpdate.id,
          'Updated Product Name',
          'Updated Category',
          199.99,
          null,
        );

        if (updateSuccess) {
          print('✅ Product updated successfully!');

          // Verify the update by fetching products again
          print('\n3. Verifying the update...');
          var updatedProducts = await ApiService.fetchProducts();
          var updatedProduct = updatedProducts.firstWhere(
            (p) => p.id == productToUpdate.id,
            orElse: () => productToUpdate,
          );
          print(
            'Updated product: Name=${updatedProduct.name}, Price=\$${updatedProduct.price}',
          );
        } else {
          print('❌ Product update returned false');
        }
      } catch (e) {
        print('❌ Product update failed with exception: $e');
        print('Exception type: ${e.runtimeType}');

        // Check if it's a specific type of error
        if (e.toString().contains('SocketException')) {
          print('🔍 Network issue - check server connectivity');
        } else if (e.toString().contains('TimeoutException')) {
          print('🔍 Request timed out - server might be slow');
        } else if (e.toString().contains('FormatException')) {
          print('🔍 Response format issue - check server response');
        } else if (e.toString().contains('Server returned status')) {
          print('🔍 Server returned an error status - check server logs');
        } else {
          print('🔍 Unknown error - check server implementation');
        }
      }
    }
  } catch (e) {
    print('❌ Failed to fetch products: $e');
  }

  print('\n=== Update Test Complete ===');
}
