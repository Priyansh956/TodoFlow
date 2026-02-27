import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/app_exceptions.dart';

class HttpClient {
  final String baseUrl;
  final http.Client _client;

  HttpClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<dynamic> get(
      String path, {
        Map<String, dynamic>? queryParams,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: queryParams?.map(
              (k, v) => MapEntry(k, v.toString()),
        ),
      );
      final headers = await _getHeaders();
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const ServerException();
    }
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _getHeaders();
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const ServerException();
    }
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _getHeaders();
      final response = await _client
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const ServerException();
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _getHeaders();
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const ServerException();
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw const AuthException('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw const NotFoundException();
    } else {
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final message = body['message'] as String? ?? 'Server error occurred.';
      throw ServerException(message);
    }
  }

  void dispose() => _client.close();
}