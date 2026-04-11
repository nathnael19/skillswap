import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConstants {
  static String get _host {
    if (kIsWeb) return '127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return '10.0.2.2:8000';
    } catch (_) {}
    return '127.0.0.1:8000';
  }

  static String get baseUrl => 'http://$_host/api/v1';
  static String get wsBaseUrl => 'ws://$_host/api/v1';
  
  // Auth & Users
  static const String initUser = '/users/init';
  static const String me = '/users/me';
  static const String discover = '/users/discover';
  static const String userById = '/users'; // /users/{id}
  
  // Upload
  static const String uploadImage = '/upload/image';
  
  // Matches
  static const String swipes = '/matches/swipes';
  static const String matches = '/matches/matches';
  static const String likesReceived = '/matches/received-likes';
  static const String sentLikes = '/matches/sent-likes';
  static const String sentDislikes = '/matches/sent-dislikes';
  
  // Chat
  static const String messages = '/messages'; // /messages/{match_id}
  
  // Sessions
  static const String sessions = '/sessions';
  
  // Ratings
  static const String ratings = '/ratings';
  static const String userRatings = '/ratings/users'; // /ratings/users/{id}
  
  // Credits
  static const String credits = '/credits';
}
