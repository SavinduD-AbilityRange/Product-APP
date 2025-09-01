import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api_config.dart';

class HttpApiService {
  
  Future<bool> testConnection() async {
    try {
      ApiConfig.logDebug('Testing connection to backend...');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final response = await http
              .get(Uri.parse('$baseUrl/ping'), headers: ApiConfig.headers)
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            ApiConfig.logDebug('✅ Connection successful to: $baseUrl');
            return true;
          }
        } catch (e) {
          ApiConfig.logDebug(' Connection failed to $baseUrl: $e');
          continue;
        }
      }

      ApiConfig.logDebug('All connection attempts failed');
      return false;
    } catch (e) {
      ApiConfig.logDebug(' Connection test error: $e');
      return false;
    }
  }


  Future<List<Product>> getProducts() async {
    try {
      ApiConfig.logDebug('Fetching products from backend...');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final response = await http
              .get(Uri.parse('$baseUrl/products'), headers: ApiConfig.headers)
              .timeout(ApiConfig.timeout);

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);

            
            List data;
            if (responseData is List) {
              data = responseData;
            } else if (responseData is Map &&
                responseData.containsKey('products')) {
              data = responseData['products'];
            } else if (responseData is Map &&
                responseData.containsKey('data')) {
              data = responseData['data'];
            } else {
              throw Exception('Unexpected response format');
            }

            ApiConfig.logDebug('✅ Fetched ${data.length} products');
            return data.map((item) => Product.fromJson(item)).toList();
          }
        } catch (e) {
          ApiConfig.logDebug('Error fetching from $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to fetch products from all endpoints');
    } catch (e) {
      ApiConfig.logDebug('Get products error: $e');
      throw Exception('Failed to load products: $e');
    }
  }


  Future<Product> createProduct({
    required String name,
    required String category,
    required double price,
    String? description,
    int stockQuantity = 0,
    dynamic image, 
  }) async {
    try {
      ApiConfig.logDebug('Creating product: $name');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl/products'),
          );

        
          request.fields['name'] = name;
          request.fields['category'] = category;
          request.fields['price'] = price.toString();
          request.fields['description'] = description ?? '';
          request.fields['stock_quantity'] = stockQuantity.toString();

          if (image != null) {
            if (kIsWeb && image is Uint8List) {
              
              final base64Image = base64Encode(image);
              request.fields['image_base64'] = base64Image;
            } else if (!kIsWeb && image.path != null) {
              
              request.files.add(
                await http.MultipartFile.fromPath('image', image.path),
              );
            }
          }

          final response = await request.send().timeout(ApiConfig.timeout);
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = json.decode(responseBody);

            Map<String, dynamic> productData;
            if (responseData is Map && responseData.containsKey('product')) {
              productData = responseData['product'];
            } else if (responseData is Map &&
                responseData.containsKey('data')) {
              productData = responseData['data'];
            } else {
              productData = responseData;
            }

            ApiConfig.logDebug('✅ Product created successfully');
            return Product.fromJson(productData);
          }
        } catch (e) {
          ApiConfig.logDebug('Error creating product at $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to create product at all endpoints');
    } catch (e) {
      ApiConfig.logDebug('Create product error: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Product> updateProduct({
    required String id,
    String? name,
    String? category,
    double? price,
    String? description,
    int? stockQuantity,
    dynamic image,
  }) async {
    try {
      ApiConfig.logDebug('Updating product: $id');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final request = http.MultipartRequest(
            'PUT',
            Uri.parse('$baseUrl/products/$id'),
          );
          if (name != null) request.fields['name'] = name;
          if (category != null) request.fields['category'] = category;
          if (price != null) request.fields['price'] = price.toString();
          if (description != null) request.fields['description'] = description;
          if (stockQuantity != null)
            request.fields['stock_quantity'] = stockQuantity.toString();

          if (image != null) {
            if (kIsWeb && image is Uint8List) {
              final base64Image = base64Encode(image);
              request.fields['image_base64'] = base64Image;
            } else if (!kIsWeb && image.path != null) {
              request.files.add(
                await http.MultipartFile.fromPath('image', image.path),
              );
            }
          }

          final response = await request.send().timeout(ApiConfig.timeout);
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            final responseData = json.decode(responseBody);

            Map<String, dynamic> productData;
            if (responseData is Map && responseData.containsKey('product')) {
              productData = responseData['product'];
            } else if (responseData is Map &&
                responseData.containsKey('data')) {
              productData = responseData['data'];
            } else {
              productData = responseData;
            }

            ApiConfig.logDebug('✅ Product updated successfully');
            return Product.fromJson(productData);
          }
        } catch (e) {
          ApiConfig.logDebug('Error updating product at $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to update product at all endpoints');
    } catch (e) {
      ApiConfig.logDebug('Update product error: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      ApiConfig.logDebug('Deleting product: $id');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final response = await http
              .delete(
                Uri.parse('$baseUrl/products/$id'),
                headers: ApiConfig.headers,
              )
              .timeout(ApiConfig.timeout);

          if (response.statusCode == 200 || response.statusCode == 204) {
            ApiConfig.logDebug('✅ Product deleted successfully');
            return true;
          }
        } catch (e) {
          ApiConfig.logDebug('Error deleting product at $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to delete product at all endpoints');
    } catch (e) {
      ApiConfig.logDebug('Delete product error: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      ApiConfig.logDebug('Fetching categories from backend...');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final response = await http
              .get(Uri.parse('$baseUrl/categories'), headers: ApiConfig.headers)
              .timeout(ApiConfig.timeout);

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);

            List data;
            if (responseData is List) {
              data = responseData;
            } else if (responseData is Map &&
                responseData.containsKey('categories')) {
              data = responseData['categories'];
            } else if (responseData is Map &&
                responseData.containsKey('data')) {
              data = responseData['data'];
            } else {
              throw Exception('Unexpected response format');
            }

            ApiConfig.logDebug('Fetched ${data.length} categories');
            return data.map((item) => item.toString()).toList();
          }
        } catch (e) {
          ApiConfig.logDebug(" Error fetching categories from $baseUrl: $e");
          continue;
        }
      }

      ApiConfig.logDebug('Using default categories (backend unavailable)');
      return ['Electronics', 'Clothing', 'Food', 'Books', 'Home & Garden'];
    } catch (e) {
      ApiConfig.logDebug('Get categories error: $e');
      return ['Electronics', 'Clothing', 'Food', 'Books', 'Home & Garden'];
    }
  }
}
