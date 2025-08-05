import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api_config.dart';

class ApiService {
  // Use the configuration file for flexible URL management
  static String get baseUrl => ApiConfig.productsUrl;

  // Test endpoints with fallback URLs
  static Future<bool> pingServer() async {
    final fallbackUrls = ApiConfig.fallbackUrls;

    print('=== Starting pingServer() ===');
    print('Platform: ${Platform.operatingSystem}');
    print('Fallback URLs: $fallbackUrls');

    for (int i = 0; i < fallbackUrls.length; i++) {
      String baseUrl = fallbackUrls[i];
      try {
        final pingUrl = '$baseUrl/ping';
        print('Ping attempt ${i + 1}/${fallbackUrls.length}: $pingUrl');

        final response = await http
            .get(
              Uri.parse(pingUrl),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        print(
          'Ping response - Status: ${response.statusCode}, Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          print('✅ Ping successful to: $pingUrl');
          return true;
        }
      } catch (e) {
        print('❌ Ping failed for $baseUrl: $e');
        continue; // Try next URL
      }
    }

    print('❌ All ping attempts failed');
    return false;
  }

  static Future<Map<String, dynamic>?> checkEnvironment() async {
    final fallbackUrls = ApiConfig.fallbackUrls;

    print('=== Starting checkEnvironment() ===');
    print('Fallback URLs: $fallbackUrls');

    for (int i = 0; i < fallbackUrls.length; i++) {
      String baseUrl = fallbackUrls[i];
      try {
        final checkUrl = '$baseUrl/check-env';
        print('Attempt ${i + 1}/${fallbackUrls.length}: GET $checkUrl');

        final response = await http
            .get(
              Uri.parse(checkUrl),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        print('Response - Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          print('✅ Environment check successful to: $checkUrl');
          return json.decode(response.body);
        }
      } catch (e) {
        print('❌ Environment check failed for $baseUrl: $e');
        continue; // Try next URL
      }
    }

    print('❌ All environment check attempts failed');
    return null;
  }

  static Future<List<Product>> fetchProducts() async {
    final fallbackUrls = ApiConfig.fallbackUrls;

    print('=== Starting fetchProducts() ===');
    print('Platform: ${Platform.operatingSystem}');
    print('Fallback URLs: $fallbackUrls');

    for (int i = 0; i < fallbackUrls.length; i++) {
      String baseUrl = fallbackUrls[i];
      try {
        final productsUrl = '$baseUrl/products';
        print(
          'Attempt ${i + 1}/${fallbackUrls.length}: Connecting to $productsUrl',
        );

        final response = await http
            .get(
              Uri.parse(productsUrl),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 8)); // Increased timeout

        print('Response received - Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('Raw response: $responseData');

          // Handle different response formats
          List data;
          if (responseData is List) {
            // Direct array response
            data = responseData;
          } else if (responseData is Map &&
              responseData.containsKey('products')) {
            // Wrapped response with 'products' key
            data = responseData['products'];
          } else if (responseData is Map && responseData.containsKey('data')) {
            // Wrapped response with 'data' key
            data = responseData['data'];
          } else {
            print('Unexpected response format: $responseData');
            throw Exception('Unexpected response format from server');
          }

          print('SUCCESS: Fetched ${data.length} products from $productsUrl');
          return data.map((item) => Product.fromJson(item)).toList();
        } else if (response.statusCode == 500) {
          print('Server error (500) for $productsUrl - trying next URL');
          continue; // Try next URL
        } else {
          print(
            'HTTP error ${response.statusCode} for $productsUrl - trying next URL',
          );
          continue; // Try next URL instead of throwing exception
        }
      } catch (e) {
        print('ERROR for $baseUrl: $e');

        if (e.toString().contains('TimeoutException')) {
          print('⚠️  Connection timed out after 8 seconds');
        } else if (e.toString().contains('SocketException')) {
          print('⚠️  Cannot reach server - check if backend is running');
        }

        // If this is the last URL, throw the exception
        if (i == fallbackUrls.length - 1) {
          print('❌ All URLs failed. Last error: $e');
          throw Exception(
            'Cannot connect to server. Please check:\n'
            'Last error: $e',
          );
        }
        continue; // Try next URL
      }
    }

    throw Exception('All connection attempts failed');
  }

  static Future<bool> deleteProduct(int id) async {
    final fallbackUrls = ApiConfig.fallbackUrls;

    print('=== Starting deleteProduct() ===');
    print('Product ID: $id');

    for (int i = 0; i < fallbackUrls.length; i++) {
      String baseUrl = fallbackUrls[i];
      try {
        final deleteUrl = '$baseUrl/products/$id';
        print('Attempt ${i + 1}/${fallbackUrls.length}: DELETE to $deleteUrl');

        final response = await http.delete(
          Uri.parse(deleteUrl),
          headers: {'Content-Type': 'application/json'},
        );

        print('Response - Status: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 204) {
          print('✅ Product deleted successfully from $deleteUrl');
          return true;
        } else {
          print('❌ Failed to delete product - Status: ${response.statusCode}');
          if (i == fallbackUrls.length - 1) {
            throw Exception('Server returned status ${response.statusCode}');
          }
          continue; // Try next URL
        }
      } catch (e) {
        print('❌ Error deleting product from $baseUrl: $e');
        if (i == fallbackUrls.length - 1) {
          throw Exception('Failed to delete product: $e');
        }
        continue; // Try next URL
      }
    }

    throw Exception('All connection attempts failed');
  }

  static Future<bool> addProduct(
    String name,
    String category,
    double price,
    File? imageFile,
  ) async {
    final fallbackUrls = ApiConfig.fallbackUrls;

    print('=== Starting addProduct() ===');
    print('Product details: name=$name, category=$category, price=$price');
    print('Image file: ${imageFile?.path ?? 'No image'}');

    for (int i = 0; i < fallbackUrls.length; i++) {
      String baseUrl = fallbackUrls[i];
      try {
        final addUrl = '$baseUrl/products';
        print('Attempt ${i + 1}/${fallbackUrls.length}: POST to $addUrl');

        var request = http.MultipartRequest('POST', Uri.parse(addUrl));
        request.fields['name'] = name;
        request.fields['category'] = category;
        request.fields['price'] = price.toString();

        if (imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Response - Status: ${response.statusCode}, Body: $responseBody');

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Product added successfully to $addUrl');
          return true;
        } else {
          print('❌ Failed to add product - Status: ${response.statusCode}');
          if (i == fallbackUrls.length - 1) {
            throw Exception(
              'Server returned status ${response.statusCode}: $responseBody',
            );
          }
          continue; // Try next URL
        }
      } catch (e) {
        print('❌ Error adding product to $baseUrl: $e');
        if (i == fallbackUrls.length - 1) {
          throw Exception('Failed to add product: $e');
        }
        continue; // Try next URL
      }
    }

    throw Exception('All connection attempts failed');
  }

  static Future<bool> updateProduct(
    int id,
    String name,
    String category,
    double price,
    File? imageFile,
  ) async {
    final fallbackUrls = ApiConfig.fallbackUrls;

    print('=== Starting updateProduct() ===');
    print('Product ID: $id, name=$name, category=$category, price=$price');
    print('Image file: ${imageFile?.path ?? 'No new image'}');

    for (int i = 0; i < fallbackUrls.length; i++) {
      String baseUrl = fallbackUrls[i];
      try {
        final updateUrl = '$baseUrl/products/$id';
        print('Attempt ${i + 1}/${fallbackUrls.length}: PUT to $updateUrl');

        var request = http.MultipartRequest('PUT', Uri.parse(updateUrl));
        request.fields['name'] = name;
        request.fields['category'] = category;
        request.fields['price'] = price.toString();

        if (imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Response - Status: ${response.statusCode}, Body: $responseBody');

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Product updated successfully at $updateUrl');
          return true;
        } else {
          print('❌ Failed to update product - Status: ${response.statusCode}');
          if (i == fallbackUrls.length - 1) {
            throw Exception(
              'Server returned status ${response.statusCode}: $responseBody',
            );
          }
          continue; // Try next URL
        }
      } catch (e) {
        print('❌ Error updating product at $baseUrl: $e');
        if (i == fallbackUrls.length - 1) {
          throw Exception('Failed to update product: $e');
        }
        continue; // Try next URL
      }
    }

    throw Exception('All connection attempts failed');
  }
}
