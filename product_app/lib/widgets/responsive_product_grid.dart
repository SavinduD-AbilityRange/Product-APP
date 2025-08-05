import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_card.dart';

class ResponsiveProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onEdit;
  final Function(Product) onDelete;

  const ResponsiveProductGrid({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 600 ? 3 : 2;
        final aspectRatio = screenWidth > 600 ? 0.9 : 0.8;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenWidth > 600 ? 280 : 250,
                minHeight: 200,
              ),
              child: ProductCard(
                product: product,
                onEdit: () => onEdit(product),
                onDelete: () => onDelete(product),
              ),
            );
          },
        );
      },
    );
  }
}
