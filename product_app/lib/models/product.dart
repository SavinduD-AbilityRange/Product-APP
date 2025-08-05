class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String date;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.date,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? 'Unnamed',
      category: json['category'] ?? 'Uncategorized',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      image: json['image'] ?? '', // fallback to empty string
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'date': date,
    };
  }
}
