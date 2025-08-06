class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String date;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.date,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      category: json['category'] ?? 'Uncategorized',
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image'] ?? '',
      date:
          json['updated_at'] ??
          json['created_at'] ??
          json['date'] ??
          DateTime.now().toIso8601String(),
    );
  }
}
