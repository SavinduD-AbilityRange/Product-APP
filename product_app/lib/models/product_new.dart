class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final int stockQuantity;
  final bool status;
  final dynamic image; // Can be File (mobile) or Uint8List (web)
  final String? imageUrl; // URL from server
  final String date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.stockQuantity = 0,
    this.status = true,
    this.image,
    this.imageUrl,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert from JSON (from your backend API)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['description'],
      stockQuantity: int.tryParse(json['stock_quantity'].toString()) ?? 0,
      status: json['status'] == true || json['status'] == 1,
      imageUrl: json['image'], // Your backend uses 'image' field
      date:
          json['created_at']?.toString().split('T')[0] ??
          DateTime.now().toString().split(' ')[0],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  // Convert to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'stock_quantity': stockQuantity,
      'status': status,
    };
  }

  // Copy with new values
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    int? stockQuantity,
    bool? status,
    dynamic image,
    String? imageUrl,
    String? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
