import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const baseUrl = 'http://10.0.2.2:8000/api/products';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }

  static Future<bool> addProduct(String name, String category, double price, File? imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['price'] = price.toString();
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateProduct(int id, String name, String category, double price, File? imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$id?_method=PUT'));
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['price'] = price.toString();
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final response = await request.send();
    return response.statusCode == 200;
  }
}
