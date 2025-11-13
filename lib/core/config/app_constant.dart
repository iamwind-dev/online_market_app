/// Lưu trữ các hằng số toàn cục của ứng dụng
class AppConstant {
  AppConstant._();

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';
  static const String userProfileEndpoint = '/user/profile';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String firstLaunchKey = 'first_launch';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10,11}$';
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Error Messages
  static const String networkErrorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại.';
  static const String serverErrorMessage = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String unknownErrorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String timeoutErrorMessage = 'Yêu cầu hết thời gian chờ.';
  static const String unauthorizedErrorMessage = 'Phiên đăng nhập đã hết hạn.';

  // Defaults
  static const String defaultLanguage = 'vi';
  static const String defaultCurrency = 'VND';
  static const String defaultCountryCode = 'VN';

  // Limits
  static const int maxCartItems = 99;
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50 MB
}
