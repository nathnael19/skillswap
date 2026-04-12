import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiClient {
  final FirebaseAuth _auth;
  final http.Client _client;
  
  String? _cachedToken;
  DateTime? _tokenExpiry;

  ApiClient(this._auth, this._client);

  Future<Map<String, String>> _getHeaders() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'Content-Type': 'application/json'};
    }
    
    // Cache for 45 minutes (Firebase tokens last 60 minutes) to avoid platform channel overhead
    if (_cachedToken == null || _tokenExpiry == null || DateTime.now().isAfter(_tokenExpiry!)) {
      _cachedToken = await user.getIdToken();
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 45));
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_cachedToken',
    };
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
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
    return await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
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
}
