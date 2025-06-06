import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';

class ApiClient {
  final String _baseUrl = Env.baseUrl;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': Env.apiKey,
    'Authorization': 'Bearer ${Env.apiKey}',
    'Prefer': 'return=representation'  // This tells Supabase to return the created record
  };

  Future<List<dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'),
        headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    print('Sending data to $endpoint: ${jsonEncode(data)}');
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Accept both 200 and 201 as success codes
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        final decoded = json.decode(response.body);
        // Supabase might return an array with one item
        if (decoded is List && decoded.isNotEmpty) {
          return decoded[0];
        }
        return decoded;
      } else {
        // If body is empty but status is success, return the data that was sent
        return data;
      }
    } else {
      throw Exception('Failed to post data: ${response.statusCode} : ${response.body}');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  Future<void> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }
}