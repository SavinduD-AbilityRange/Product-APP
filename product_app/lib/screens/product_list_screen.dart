import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = ApiService.fetchProducts();
  }

  void _refreshProducts() {
    setState(() {
      _products = ApiService.fetchProducts();
    });
  }

  void _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("🗑️ Confirm Deletion"),
            content: const Text(
              "Are you sure you want to delete this product?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      bool success = await ApiService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Product deleted' : '❌ Failed to delete product',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) _refreshProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('🛍️ Product List'),
        elevation: 2,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: _refreshProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("😕 No products available."));
          }

          final productList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditProductScreen(product: product),
                      ),
                    );
                    if (result == true) _refreshProducts();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              product.image.isNotEmpty
                                  ? Image.network(
                                    "http://10.0.2.2:8000/${product.image}",
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                  )
                                  : Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Rs. ${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteProduct(product.id!),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
          if (result == true) _refreshProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
