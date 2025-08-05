import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCardList extends StatelessWidget {
  final List<Product> products;
  final Function({int? index}) onEdit;
  final Function(int index) onDelete;

  const ProductCardList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: _buildProductImage(product),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ID: ${product.id}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Category: ${product.category}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Price: \$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Stock: ${product.stockQuantity}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Date: ${product.date}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                  onPressed: () => onEdit(index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => onDelete(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    // Show server image if available
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          product.imageUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image, size: 60, color: Colors.grey);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      );
    }

    // Show local image if available
    if (product.image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child:
            kIsWeb
                ? Image.memory(
                  product.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : Image.file(
                  product.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
      );
    }

    // Show placeholder
    return const Icon(Icons.image, size: 60, color: Colors.grey);
  }
}
