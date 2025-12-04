import 'package:equatable/equatable.dart';

/// Model đại diện cho thông tin người bán
class SellerInfo extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String bankName;
  final String accountNumber;
  final String marketName;
  final String stallNumber;
  final List<String> categories;
  final String avatarUrl;

  const SellerInfo({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.bankName,
    required this.accountNumber,
    required this.marketName,
    required this.stallNumber,
    required this.categories,
    required this.avatarUrl,
  });

  /// Format danh mục hiển thị
  String get categoriesDisplay {
    return categories.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        bankName,
        accountNumber,
        marketName,
        stallNumber,
        categories,
        avatarUrl,
      ];
}

/// State chính của Seller User
class SellerUserState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final SellerInfo? sellerInfo;
  final int currentTabIndex;

  const SellerUserState({
    this.isLoading = false,
    this.errorMessage,
    this.sellerInfo,
    this.currentTabIndex = 4, // Tab Tài khoản mặc định
  });

  /// Factory tạo state ban đầu
  factory SellerUserState.initial() {
    return const SellerUserState(isLoading: true);
  }

  SellerUserState copyWith({
    bool? isLoading,
    String? errorMessage,
    SellerInfo? sellerInfo,
    int? currentTabIndex,
  }) {
    return SellerUserState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sellerInfo: sellerInfo ?? this.sellerInfo,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        sellerInfo,
        currentTabIndex,
      ];
}
