import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../error/app_exception.dart';
import '../../utils/app_logger.dart';
import '../../models/user_model.dart';
import '../local_storage_service.dart';
import 'auth_response.dart';

/// Service xử lý authentication với API
class AuthService {
  final http.Client _client;
  final LocalStorageService _localStorage;

  AuthService({
    http.Client? client,
    LocalStorageService? localStorage,
  })  : _client = client ?? http.Client(),
        _localStorage = localStorage ?? LocalStorageService();

  /// Đăng ký tài khoản mới
  Future<AuthResponse> register({
    required String username,
    required String password,
    required String fullName,
    String role = 'nguoi_mua',
  }) async {
    final registerUrl = AppConfig.fullAuthRegisterUrl;
    
    if (AppConfig.enableApiLogging) {
      AppLogger.info('📝 [AUTH] Đang đăng ký tài khoản...');
      AppLogger.info('📡 [AUTH] URL: $registerUrl');
      AppLogger.info('👤 [AUTH] Username: $username');
      AppLogger.info('🎭 [AUTH] Role: $role');
    }

    try {
      // Prepare request body
      final body = jsonEncode({
        'ten_dang_nhap': username,
        'mat_khau': password,
        'ten_nguoi_dung': fullName,
        'role': role,
      });

      if (AppConfig.enableApiLogging) {
        AppLogger.info('📤 [AUTH] Request body: $body');
      }

      // Send POST request
      final response = await _client.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        Duration(milliseconds: AppConfig.connectTimeout),
        onTimeout: () {
          AppLogger.error('⏱️ [AUTH] Request timeout');
          throw NetworkException(message: 'Timeout - Vui lòng thử lại');
        },
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('📥 [AUTH] Response status: ${response.statusCode}');
        AppLogger.info('📥 [AUTH] Response body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final jsonData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);

        if (AppConfig.enableApiLogging) {
          AppLogger.info('✅ [AUTH] Đăng ký thành công');
          AppLogger.info('🎫 [AUTH] Token: ${authResponse.token}');
          AppLogger.info('👤 [AUTH] User: ${authResponse.data.tenDangNhap}');
        }

        // Save to local storage
        await _saveAuthData(authResponse);

        return authResponse;
      } else if (response.statusCode == 409) {
        // Conflict - username already exists
        AppLogger.warning('❌ [AUTH] Đăng ký thất bại - Tên đăng nhập đã tồn tại');
        throw ConflictException(message: 'Tên đăng nhập đã tồn tại!');
      } else if (response.statusCode == 400) {
        // Bad request - invalid data
        AppLogger.warning('❌ [AUTH] Đăng ký thất bại - Dữ liệu không hợp lệ');
        throw ValidationException(message: 'Thông tin đăng ký không hợp lệ!');
      } else if (response.statusCode >= 500) {
        // Server error
        AppLogger.error('🔥 [AUTH] Lỗi server: ${response.statusCode}');
        throw ServerException(message: 'Lỗi server - Vui lòng thử lại sau');
      } else {
        // Other errors
        AppLogger.error('⚠️ [AUTH] Lỗi không xác định: ${response.statusCode}');
        throw ServerException(
          message: 'Lỗi đăng ký (${response.statusCode})',
        );
      }
    } on http.ClientException catch (e) {
      AppLogger.error('🌐 [AUTH] Lỗi kết nối: ${e.message}');
      throw NetworkException(message: 'Lỗi kết nối: ${e.message}');
    } on FormatException catch (e) {
      AppLogger.error('📝 [AUTH] Lỗi parse JSON: ${e.message}');
      throw ParseException(message: 'Lỗi định dạng dữ liệu: ${e.message}');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      AppLogger.error('💥 [AUTH] Lỗi không xác định: ${e.toString()}');
      throw AppException(message: 'Đã có lỗi xảy ra: ${e.toString()}');
    }
  }

