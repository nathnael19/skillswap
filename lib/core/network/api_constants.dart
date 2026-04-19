class ApiConstants {
  static const String _defaultHost = 'skillswap-06182658.fastapicloud.dev';

  static String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://$_defaultHost/api/v1',
      );
  static String get wsBaseUrl => const String.fromEnvironment(
        'WS_BASE_URL',
        defaultValue: 'wss://$_defaultHost/api/v1',
      );
  static String get mediaBaseUrl => const String.fromEnvironment(
        'MEDIA_BASE_URL',
        defaultValue: 'https://$_defaultHost',
      );

  // App Config
  static const String appConfig = '/config';
  
  // Auth & Users
  static const String initUser = '/users/init';
  static const String me = '/users/me';
  static const String updateUser = '/users/me';
  static const String deleteUser = '/users/me';
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
  static const String acceptMatch = '/matches'; // /matches/{match_id}/accept
  
  // Chat
  static const String messages = '/messages'; // /messages/{match_id}
  static const String initPaidChat = '/messages/init-paid';
  
  // Sessions
  static const String sessions = '/sessions';
  
  // Ratings
  static const String ratings = '/ratings';
  static const String userRatings = '/ratings/users'; // /ratings/users/{id}
  
  // Credits
  static const String credits = '/credits';
  static const String withdraw = '/credits/withdraw';

  // Billing
  static const String billingCheckout = '/billing/checkout';
}
