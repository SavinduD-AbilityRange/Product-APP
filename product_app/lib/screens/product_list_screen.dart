import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      products = ApiService.fetchProducts();
    });
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';

    // If it's already a complete URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      print('Image URL is already complete: $imageUrl');
      return imageUrl;
    }

    // If it's a relative path, construct the full URL
    // Use the first fallback URL from ApiConfig
    final fallbackUrls = ApiConfig.fallbackUrls;
    final baseUrl =
        fallbackUrls.isNotEmpty ? fallbackUrls[0] : 'http://10.0.2.2:8000';

    print('Using base URL: $baseUrl');
    print('Original image URL: "$imageUrl"');

    String fullUrl;
    // Check if the imageUrl already contains the storage path
    if (imageUrl.startsWith('storage/products/')) {
      fullUrl = '$baseUrl/$imageUrl';
      print('Case 1: storage/products/ prefix found');
    } else if (imageUrl.startsWith('/storage/products/')) {
      fullUrl = '$baseUrl$imageUrl';
      print('Case 2: /storage/products/ prefix found');
    } else {
      // If it's just a filename, add the full storage path
      if (imageUrl.startsWith('/')) {
        fullUrl = '$baseUrl/storage/products$imageUrl';
        print('Case 3: starts with / - adding storage path');
      } else {
        fullUrl = '$baseUrl/storage/products/$imageUrl';
        print('Case 4: filename only - adding full storage path');
      }
    }

    print('Final constructed URL: $fullUrl');
    return fullUrl;
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text('Are you sure you want to delete "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ApiService.deleteProduct(product.id);
                    _loadProducts();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete product'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'My Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Something went wrong'),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No Products Yet'),
                  const SizedBox(height: 8),
                  const Text('Start by adding your first product!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditProductScreen(),
                        ),
                      );
                      _loadProducts();
                    },
                    child: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          final productList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getFullImageUrl(product.imageUrl),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AddEditProductScreen(product: product),
                            ),
                          );
                          _loadProducts();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(product),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
          _loadProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
