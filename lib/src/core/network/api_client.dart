import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../error/failures.dart';

/// Remote data source implementation using HTTP client
///
/// All network operations go through this layer.
/// Repository pattern: UI reads from local cache, network writes to cache.
abstract class ApiClient {
  /// Base URL for the Airbnb clone API
  static const String _baseUrl = 'https://api.airbnb-clone.local';
  static const Duration _timeout = Duration(seconds: 15);

  /// Generic GET request
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParameters);

    try {
      final response = await _sendRequest(() => http.get(uri));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw NotFoundFailure(resource: endpoint);
      } else {
        throw ServerFailure(statusCode: response.statusCode);
      }
    } on ServerFailure {
      rethrow;
    } on CacheFailure {
      rethrow;
    } on Error catch (e) {
      throw NetworkFailure();
    }
  }

  /// Generic POST request
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await _sendRequest(() => http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ServerFailure(statusCode: response.statusCode);
      }
    } on ServerFailure {
      rethrow;
    } on CacheFailure {
      rethrow;
    } on Error catch (e) {
      throw NetworkFailure();
    }
  }

  /// Generic PUT request
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await _sendRequest(() => http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ServerFailure(statusCode: response.statusCode);
      }
    } on ServerFailure {
      rethrow;
    } on CacheFailure {
      rethrow;
    } on Error catch (e) {
      throw NetworkFailure();
    }
  }

  /// Generic DELETE request
  static Future<void> delete({
    required String endpoint,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await _sendRequest(() => http.delete(uri));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerFailure(statusCode: response.statusCode);
      }
    } on ServerFailure {
      rethrow;
    } on CacheFailure {
      rethrow;
    } on Error catch (e) {
      throw NetworkFailure();
    }
  }

  /// Internal request sender with timeout and error handling
  static Future<http.Response> _sendRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      return response;
    } on TimeoutException {
      throw NetworkFailure();
    } on SocketException {
      throw NetworkFailure();
    } on HttpException {
      throw NetworkFailure();
    } on FormatException {
      throw NetworkFailure();
    } catch (e) {
      rethrow;
    }
  }
}