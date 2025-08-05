import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTable extends StatelessWidget {
  final List<Product> products;
  final Function({int? index}) onEdit;
  final Function(int index) onDelete;

  const ProductTable({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 48,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columns: const [
                  DataColumn(label: Text("Image")),
                  DataColumn(label: Text("Product ID")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Stock")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Actions")),
                ],
                rows:
                    products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(_buildProductImage(product)),
                          DataCell(
                            Text(
                              product.id,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DataCell(Text(product.name)),
                          DataCell(Text(product.category)),
                          DataCell(
                            Text('\$${product.price.toStringAsFixed(2)}'),
                          ),
                          DataCell(Text(product.stockQuantity.toString())),
                          DataCell(Text(product.date)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  onPressed: () => onEdit(index: index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => onDelete(index),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product) {
    // Show server image if available
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          product.imageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image, size: 24);
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
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
                : Image.file(
                  product.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
      );
    }

    // Show placeholder
    return const Icon(Icons.image, size: 24);
  }
}
