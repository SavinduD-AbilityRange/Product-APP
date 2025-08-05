import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<bool> addProduct(Product product, File? image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products/'),
    );
    request.fields['name'] = product.name;
    request.fields['category'] = product.category;
    request.fields['price'] = product.price.toString();
    request.fields['date'] = product.date;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var response = await request.send();

    // 👇 NEW: Read and print the response body
    final responseBody = await response.stream.bytesToString();
    print("Response Status: ${response.statusCode}");
    print("Response Body: $responseBody");

    return response.statusCode == 201;
  }

  static Future<bool> updateProduct(
    int id,
    Product product,
    File? image,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products/$id?_method=PUT'),
    );
    request.fields['name'] = product.name;
    request.fields['category'] = product.category;
    request.fields['price'] = product.price.toString();
    request.fields['date'] = product.date;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var response = await request.send();

    // 👇 NEW: Read and print the response body
    final responseBody = await response.stream.bytesToString();
    print("Response Status: ${response.statusCode}");
    print("Response Body: $responseBody");

    return response.statusCode == 200;
  }

  static Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    return response.statusCode == 200;
  }
}
