import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/query_response.dart'; // Import the model

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<QueryResponse> generateQuery(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate_query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      return QueryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to generate query');
    }
  }
}
