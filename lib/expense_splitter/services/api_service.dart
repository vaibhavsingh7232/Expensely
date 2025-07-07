import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://bill-splitting-backend-0lof.onrender.com/api/splits';

  static Future<List<dynamic>> fetchSplits() async {
    final url = Uri.parse('https://bill-splitting-backend-0lof.onrender.com/api/splits/all'); // change if deployed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch splits');
    }
  }

  static Future<void> saveSplit(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('Request URL: $url');
      print('Request Body: ${jsonEncode(data)}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to save split');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
  }
}
