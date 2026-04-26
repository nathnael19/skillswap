import 'dart:convert';

import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/hubs/data/models/hub_message_model.dart';
import 'package:skillswap/features/hubs/data/models/hub_model.dart';

class HubBackendService {
  final ApiClient _apiClient;

  HubBackendService(this._apiClient);

  Future<List<Hub>> listHubs() async {
    final response = await _apiClient.get(ApiConstants.hubs);
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch hubs',
      );
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Hub.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<String> createHub({
    required String name,
    required String slug,
    required String description,
    required String category,
    bool isPrivate = false,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.hubs,
      body: {
        'name': name,
        'slug': slug,
        'description': description,
        'category': category,
        'is_private': isPrivate,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to create hub',
      );
    }
    final data = jsonDecode(response.body);
    return data['id'];
  }

  Future<void> joinHub(String hubId) async {
    final response = await _apiClient.post(
      '${ApiConstants.hubs}/$hubId/join',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to join hub',
      );
    }
  }

  Future<void> leaveHub(String hubId) async {
    final response = await _apiClient.post(
      '${ApiConstants.hubs}/$hubId/leave',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to leave hub',
      );
    }
  }

  Future<List<HubMessage>> getMessages(String hubId) async {
    final response = await _apiClient.get('${ApiConstants.hubs}/$hubId/messages');
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch hub messages',
      );
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => HubMessage.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> sendMessage(String hubId, String text) async {
    final response = await _apiClient.post(
      '${ApiConstants.hubs}/$hubId/messages',
      body: {'text': text},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to send hub message',
      );
    }
  }
}
