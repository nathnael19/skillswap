class ApiConstants {
  static String get baseUrl => 'https://skillswap-06182658.fastapicloud.dev/api/v1';
  static String get wsBaseUrl => 'wss://skillswap-06182658.fastapicloud.dev/api/v1';
  static String get mediaBaseUrl => 'https://skillswap-06182658.fastapicloud.dev';
  
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
