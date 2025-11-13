import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_market_app/feature/user/presentation/cubit/user_state.dart';

/// Cubit quản lý state cho User/Account Screen
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  /// Load thông tin user
  void loadUserData({
    String? userName,
    String? userImage,
    int? pendingOrders,
    int? processingOrders,
    int? shippingOrders,
    int? completedOrders,
  }) {
    emit(state.copyWith(isLoading: true));

    // Simulate loading data - in real app, this would fetch from API/repository
    emit(state.copyWith(
      userName: userName ?? 'Lê Thị Tuyết',
      userImage: userImage ?? 'assets/img/user_profile_image.png',
      pendingOrders: pendingOrders ?? 1,
      processingOrders: processingOrders ?? 0,
      shippingOrders: shippingOrders ?? 3,
      completedOrders: completedOrders ?? 1,
      isLoading: false,
    ));
  }

  /// Navigate to Favorites screen
  void navigateToFavorites() {
    // Navigation will be handled by screen
  }

  /// Navigate to MCard screen
  void navigateToMCard() {
    // Navigation will be handled by screen
  }

  /// Navigate to Terms of Service
  void navigateToTermsOfService() {
    // Navigation will be handled by screen
  }

  /// Navigate to Language settings
  void navigateToLanguage() {
    // Navigation will be handled by screen
  }

  /// Navigate to Customer Care
  void navigateToCustomerCare() {
    // Navigation will be handled by screen
  }

  /// Navigate to Support
  void navigateToSupport() {
    // Navigation will be handled by screen
  }

  /// Delete account
  void deleteAccount() {
    // Implement delete account logic
  }

  /// Logout
  void logout() {
    // Implement logout logic
    emit(const UserState());
  }

  /// Navigate to order status screen
  void navigateToOrders(String status) {
    // Navigation will be handled by screen
    // status can be: pending, processing, shipping, completed
  }

  /// Navigate to settings
  void navigateToSettings() {
    // Navigation will be handled by screen
  }

  /// Navigate to edit profile
  void navigateToEditProfile() {
    // Navigation will be handled by screen
  }

  /// Navigate to cart
  void navigateToCart() {
    // Navigation will be handled by screen
  }
}
