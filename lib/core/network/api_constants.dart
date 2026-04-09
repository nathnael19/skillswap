import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:8000/api/v1' 
      : 'http://10.0.2.2:8000/api/v1';
  
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
