import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerHomeCubit()..initializeHome(),
      child: const _SellerHomeView(),
    );
  }
}

class _SellerHomeView extends StatelessWidget {
  const _SellerHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SellerHomeCubit, SellerHomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SellerHomeCubit>().refreshData(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SellerHomeCubit>().refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, state),
                  const SizedBox(height: 8),
                  _buildDailyOverviewCard(context, state),
                  const SizedBox(height: 16),
                  _buildProductCard(context, state),
                  const SizedBox(height: 16),
                  _buildAnalyticsCard(context, state),
                  const SizedBox(height: 16),
                  _buildFinanceCard(context, state),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SellerHomeCubit, SellerHomeState>(
        builder: (context, state) {
          return _buildBottomNavigation(context, state);
        },
      ),
    );
  }

  /// Header với tên gian hàng
  Widget _buildHeader(BuildContext context, SellerHomeState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          'GIAN HÀNG: ${state.shopName}',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Card Tổng quan hằng ngày
  Widget _buildDailyOverviewCard(BuildContext context, SellerHomeState state) {
    final cubit = context.read<SellerHomeCubit>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFFF7),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề với icon và nút mở rộng
          Row(
            children: [
              Image.asset(
                'assets/img/seller_home_analysis_icon.png',
                width: 21,
                height: 19,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.attach_money, size: 21, color: Color(0xFF00B40F));
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Tổng quan hằng ngày',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => cubit.navigateToRevenue(),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                  color: Color(0xFF1C1B1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Doanh thu và Đơn hàng
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Doanh thu',
                      style: TextStyle(
                        fontFamily: 'Varta',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cubit.formatCurrency(state.dailyOverview.revenue),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0F0F0F),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đơn hàng',
                      style: TextStyle(
                        fontFamily: 'Varta',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.dailyOverview.orderCount}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0F0F0F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card Sản phẩm
  Widget _buildProductCard(BuildContext context, SellerHomeState state) {
    final cubit = context.read<SellerHomeCubit>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFFF7),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF9E4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.shopping_basket, size: 18, color: Color(0xFF00B40F)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Sản phẩm',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => cubit.navigateToProducts(),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                  color: Color(0xFF1C1B1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Số lượng và trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.productInfo.totalProducts} ',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF0F0F0F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      fontFamily: 'Varta',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Avatar sản phẩm
              Container(
                width: 31,
                height: 31,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
              ),
              // Nút thêm sản phẩm
              GestureDetector(
                onTap: () => cubit.navigateToAddProduct(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B40F),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Thêm sản phẩm',
                    style: TextStyle(
                      fontFamily: 'Varta',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card Phân tích
  Widget _buildAnalyticsCard(BuildContext context, SellerHomeState state) {
    final cubit = context.read<SellerHomeCubit>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFFF7),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Row(
                  children: [
                    Image.asset(
                      'assets/img/seller_home_analysis_icon.png',
                      width: 24,
                      height: 26,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.analytics, size: 24, color: Color(0xFF00B40F));
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Phân tích',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    // Bộ lọc 7 ngày
                    GestureDetector(
                      onTap: () => cubit.navigateToAnalytics(),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            state.analyticsInfo.period,
                            style: const TextStyle(
                              fontFamily: 'Varta',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Doanh thu và Đơn hàng nhỏ
                Row(
                  children: [
                    // Doanh thu
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/img/seller_home_order_icon.png',
                            width: 12,
                            height: 11,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 12,
                                height: 11,
                                color: Colors.grey,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Doanh thu',
                            style: TextStyle(
                              fontFamily: 'Varta',
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cubit.formatCurrency(state.analyticsInfo.totalRevenue),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF0F0F0F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Đơn hàng
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/img/seller_home_order_icon.png',
                            width: 12,
                            height: 11,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 12,
                                height: 11,
                                color: Colors.grey,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Đơn hàng',
                            style: TextStyle(
                              fontFamily: 'Varta',
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.analyticsInfo.totalOrders} đơn',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF0F0F0F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Biểu đồ
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
            child: Image.asset(
              'assets/img/seller_home_chart.png',
              width: double.infinity,
              height: 108,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 108,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.show_chart, size: 40, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Card Tài chính
  Widget _buildFinanceCard(BuildContext context, SellerHomeState state) {
    final cubit = context.read<SellerHomeCubit>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFFF7),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, size: 16, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Tài chính',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => cubit.navigateToFinance(),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                  color: Color(0xFF1C1B1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Giữ tiền
          Text(
            'Giữ tiền ${state.financeInfo.holdingDays} ngày',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Đang giữ và Đã thanh toán
          Row(
            children: [
              // Đang giữ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF9E4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Đang giữ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cubit.formatCurrency(state.financeInfo.holdingAmount),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0F0F0F),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider dọc
              Container(
                width: 1,
                height: 60,
                color: const Color(0xFFD9D9D9),
              ),
              const SizedBox(width: 16),
              // Đã thanh toán
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF9E4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Đã thanh toán',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cubit.formatCurrency(state.financeInfo.paidAmount),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0F0F0F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigation(BuildContext context, SellerHomeState state) {
    final cubit = context.read<SellerHomeCubit>();

    return Container(
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Đơn hàng
          _buildNavItem(
            context,
            icon: Icons.receipt_long,
            label: 'Đơn hàng',
            isSelected: state.currentTabIndex == 0,
            onTap: () => cubit.changeTab(0),
          ),
          // Sản phẩm
          _buildNavItem(
            context,
            icon: Icons.shopping_bag,
            label: 'Sản phẩm',
            isSelected: state.currentTabIndex == 1,
            onTap: () => cubit.changeTab(1),
          ),
          // Avatar (Home)
          GestureDetector(
            onTap: () => cubit.changeTab(2),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.currentTabIndex == 2 ? const Color(0xFF00B40F) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/img/seller_home_avatar.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 58,
                      height: 58,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 30),
                    );
                  },
                ),
              ),
            ),
          ),
          // Doanh số
          _buildNavItem(
            context,
            icon: Icons.attach_money,
            label: 'Doanh số',
            isSelected: state.currentTabIndex == 3,
            onTap: () => cubit.changeTab(3),
          ),
          // Tài khoản
          _buildNavItem(
            context,
            icon: Icons.account_circle,
            label: 'Tài khoản',
            isSelected: state.currentTabIndex == 4,
            onTap: () => cubit.changeTab(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF00B40F) : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: isSelected ? const Color(0xFF00B40F) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
