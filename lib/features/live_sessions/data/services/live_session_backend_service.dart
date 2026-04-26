import 'dart:convert';

import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_service.dart';

class JoinTokenResponse {
  final String token;
  final String roomId;
  final SessionRole role;

  const JoinTokenResponse({
    required this.token,
    required this.roomId,
    required this.role,
  });
}

class LiveSessionBackendService {
  final ApiClient _apiClient;

  LiveSessionBackendService(this._apiClient);

  Future<JoinTokenResponse> getJoinToken(String sessionId) async {
    final response = await _apiClient.post(
      '${ApiConstants.liveSessions}/$sessionId/join-token',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to get session join token',
      );
    }
    final data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final roleName = (data['role'] as String? ?? 'audience').toLowerCase();
    final role = roleName == 'host' ? SessionRole.host : SessionRole.audience;
    return JoinTokenResponse(
      token: data['token'] as String,
      roomId: data['room_id'] as String? ?? '',
      role: role,
    );
  }

  Future<void> startSession(String sessionId) async {
    final response = await _apiClient.post(
      '${ApiConstants.liveSessions}/$sessionId/start',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to start session',
      );
    }
  }

  Future<void> updateSession({
    required String sessionId,
    String? title,
    DateTime? scheduledAt,
    List<String>? topics,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (scheduledAt != null) body['scheduled_at'] = scheduledAt.toUtc().toIso8601String();
    if (topics != null) body['topics'] = topics;

    final response = await _apiClient.patch(
      '${ApiConstants.liveSessions}/$sessionId',
      body: body,
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to update session',
      );
    }
  }

  Future<String> createSession({
    required String title,
    required DateTime scheduledAt,
    int maxParticipants = 20,
    String type = 'group',
    String? participantId,
    List<String>? topics,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'max_participants': maxParticipants,
      'type': type,
      'topics': topics ?? [],
    };
    if (participantId != null) {
      body['participant_id'] = participantId;
    }

    final response = await _apiClient.post(
      '${ApiConstants.liveSessions}/',
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
      );
    }
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        final id = data['id'] ?? data['session_id'] ?? data['room_id'];
        if (id != null) {
          return id.toString();
        }
      }
      throw ServerFailure('Server returned an invalid response format.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to parse server response: ${response.body}');
    }
  }

  Future<void> endSession(String sessionId) async {
    final response = await _apiClient.post(
      '${ApiConstants.liveSessions}/$sessionId/end',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to end session',
      );
    }
  }

  Future<void> leaveSession(String sessionId) async {
    final response = await _apiClient.post(
      '${ApiConstants.liveSessions}/$sessionId/leave',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to leave session',
      );
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.liveSessions}/$sessionId',
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to delete session',
      );
    }
  }
}
