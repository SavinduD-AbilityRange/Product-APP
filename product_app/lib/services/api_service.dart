import '../models/product.dart';

class ApiService {
  static final List<Product> _products = [];
  static final Set<String> _customCategories = {
    'Electronics',
    'Clothing',
    'Food',
    'Books',
    'Home & Garden',
  };

  // Get all products
  Future<List<Product>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_products);
  }

  // Get single product
  Future<Product> getProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final product = _products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
    );
    return product;
  }

  // Create new product
  Future<Product> createProduct({
    required String name,
    required String category,
    required double price,
    String? description,
    int stockQuantity = 0,
    dynamic image, // File or Uint8List
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      price: price,
      description: description,
      stockQuantity: stockQuantity,
      image: image,
      date: DateTime.now().toString().split(' ')[0],
    );

    _products.add(newProduct);
    return newProduct;
  }

  // Update product
  Future<Product> updateProduct({
    required String id,
    String? name,
    String? category,
    double? price,
    String? description,
    int? stockQuantity,
    dynamic image,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Product not found');
    }

    final oldProduct = _products[index];
    final updatedProduct = oldProduct.copyWith(
      name: name,
      category: category,
      price: price,
      description: description,
      stockQuantity: stockQuantity,
      image: image,
      updatedAt: DateTime.now(),
    );

    _products[index] = updatedProduct;
    return updatedProduct;
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products.removeAt(index);
      return true;
    }
    return false;
  }

  // Get categories
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Combine default categories with custom ones from products
    final productCategories = _products.map((p) => p.category).toSet();
    final allCategories = {..._customCategories, ...productCategories};

    return allCategories.toList()..sort();
  }

  // Add a new category
  Future<void> addCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _customCategories.add(category);
  }
}
