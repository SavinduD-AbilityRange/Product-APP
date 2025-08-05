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
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] ?? '',
      date: json['updated_at'] ?? json['created_at'],
    );
  }
}
