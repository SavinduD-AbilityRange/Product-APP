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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Card(
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(product),
                ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Price: \$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Stock: ${product.stockQuantity}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Date: ${product.date}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () => onEdit(index: index),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => onDelete(index),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    // Show server image if available
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image, size: 30, color: Colors.grey);
        },
      );
    }

    // Show local image if available
    if (product.image != null) {
      return Image.memory(product.image!, fit: BoxFit.cover);
    }

    // Show placeholder
    return const Icon(Icons.image, size: 30, color: Colors.grey);
  }
}
