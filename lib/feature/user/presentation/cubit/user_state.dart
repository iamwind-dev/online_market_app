import 'package:equatable/equatable.dart';

/// State cho User/Account Screen
class UserState extends Equatable {
  final String userName;
  final String userImage;
  final int pendingOrders;
  final int processingOrders;
  final int shippingOrders;
  final int completedOrders;
  final bool isLoading;
  final String? errorMessage;
  final bool requiresLogin;

  const UserState({
    this.userName = '',
    this.userImage = '',
    this.pendingOrders = 0,
    this.processingOrders = 0,
    this.shippingOrders = 0,
    this.completedOrders = 0,
    this.isLoading = false,
    this.errorMessage,
    this.requiresLogin = false,
  });

  UserState copyWith({
    String? userName,
    String? userImage,
    int? pendingOrders,
    int? processingOrders,
    int? shippingOrders,
    int? completedOrders,
    bool? isLoading,
    String? errorMessage,
    bool? requiresLogin,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      processingOrders: processingOrders ?? this.processingOrders,
      shippingOrders: shippingOrders ?? this.shippingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      requiresLogin: requiresLogin ?? this.requiresLogin,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        userImage,
        pendingOrders,
        processingOrders,
        shippingOrders,
        completedOrders,
        isLoading,
        errorMessage,
        requiresLogin,
      ];
}
