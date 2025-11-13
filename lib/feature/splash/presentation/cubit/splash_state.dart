part of 'splash_cubit.dart';

/// Base class cho tất cả các state của Splash
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// State khởi tạo ban đầu
class SplashInitial extends SplashState {}

/// State đang tải dữ liệu
class SplashLoading extends SplashState {}

/// State người dùng đã đăng nhập
/// 
/// Sau state này, ứng dụng sẽ điều hướng đến màn hình Home
class SplashAuthenticated extends SplashState {}

/// State người dùng chưa đăng nhập
/// 
/// Sau state này, ứng dụng sẽ điều hướng đến màn hình Onboarding hoặc Login
class SplashUnauthenticated extends SplashState {}

/// State xảy ra lỗi trong quá trình khởi tạo
class SplashError extends SplashState {
  final String message;

  const SplashError({required this.message});

  @override
  List<Object?> get props => [message];
}
