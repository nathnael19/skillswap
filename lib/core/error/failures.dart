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

      final map = jsonDecode(body);
      if (map['detail'] == 'Not authenticated') {
        return ServerFailure('LOGIN_REQUIRED');
      }
      if (map['detail'] != null) {
        return ServerFailure(map['detail']);
      }
    } catch (_) {}
    return ServerFailure(fallbackMessage ?? 'Server returned an error: $body');
  }
}

class ConnectionFailure extends Failure {
  ConnectionFailure([super.message = 'No internet connection.']);
}
