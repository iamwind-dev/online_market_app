import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class SellerHomeCubit extends Cubit<SellerHomeState> {
  SellerHomeCubit() : super(SellerHomeState.initial());

  /// Khởi tạo và load dữ liệu trang chủ người bán
  Future<void> initializeHome() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      emit(state.copyWith(
        isLoading: false,
        shopName: 'PHƯƠNG NHI',
        dailyOverview: const DailyOverview(
          revenue: 116000,
          orderCount: 3,
        ),
        productInfo: const ProductInfo(
          totalProducts: 34,
          activeProducts: 34,
          lowStockCount: 8,
        ),
        analyticsInfo: const AnalyticsInfo(
          totalRevenue: 1350000,
          totalOrders: 50,
          period: '7 ngày gần đây',
        ),
        financeInfo: const FinanceInfo(
          holdingAmount: 120000,
          holdingDays: 1,
          paidAmount: 350000,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu: ${e.toString()}',
      ));
    }
  }

  /// Chuyển tab bottom navigation
  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  /// Điều hướng đến trang chi tiết doanh thu
  void navigateToRevenue() {
    // TODO: Implement navigation
  }

  /// Điều hướng đến trang chi tiết đơn hàng
  void navigateToOrders() {
    // TODO: Implement navigation
  }

  /// Điều hướng đến trang sản phẩm
  void navigateToProducts() {
    // TODO: Implement navigation
  }

  /// Điều hướng đến trang thêm sản phẩm
  void navigateToAddProduct() {
    // TODO: Implement navigation
  }

  /// Điều hướng đến trang phân tích chi tiết
  void navigateToAnalytics() {
    // TODO: Implement navigation
  }

  /// Điều hướng đến trang tài chính
  void navigateToFinance() {
    // TODO: Implement navigation
  }

  /// Toggle trạng thái cửa hàng (mở/đóng)
  void toggleStoreStatus() {
    emit(state.copyWith(isStoreOpen: !state.isStoreOpen));
  }

  /// Refresh dữ liệu
  Future<void> refreshData() async {
    await initializeHome();
  }

  /// Format số tiền thành chuỗi hiển thị
  String formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatted đồng';
  }
}
