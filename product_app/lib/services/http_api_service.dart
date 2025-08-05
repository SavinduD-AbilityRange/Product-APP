import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api_config.dart';

class HttpApiService {
  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      ApiConfig.logDebug(
        'Testing connection to your backend at localhost:8001...',
      );

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          // Test the /products endpoint since that's what your backend serves
          final response = await http
              .get(Uri.parse('$baseUrl/products'), headers: ApiConfig.headers)
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            ApiConfig.logDebug('✅ Connection successful to: $baseUrl');
            final data = json.decode(response.body);
            ApiConfig.logDebug('Backend response: ${data.toString()}');
            return true;
          }
        } catch (e) {
          ApiConfig.logDebug('❌ Connection failed to $baseUrl: $e');
          continue;
        }
      }

      ApiConfig.logDebug('❌ All connection attempts failed');
      return false;
    } catch (e) {
      ApiConfig.logDebug('❌ Connection test error: $e');
      return false;
    }
  }

  // Get all products
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

            // Handle different response formats
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
          ApiConfig.logDebug('❌ Error fetching from $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to fetch products from all endpoints');
    } catch (e) {
      ApiConfig.logDebug('❌ Get products error: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  // Create new product
  Future<Product> createProduct({
    required String name,
    required String category,
    required double price,
    String? description,
    int stockQuantity = 0,
    dynamic image, // File, Uint8List, or null
  }) async {
    try {
      ApiConfig.logDebug('Creating product: $name');

      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl/products'),
          );

          ApiConfig.logDebug('Sending POST request to: $baseUrl/products');

          // Add text fields
          request.fields['name'] = name;
          request.fields['category'] = category;
          request.fields['price'] = price.toString();
          request.fields['description'] = description ?? '';
          request.fields['stock_quantity'] = stockQuantity.toString();

          ApiConfig.logDebug('Request fields: ${request.fields}');

          // Handle image upload
          if (image != null) {
            if (kIsWeb && image is Uint8List) {
              // Web: Instead of storing huge base64, store just a filename
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final filename = 'web_upload_$timestamp.jpg';
              request.fields['image'] = filename;
              ApiConfig.logDebug('Added image filename: $filename');
              // TODO: In a real app, you would upload the image to a file server
              // For now, we just store the filename reference
            } else if (!kIsWeb && image.path != null) {
              // Mobile: Extract filename from path
              final filename = image.path.split('/').last;
              request.fields['image'] = filename;
              ApiConfig.logDebug('Added image filename: $filename');
              // For file upload, you would add the actual file:
              // request.files.add(await http.MultipartFile.fromPath('image_file', image.path));
            }
          }

          final response = await request.send().timeout(ApiConfig.timeout);
          final responseBody = await response.stream.bytesToString();

          ApiConfig.logDebug('Response status: ${response.statusCode}');
          ApiConfig.logDebug('Response body: $responseBody');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = json.decode(responseBody);

            // Handle different response formats
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
          } else {
            ApiConfig.logDebug(
              '❌ Create failed with status ${response.statusCode}: $responseBody',
            );
          }
        } catch (e) {
          ApiConfig.logDebug('❌ Error creating product at $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to create product at all endpoints');
    } catch (e) {
      ApiConfig.logDebug('❌ Create product error: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  // Update product
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

          ApiConfig.logDebug('Sending PUT request to: $baseUrl/products/$id');

          // Add text fields (only if provided)
          if (name != null) request.fields['name'] = name;
          if (category != null) request.fields['category'] = category;
          if (price != null) request.fields['price'] = price.toString();
          if (description != null) request.fields['description'] = description;
          if (stockQuantity != null)
            request.fields['stock_quantity'] = stockQuantity.toString();

          ApiConfig.logDebug('Update request fields: ${request.fields}');

          // Handle image upload
          if (image != null) {
            if (kIsWeb && image is Uint8List) {
              // Web: Store filename instead of base64
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final filename = 'web_upload_$timestamp.jpg';
              request.fields['image'] = filename;
              ApiConfig.logDebug('Updated image filename: $filename');
            } else if (!kIsWeb && image.path != null) {
              // Mobile: Extract filename from path
              final filename = image.path.split('/').last;
              request.fields['image'] = filename;
              ApiConfig.logDebug('Updated image filename: $filename');
            }
          }

          final response = await request.send().timeout(ApiConfig.timeout);
          final responseBody = await response.stream.bytesToString();

          ApiConfig.logDebug('Update response status: ${response.statusCode}');
          ApiConfig.logDebug('Update response body: $responseBody');

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
          } else {
            ApiConfig.logDebug(
              '❌ Update failed with status ${response.statusCode}: $responseBody',
            );
          }
        } catch (e) {
          ApiConfig.logDebug('❌ Error updating product at $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to update product at all endpoints');
    } catch (e) {
      ApiConfig.logDebug('❌ Update product error: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
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
          ApiConfig.logDebug('❌ Error deleting product at $baseUrl: $e');
          continue;
        }
      }

      throw Exception('Failed to delete product at all endpoints');
    } catch (e) {
      ApiConfig.logDebug('❌ Delete product error: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      ApiConfig.logDebug('Fetching categories from backend...');

      // First try to get categories from /categories endpoint
      for (String baseUrl in ApiConfig.fallbackUrls) {
        try {
          final response = await http
              .get(Uri.parse('$baseUrl/categories'), headers: ApiConfig.headers)
              .timeout(const Duration(seconds: 10));

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

            ApiConfig.logDebug(
              '✅ Fetched ${data.length} categories from /categories',
            );
            return data.map((item) => item.toString()).toList();
          }
        } catch (e) {
          ApiConfig.logDebug('❌ Categories endpoint failed for $baseUrl: $e');
          continue;
        }
      }

      // If /categories endpoint fails, extract categories from products
      ApiConfig.logDebug(
        'Categories endpoint not available, extracting from products...',
      );
      try {
        final products = await getProducts();
        final categorySet = <String>{};

        for (final product in products) {
          if (product.category.isNotEmpty) {
            categorySet.add(product.category);
          }
        }

        final categories = categorySet.toList()..sort();
        ApiConfig.logDebug(
          '✅ Extracted ${categories.length} categories from products: $categories',
        );
        return categories;
      } catch (e) {
        ApiConfig.logDebug('❌ Failed to extract categories from products: $e');
      }

      // Return default categories if all else fails
      ApiConfig.logDebug('⚠️ Using default categories (backend unavailable)');
      return [
        'Electronics',
        'Clothing',
        'Food',
        'Books',
        'Home & Garden',
        'Home & Kitchen',
      ];
    } catch (e) {
      ApiConfig.logDebug('❌ Get categories error: $e');
      return [
        'Electronics',
        'Clothing',
        'Food',
        'Books',
        'Home & Garden',
        'Home & Kitchen',
      ];
    }
  }
}
