import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/config/api_config.dart';

void main() async {
  print('=== Raw HTTP Update Test ===');

  // Let's manually test the HTTP request to see exactly what's being sent
  print('\n1. Testing raw HTTP PUT request...');

  try {
    final baseUrl = ApiConfig.fallbackUrls.first;
    final updateUrl = '$baseUrl/products/1'; // Test with product ID 1

    print('Sending PUT request to: $updateUrl');

    // Create a manual multipart request to debug
    var request = http.MultipartRequest('PUT', Uri.parse(updateUrl));

    // Add fields exactly as the API service does
    request.fields['name'] = 'DEBUG TEST NAME';
    request.fields['category'] = 'DEBUG TEST CATEGORY';
    request.fields['price'] = '999.99';

    print('Request fields being sent:');
    request.fields.forEach((key, value) {
      print('  $key: $value');
    });

    print('Request headers:');
    request.headers.forEach((key, value) {
      print('  $key: $value');
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('\nServer Response:');
    print('Status Code: ${response.statusCode}');
    print('Response Body: $responseBody');

    // Try to parse the response
    try {
      final parsedResponse = json.decode(responseBody);
      print('\nParsed Response:');
      print(json.encode(parsedResponse));

      if (parsedResponse['product'] != null) {
        final returnedProduct = parsedResponse['product'];
        print('\nReturned Product Data:');
        print('  Name: ${returnedProduct['name']}');
        print('  Category: ${returnedProduct['category']}');
        print('  Price: ${returnedProduct['price']}');
        print('  Updated At: ${returnedProduct['updated_at']}');

        // Check if the returned data matches what we sent
        bool nameMatches = returnedProduct['name'] == 'DEBUG TEST NAME';
        bool categoryMatches =
            returnedProduct['category'] == 'DEBUG TEST CATEGORY';
        bool priceMatches = returnedProduct['price'].toString() == '999.99';

        print('\nData Verification:');
        print(
          '  Name updated: ${nameMatches ? "✅" : "❌"} (Expected: DEBUG TEST NAME, Got: ${returnedProduct['name']})',
        );
        print(
          '  Category updated: ${categoryMatches ? "✅" : "❌"} (Expected: DEBUG TEST CATEGORY, Got: ${returnedProduct['category']})',
        );
        print(
          '  Price updated: ${priceMatches ? "✅" : "❌"} (Expected: 999.99, Got: ${returnedProduct['price']})',
        );

        if (!nameMatches || !categoryMatches || !priceMatches) {
          print('\n🔍 BACKEND ISSUE DETECTED:');
          print(
            '   The server is receiving the update request but not processing the new values.',
          );
          print('   Check your backend PUT/UPDATE endpoint implementation.');
        }
      }
    } catch (e) {
      print('Failed to parse response: $e');
    }
  } catch (e) {
    print('❌ Request failed: $e');
  }

  print('\n=== Raw Test Complete ===');
}
