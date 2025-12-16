import 'package:equatable/equatable.dart';

/// Model đại diện cho thông tin tài chính người bán
class FinanceInfo extends Equatable {
  final double holdingAmount;
  final int holdingDays;
  final double paidAmount;

  const FinanceInfo({
    required this.holdingAmount,
    required this.holdingDays,
    required this.paidAmount,
  });

  @override
  List<Object?> get props => [holdingAmount, holdingDays, paidAmount];
}

/// Model đại diện cho tổng quan hằng ngày
class DailyOverview extends Equatable {
  final double revenue;
  final int orderCount;

  const DailyOverview({
    required this.revenue,
    required this.orderCount,
  });

  @override
  List<Object?> get props => [revenue, orderCount];
}

/// Model đại diện cho thông tin sản phẩm
class ProductInfo extends Equatable {
  final int totalProducts;
  final int activeProducts;
  final int lowStockCount;

  const ProductInfo({
    required this.totalProducts,
    required this.activeProducts,
    this.lowStockCount = 0,
  });

  @override
  List<Object?> get props => [totalProducts, activeProducts, lowStockCount];
}

/// Model đại diện cho phân tích 7 ngày gần đây
class AnalyticsInfo extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final String period;

  const AnalyticsInfo({
    required this.totalRevenue,
    required this.totalOrders,
    required this.period,
  });

  @override
  List<Object?> get props => [totalRevenue, totalOrders, period];
}

/// State chính của Seller Home
class SellerHomeState extends Equatable {
  final String shopName;
  final bool isLoading;
  final String? errorMessage;
  final DailyOverview dailyOverview;
  final ProductInfo productInfo;
  final AnalyticsInfo analyticsInfo;
  final FinanceInfo financeInfo;
  final int currentTabIndex;
  final bool isStoreOpen;

  const SellerHomeState({
    required this.shopName,
    this.isLoading = false,
    this.errorMessage,
    required this.dailyOverview,
    required this.productInfo,
    required this.analyticsInfo,
    required this.financeInfo,
    this.currentTabIndex = 0,
    this.isStoreOpen = true,
  });

  /// Factory tạo state ban đầu
  factory SellerHomeState.initial() {
    return const SellerHomeState(
      shopName: 'PHƯƠNG NHI',
      isLoading: true,
      dailyOverview: DailyOverview(revenue: 0, orderCount: 0),
      productInfo: const ProductInfo(totalProducts: 0, activeProducts: 0, lowStockCount: 0),
      analyticsInfo: AnalyticsInfo(
        totalRevenue: 0,
        totalOrders: 0,
        period: '7 ngày gần đây',
      ),
      financeInfo: FinanceInfo(
        holdingAmount: 0,
        holdingDays: 0,
        paidAmount: 0,
      ),
    );
  }

  SellerHomeState copyWith({
    String? shopName,
    bool? isLoading,
    String? errorMessage,
    DailyOverview? dailyOverview,
    ProductInfo? productInfo,
    AnalyticsInfo? analyticsInfo,
    FinanceInfo? financeInfo,
    int? currentTabIndex,
    bool? isStoreOpen,
  }) {
    return SellerHomeState(
      shopName: shopName ?? this.shopName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dailyOverview: dailyOverview ?? this.dailyOverview,
      productInfo: productInfo ?? this.productInfo,
      analyticsInfo: analyticsInfo ?? this.analyticsInfo,
      financeInfo: financeInfo ?? this.financeInfo,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isStoreOpen: isStoreOpen ?? this.isStoreOpen,
    );
  }

  @override
  List<Object?> get props => [
        shopName,
        isLoading,
        errorMessage,
        dailyOverview,
        productInfo,
        analyticsInfo,
        financeInfo,
        currentTabIndex,
        isStoreOpen,
      ];
}
