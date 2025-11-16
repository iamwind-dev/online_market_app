/// Cấu hình toàn cục cho ứng dụng
/// Chứa các thông tin về môi trường, API, timeout, etc.
class AppConfig {
  // Singleton pattern
  AppConfig._();
  static final AppConfig instance = AppConfig._();
  factory AppConfig() => instance;

  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://subtle-seat-475108-v5.et.r.appspot.com/api',
  );

  // API Endpoints
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLogoutEndpoint = '/auth/logout';
  static const String authRefreshEndpoint = '/auth/refresh';
  static const String authMeEndpoint = '/auth/me';

  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // App Information
  static const String appName = 'Online Market';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB

  // Authentication
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true; // Log API requests/responses

  // Check if in development mode
  bool get isDevelopment => environment == 'development';
  bool get isProduction => environment == 'production';
  bool get isStaging => environment == 'staging';

  // Get full API URL
  String getApiUrl(String endpoint) {
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$baseUrl$cleanEndpoint';
  }

  // Get full auth login URL
  static String get fullAuthLoginUrl => '$baseUrl$authLoginEndpoint';
  static String get fullAuthRegisterUrl => '$baseUrl$authRegisterEndpoint';
  static String get fullAuthLogoutUrl => '$baseUrl$authLogoutEndpoint';
  static String get fullAuthRefreshUrl => '$baseUrl$authRefreshEndpoint';
  static String get fullAuthMeUrl => '$baseUrl$authMeEndpoint';
}
