import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visit_tracker/env.dart';

class ApiClient {
  final String _baseUrl = Env.baseUrl;
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'apikey': Env.apiKey,
    'Authorization': 'Bearer ${Env.apiKey}'
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
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
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