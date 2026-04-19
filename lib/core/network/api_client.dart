import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiClient {
  final FirebaseAuth _auth;
  final http.Client _client;

  String? _cachedToken;

  ApiClient(this._auth, this._client) {
    _auth.idTokenChanges().listen((user) async {
      if (user != null) {
        _cachedToken = await user.getIdToken();
      } else {
        _cachedToken = null;
      }
    });
  }

  Future<Map<String, String>> _getHeaders() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'Content-Type': 'application/json'};
    }

    // Fallback if the stream hasn't populated it yet
    _cachedToken ??= await user.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_cachedToken',
    };
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final headers = await _getHeaders();
    var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return await _client.get(uri, headers: headers);
  }

  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    // POST + application/json + zero-length body breaks some browsers (Failed to fetch).
    if (body == null) {
      final withoutContentType = Map<String, String>.from(headers)
        ..remove('Content-Type');
      return await _client.post(uri, headers: withoutContentType);
    }
    return await _client.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await _client.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await _client.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await _client.delete(uri, headers: headers);
  }

  Future<http.Response> upload(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
