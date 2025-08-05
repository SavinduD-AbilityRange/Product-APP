import '../lib/services/api_service.dart';

void main() async {
  print('=== Simple Product Test ===');

  // Test adding a product
  print('\n1. Adding a product...');
  try {
    bool success = await ApiService.addProduct(
      'Sample Product',
      'Electronics',
      99.99,
      null,
    );
    print('Add product result: $success');
  } catch (e) {
    print('Add product error: $e');
  }

  // Test fetching products
  print('\n2. Fetching products...');
  try {
    var products = await ApiService.fetchProducts();
    print('Fetch products result: ${products.length} products found');

    for (var product in products) {
      print(
        '  - ID: ${product.id}, Name: ${product.name}, Price: \$${product.price}',
      );
    }
  } catch (e) {
    print('Fetch products error: $e');
  }

  print('\n=== Test Complete ===');
}
