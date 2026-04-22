import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_token_store.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required AuthTokenStore tokenStore,
    http.Client? httpClient,
    Uri? baseUri,
  }) : _tokenStore = tokenStore,
       _httpClient = httpClient ?? http.Client(),
       _baseUri = baseUri ?? Uri.parse(_defaultBaseUrl);

  static const String _configuredBaseUrl = String.fromEnvironment(
    'HABITBET_API_BASE_URL',
    defaultValue: '',
  );

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  final AuthTokenStore _tokenStore;
  final http.Client _httpClient;
  final Uri _baseUri;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _send(
      'GET',
      path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
    return _decodeObject(response);
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _send(
      'GET',
      path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
    final payload = _decodeJson(response);
    if (payload is List<dynamic>) {
      return payload;
    }

    throw const ApiException('Unexpected response format.');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _send(
      'POST',
      path,
      body: body,
      authenticated: authenticated,
    );

    if (response.statusCode == HttpStatus.noContent || response.body.isEmpty) {
      return const <String, dynamic>{};
    }

    return _decodeObject(response);
  }

  Future<void> postEmpty(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    await _send('POST', path, body: body, authenticated: authenticated);
  }

  Future<void> putBytesUrl(
    String url, {
    required List<int> bytes,
    String? contentType,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse(url);
    final headers = await _buildHeaders(
      authenticated: authenticated,
      contentType: contentType,
    );

    late final http.Response response;
    try {
      response = await _httpClient.put(uri, headers: headers, body: bytes);
    } on SocketException {
      throw ApiException(
        'Could not connect to HabitBet backend at ${uri.origin}.',
      );
    } on http.ClientException catch (error) {
      throw ApiException(error.message);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ApiException(
      _extractErrorMessage(response),
      statusCode: response.statusCode,
    );
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    required bool authenticated,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final headers = await _buildHeaders(
      authenticated: authenticated,
      contentType: body == null ? null : 'application/json',
    );

    late final http.Response response;
    try {
      if (method == 'GET') {
        response = await _httpClient.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await _httpClient.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      } else {
        throw ApiException('Unsupported HTTP method: $method');
      }
    } on SocketException {
      throw ApiException(
        'Could not connect to HabitBet backend at ${_baseUri.origin}.',
      );
    } on http.ClientException catch (error) {
      throw ApiException(error.message);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    throw ApiException(
      _extractErrorMessage(response),
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, String>> _buildHeaders({
    required bool authenticated,
    String? contentType,
  }) async {
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (contentType != null) {
      headers[HttpHeaders.contentTypeHeader] = contentType;
    }

    if (!authenticated) {
      return headers;
    }

    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      throw const ApiException('Authentication is required.', statusCode: 401);
    }
    headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    return headers;
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;

    return _baseUri.replace(
      path: '$basePath/$normalizedPath',
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final payload = _decodeJson(response);
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    throw const ApiException('Unexpected response format.');
  }

  dynamic _decodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _extractErrorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'Request failed with status ${response.statusCode}.';
    }

    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is Map<String, dynamic>) {
        final error = payload['error'];
        if (error is Map<String, dynamic> && error['message'] is String) {
          return error['message'] as String;
        }

        final detail = payload['detail'];
        if (detail is String) {
          return detail;
        }

        if (detail is List) {
          final messages = detail
              .whereType<Map<String, dynamic>>()
              .map((item) => item['msg'])
              .whereType<String>()
              .toList();
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
      }
    } catch (_) {
      // Fall through to generic error message below.
    }

    return 'Request failed with status ${response.statusCode}.';
  }
}