  /// Đăng nhập với username và password
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final loginUrl = AppConfig.fullAuthLoginUrl;
    
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🔐 [AUTH] Đang đăng nhập...');
      AppLogger.info('📡 [AUTH] URL: $loginUrl');
      AppLogger.info('👤 [AUTH] Username: $username');
    }

    try {
      // Prepare request body
      final body = jsonEncode({
        'ten_dang_nhap': username,
        'mat_khau': password,
      });

      if (AppConfig.enableApiLogging) {
        AppLogger.info('📤 [AUTH] Request body: $body');
      }

      // Send POST request
      final response = await _client.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        Duration(milliseconds: AppConfig.connectTimeout),
        onTimeout: () {
          AppLogger.error('⏱️ [AUTH] Request timeout');
          throw NetworkException(message: 'Timeout - Vui lòng thử lại');
        },
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('📥 [AUTH] Response status: ${response.statusCode}');
        AppLogger.info('📥 [AUTH] Response body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final jsonData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);

        if (AppConfig.enableApiLogging) {
          AppLogger.info('✅ [AUTH] Đăng nhập thành công');
          AppLogger.info('🎫 [AUTH] Token: ${authResponse.token}');
          AppLogger.info('👤 [AUTH] User: ${authResponse.data.tenDangNhap}');
        }

        // Save to local storage
        await _saveAuthData(authResponse);

        return authResponse;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Unauthorized - wrong credentials
        AppLogger.warning('❌ [AUTH] Đăng nhập thất bại - Sai thông tin');
        throw UnauthorizedException(message: 'Sai tên đăng nhập hoặc mật khẩu!');
      } else if (response.statusCode >= 500) {
        // Server error
        AppLogger.error('🔥 [AUTH] Lỗi server: ${response.statusCode}');
        throw ServerException(message: 'Lỗi server - Vui lòng thử lại sau');
      } else {
        // Other errors - use ServerException for generic API errors
        AppLogger.error('⚠️ [AUTH] Lỗi không xác định: ${response.statusCode}');
        throw ServerException(
          message: 'Lỗi đăng nhập (${response.statusCode})',
        );
      }
    } on http.ClientException catch (e) {
      AppLogger.error('🌐 [AUTH] Lỗi kết nối: ${e.message}');
      throw NetworkException(message: 'Lỗi kết nối: ${e.message}');
    } on FormatException catch (e) {
      AppLogger.error('📝 [AUTH] Lỗi parse JSON: ${e.message}');
      throw ParseException(message: 'Lỗi định dạng dữ liệu: ${e.message}');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      AppLogger.error('💥 [AUTH] Lỗi không xác định: ${e.toString()}');
      throw AppException(message: 'Đã có lỗi xảy ra: ${e.toString()}');
    }
  }

  /// Lưu thông tin authentication vào local storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('💾 [AUTH] Đang lưu token vào local storage...');
    }

    // Save token
    await _localStorage.setString('auth_token', authResponse.token);

    // Save user data as JSON string
    final userData = jsonEncode(authResponse.data.toJson());
    await _localStorage.setString('user_data', userData);

    // Save login status
    await _localStorage.setBool('is_logged_in', true);

    // Save login time
    await _localStorage.setString(
      'login_time',
      DateTime.now().toIso8601String(),
    );

    if (AppConfig.enableApiLogging) {
      AppLogger.info('✅ [AUTH] Token đã được lưu thành công');
    }
  }

  /// Lấy token đã lưu
  Future<String?> getToken() async {
    return _localStorage.getString('auth_token');
  }

  /// Lấy user data đã lưu
  Future<UserData?> getUserData() async {
    final userDataString = _localStorage.getString('user_data');
    if (userDataString == null) return null;

    try {
      final jsonData = jsonDecode(userDataString);
      return UserData.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    final isLoggedIn = _localStorage.getBool('is_logged_in');
    final token = await getToken();
    final result = (isLoggedIn ?? false) && token != null;
    
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🔍 [AUTH] Check login status: $result');
    }
    
    return result;
  }

  /// Kiểm tra token có hết hạn không
  Future<bool> isTokenExpired() async {
    final loginTimeString = _localStorage.getString('login_time');
    if (loginTimeString == null) return true;

    try {
      final loginTime = DateTime.parse(loginTimeString);
      final now = DateTime.now();
      final difference = now.difference(loginTime);
      
      // Token hết hạn sau 7 ngày (có thể điều chỉnh)
      const tokenDuration = Duration(days: 7);
      final isExpired = difference > tokenDuration;
      
      if (AppConfig.enableApiLogging) {
        AppLogger.info('⏰ [AUTH] Token expired: $isExpired (logged in ${difference.inHours}h ago)');
      }
      
      return isExpired;
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [AUTH] Error checking token expiration: $e');
      }
      return true;
    }
  }

  /// Kiểm tra và tự động logout nếu token hết hạn
  Future<bool> checkAndHandleTokenExpiration() async {
    final isExpired = await isTokenExpired();
    if (isExpired) {
      await logout();
      if (AppConfig.enableApiLogging) {
        AppLogger.info('🔒 [AUTH] Token đã hết hạn, đã tự động logout');
      }
      return true;
    }
    return false;
  }

  /// Lấy thông tin user hiện tại từ API
  Future<UserModel> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw UnauthorizedException(message: 'Token không tồn tại');
    }

    final url = AppConfig.fullAuthMeUrl;
    
    if (AppConfig.enableApiLogging) {
      AppLogger.info('👤 [AUTH] Đang lấy thông tin user từ API...');
      AppLogger.info('📡 [AUTH] URL: $url');
    }

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('📥 [AUTH] Response status: ${response.statusCode}');
        AppLogger.info('📥 [AUTH] Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (AppConfig.enableApiLogging) {
          AppLogger.info('📦 [AUTH] Response structure: ${jsonData.keys}');
        }
        
        // Kiểm tra nếu response có wrapper (ví dụ: {data: {...}})
        final userData = jsonData['data'] ?? jsonData;
        final user = UserModel.fromJson(userData);
        
        if (AppConfig.enableApiLogging) {
          AppLogger.info('✅ [AUTH] Lấy thông tin user thành công: ${user.tenNguoiDung}');
        }
        
        return user;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Token hết hạn hoặc không hợp lệ');
      } else {
        throw ServerException(message: 'Lỗi server: ${response.statusCode}', statusCode: response.statusCode);
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [AUTH] Lỗi khi lấy thông tin user: $e');
      }
      rethrow;
    }
  }

  /// Đăng xuất - Xóa tất cả dữ liệu authentication
  Future<void> logout() async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🚪 [AUTH] Đang đăng xuất...');
    }

    await _localStorage.remove('auth_token');
    await _localStorage.remove('user_data');
    await _localStorage.remove('is_logged_in');
    await _localStorage.remove('login_time');

    if (AppConfig.enableApiLogging) {
      AppLogger.info('✅ [AUTH] Đã đăng xuất thành công');
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
