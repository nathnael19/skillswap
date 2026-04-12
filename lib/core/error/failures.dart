import 'dart:convert';

abstract class Failure {
  final String message;
  Failure([this.message = 'An unexpected error occurred.']);
}

class ServerFailure extends Failure {
  ServerFailure([super.message]);

  factory ServerFailure.fromResponse(
    int statusCode,
    String body, {
    String? fallbackMessage,
  }) {
    try {
      if (statusCode == 401 || statusCode == 403) {
        return ServerFailure('LOGIN_REQUIRED');
      }

      final map = jsonDecode(body) as Map<String, dynamic>;

      if (statusCode == 402) {
        final detail = map['detail'];
        if (detail is Map && detail['error'] == 'insufficient_credits') {
          return ServerFailure('INSUFFICIENT_CREDITS');
        }
      }
      if (map['detail'] == 'Not authenticated') {
        return ServerFailure('LOGIN_REQUIRED');
      }
      if (map['detail'] != null) {
        final detail = map['detail'];
        if (detail is Map) {
          if (detail['error'] == 'insufficient_credits') {
            return ServerFailure('INSUFFICIENT_CREDITS');
          }
          return ServerFailure(detail.toString());
        }
        return ServerFailure(detail is String ? detail : detail.toString());
      }
    } catch (_) {}
    return ServerFailure(fallbackMessage ?? 'Server returned an error: $body');
  }
}

class ConnectionFailure extends Failure {
  ConnectionFailure([super.message = 'No internet connection.']);
}
