class ApiConstants {
  // Use 10.0.2.2 for Android emulator, localhost for others
  static const String _devHost = '10.240.41.182:8000';
  static const String _prodHost = 'skillswap-06182658.fastapicloud.dev';

  static const bool _useLocal =
      false; // Toggle this to switch between local and production

  static const String _host = _useLocal ? _devHost : _prodHost;
  static const String _protocol = _useLocal ? 'http' : 'https';
  static const String _wsProtocol = _useLocal ? 'ws' : 'wss';

  static const String _defaultBaseUrl = '$_protocol://$_host/api/v1';
  static const String _defaultWsUrl = '$_wsProtocol://$_host/api/v1';
  static const String _defaultMediaUrl = '$_protocol://$_host';

  static String get baseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );
  static String get wsBaseUrl =>
      const String.fromEnvironment('WS_BASE_URL', defaultValue: _defaultWsUrl);
  static String get mediaBaseUrl => const String.fromEnvironment(
    'MEDIA_BASE_URL',
    defaultValue: _defaultMediaUrl,
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

  // Matchejs
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
  static const String liveSessions = '/live-sessions';
  static const String hubs = '/hubs';

  // Ratings
  static const String ratings = '/ratings';
  static const String userRatings = '/ratings/users'; // /ratings/users/{id}

  // Credits
  static const String credits = '/credits';
  static const String withdraw = '/credits/withdraw';

  // Billing
  static const String billingCheckout = '/billing/checkout';
}
