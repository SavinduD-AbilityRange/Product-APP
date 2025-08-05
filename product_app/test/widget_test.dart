// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:product_app/models/product.dart';

void main() {
  testWidgets('Product model test', (WidgetTester tester) async {
    // Test Product model creation
    final product = Product(
      id: '1',
      name: 'Test Product',
      category: 'Electronics',
      price: 99.99,
      date: '2025-08-05',
    );

    expect(product.id, '1');
    expect(product.name, 'Test Product');
    expect(product.category, 'Electronics');
    expect(product.price, 99.99);
    expect(product.stockQuantity, 0); // default value
  });

  testWidgets('Product copyWith test', (WidgetTester tester) async {
    final product1 = Product(
      id: '1',
      name: 'Original',
      category: 'Electronics',
      price: 50.0,
      date: '2025-08-05',
    );

    final product2 = product1.copyWith(name: 'Updated', price: 75.0);

    expect(product2.id, '1'); // unchanged
    expect(product2.name, 'Updated'); // changed
    expect(product2.category, 'Electronics'); // unchanged
    expect(product2.price, 75.0); // changed
  });
}
