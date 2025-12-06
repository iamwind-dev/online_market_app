import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/auth/simple_auth_helper.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/dependency/injection.dart';

part 'splash_state.dart';

/// Kết quả kiểm tra authentication
class AuthCheckResult {
  final bool isAuthenticated;
  final String? role; // nguoi_mua hoặc nguoi_ban

  AuthCheckResult({required this.isAuthenticated, this.role});
}

/// Splash Cubit quản lý logic nghiệp vụ của màn hình Splash
/// 
/// Chức năng chính:
/// - Kiểm tra trạng thái đăng nhập
/// - Kiểm tra phiên bản ứng dụng
/// - Tải dữ liệu cấu hình ban đầu
/// - Điều hướng đến màn hình phù hợp sau khi hoàn tất
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  /// Khởi tạo ứng dụng
  /// 
  /// Quy trình:
  /// 1. Hiển thị logo và animation (2-3 giây)
  /// 2. Kiểm tra trạng thái đăng nhập
  /// 3. Tải cấu hình và dữ liệu cơ bản
  /// 4. Chuyển đến màn hình phù hợp
  Future<void> initialize() async {
    try {
      emit(SplashLoading());

      // Simulate loading time (minimum 2 seconds for better UX)
      await Future.delayed(const Duration(seconds: 2));

      // Check if cubit is still open before continuing
      if (isClosed) return;

      // TODO: Implement actual initialization logic
      // - Check authentication status
      // - Load user preferences
      // - Initialize services
      // - Check app version
      // - Load initial data

      // Check authentication and role
      final authResult = await _checkAuthenticationAndRole();

      // Check again if cubit is still open before emitting final state
      if (!isClosed) {
        if (authResult.isAuthenticated && authResult.role != null) {
          // Đã đăng nhập với vai trò hợp lệ (nguoi_mua hoặc nguoi_ban)
          debugPrint('[SPLASH] 🚀 Emitting SplashAuthenticated with role: ${authResult.role}');
          emit(SplashAuthenticated(role: authResult.role!));
        } else {
          // Chưa đăng nhập
          debugPrint('[SPLASH] 🚀 Emitting SplashUnauthenticated');
          emit(SplashUnauthenticated());
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(SplashError(message: e.toString()));
      }
    }
  }

  /// Kiểm tra trạng thái đăng nhập và vai trò người dùng
  Future<AuthCheckResult> _checkAuthenticationAndRole() async {
    try {
      // Check if user is logged in using simple_auth_helper
      final loggedIn = await isLoggedIn();
      
      if (!loggedIn) {
        print('[SPLASH] ℹ️ User is not logged in');
        await _loadAppConfiguration();
        await _checkAppVersion();
        return AuthCheckResult(isAuthenticated: false);
      }
      
      // User is logged in, verify token is still valid
      final userData = await getUserData();
      print('[SPLASH] ✅ User is logged in: ${userData?['ten_dang_nhap']}');
      
      // Check if token is expired
      final authService = getIt<AuthService>();
      final isTokenExpired = await authService.isTokenExpired();
      
      if (isTokenExpired) {
        print('[SPLASH] ⏰ Token has expired, clearing auth data');
        await authService.logout();
        await _loadAppConfiguration();
        await _checkAppVersion();
        return AuthCheckResult(isAuthenticated: false);
      }
      
      // Check user role - cho phép nguoi_mua và nguoi_ban
      final vaiTro = userData?['vai_tro'] as String?;
      print('[SPLASH] 👤 User role: $vaiTro');
      
      if (vaiTro != 'nguoi_mua' && vaiTro != 'nguoi_ban') {
        print('[SPLASH] ⚠️ Invalid role: $vaiTro (expected: nguoi_mua or nguoi_ban)');
        // Logout user với vai trò không hợp lệ
        await authService.logout();
        return AuthCheckResult(isAuthenticated: false);
      }
      
      // Token is still valid and role is correct
      print('[SPLASH] ✅ Token is valid and role is $vaiTro');
      await _loadAppConfiguration();
      await _checkAppVersion();
      return AuthCheckResult(isAuthenticated: true, role: vaiTro);
    } catch (e) {
      print('[SPLASH] ❌ Error checking authentication: $e');
      return AuthCheckResult(isAuthenticated: false);
    }
  }

  /// Tải cấu hình ứng dụng
  Future<void> _loadAppConfiguration() async {
    // TODO: Implement configuration loading
    // - Load from local storage
    // - Fetch from remote config if needed
    // - Apply theme settings
    // - Set language preferences
  }

  /// Kiểm tra phiên bản ứng dụng
  Future<void> _checkAppVersion() async {
    // TODO: Implement version checking
    // - Compare local version with server version
    // - Show update dialog if needed
    // - Handle force update scenario
  }
}
