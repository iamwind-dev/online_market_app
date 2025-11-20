import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/order_detail_cubit.dart';
import '../../../../../core/theme/app_colors.dart';

/// Màn hình chi tiết đơn hàng
/// 
/// Chức năng:
/// - Hiển thị chi tiết đơn hàng
/// - Hiển thị trạng thái đơn hàng
/// - Hiển thị thông tin giao hàng
/// - Hủy đơn hàng
/// - Đặt lại đơn hàng
/// - Đánh giá đơn hàng
class OrderDetailPage extends StatelessWidget {
  final String? orderId;

  const OrderDetailPage({
    super.key,
    this.orderId,
  });

  static const String routeName = '/order-detail';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderDetailCubit()..loadOrderDetail(orderId ?? 'ORD001'),
      child: const OrderDetailView(),
    );
  }
}

/// View của màn hình chi tiết đơn hàng
class OrderDetailView extends StatefulWidget {
  const OrderDetailView({super.key});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailCubit, OrderDetailState>(
      listener: (context, state) {
        if (state is OrderDetailCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is OrderDetailReordered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to new order or cart
        } else if (state is OrderDetailFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Content
              Expanded(
                child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
                  builder: (context, state) {
                    if (state is OrderDetailLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is OrderDetailLoaded) {
                      return _buildContent(context, state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              
              // Bottom navigation
              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background image
        
        // Content
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 36),
              
              // Title row with back button
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/img/back.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  const Text(
                    'Chi tiết đơn hàng',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.1,
                      color: Color(0xFF000000),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Placeholder to balance
                  const SizedBox(width: 16),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Order ID row
              BlocBuilder<OrderDetailCubit, OrderDetailState>(
                builder: (context, state) {
                  if (state is OrderDetailLoaded) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mã đơn hàng:   ',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 17,
                            height: 1.29,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Text(
                          state.orderDetail.orderNumber,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 17,
                            height: 1.29,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Content
  Widget _buildContent(BuildContext context, OrderDetailLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Shop info section
          _buildShopInfoSection(state.orderDetail),
          
          const SizedBox(height: 27),
          
          // Order summary section
          _buildOrderSummarySection(state.orderDetail),
          
          const SizedBox(height: 22),
          
          // Review button (if delivered)
          if (state.orderDetail.status.canReview)
            _buildReviewButton(context),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Shop info section
  Widget _buildShopInfoSection(OrderDetail orderDetail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop header
          Row(
            children: [
              // Shop avatar
              Container(
                width: 48,
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F8000),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  orderDetail.shopAvatar,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 0.73,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(width: 17),
              
              // Shop info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop name with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F8000).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.store,
                            size: 14,
                            color: Color(0xFF2F8000),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            orderDetail.shopName,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 1.1,
                              color: Color(0xFF202020),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(orderDetail.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(orderDetail.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        orderDetail.status.displayName,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _getStatusColor(orderDetail.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 23),
          
          // Pickup address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/img/order_location_from.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  orderDetail.pickupAddress,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.375,
                    color: Color(0xFF202020),
                  ),
                ),
              ),
            ],
          ),
          
          // Divider line
          Container(
            margin: const EdgeInsets.only(left: 15, top: 6, bottom: 6),
            width: 0,
            height: 31,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFF000000),
                  width: 1,
                ),
              ),
            ),
          ),
          
          // Delivery address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/img/order_location_to.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  orderDetail.deliveryAddress,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.375,
                    color: Color(0xFF202020),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Order summary section
  Widget _buildOrderSummarySection(OrderDetail orderDetail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
              color: Color(0xFF202020),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Items list
          ...orderDetail.items.map((item) => _buildOrderItem(item)),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
          
          const SizedBox(height: 12),
          
          // Subtotal
          _buildSummaryRow('Tổng tạm tính', orderDetail.subtotal),
          
          const SizedBox(height: 11),
          
          // Shipping fee
          _buildSummaryRow('Phí áp dụng', orderDetail.shippingFee),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
          
          const SizedBox(height: 12),
          
          // Total
          _buildSummaryRow('Tổng cộng', orderDetail.total, isBold: true),
        ],
      ),
    );
  }

  /// Order item
  Widget _buildOrderItem(OrderDetailItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Weight badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2F8000).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item.weight}${item.unit}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF2F8000),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product name
          Expanded(
            child: Text(
              item.productName,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF202020),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Price
          Text(
            '${_formatPrice(item.totalPrice)}đ',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF202020),
            ),
          ),
        ],
      ),
    );
  }

  /// Summary row
  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    if (isBold) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF202020),
              ),
            ),
            Text(
              '${_formatPrice(amount)}đ',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF2F8000),
              ),
            ),
          ],
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          '${_formatPrice(amount)}đ',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF202020),
          ),
        ),
      ],
    );
  }

  /// Get status color
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFFA500);
      case OrderStatus.confirmed:
        return const Color(0xFF4CAF50);
      case OrderStatus.processing:
        return const Color(0xFF2196F3);
      case OrderStatus.shipping:
        return const Color(0xFF9C27B0);
      case OrderStatus.delivered:
        return const Color(0xFF2F8000);
      case OrderStatus.cancelled:
        return const Color(0xFFFF0000);
      case OrderStatus.returned:
        return const Color(0xFF795548);
    }
  }

  /// Review button
  Widget _buildReviewButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to review page
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2F8000),
                Color(0xFF267000),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F8000).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rate,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Đánh giá',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('assets/img/add_home.svg', 'Trang chủ'),
          _buildNavItem('assets/img/mon_an_icon.png', 'Món ăn', isImage: true),
          _buildNavItem('assets/img/user_personas_presentation-26cd3a.png', '', isImage: true, isCenter: true),
          _buildNavItem('assets/img/wifi_notification.svg', 'Thông báo'),
          _buildNavItem('assets/img/account_circle.svg', 'Tài khoản'),
        ],
      ),
    );
  }

  /// Navigation item
  Widget _buildNavItem(String icon, String label, {bool isImage = false, bool isCenter = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isCenter)
          Container(
            width: 58,
            height: 67,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(icon),
                fit: BoxFit.cover,
              ),
            ),
          )
        else ...[
          isImage
              ? Image.asset(
                  icon,
                  width: 30,
                  height: 30,
                )
              : SvgPicture.asset(
                  icon,
                  width: 30,
                  height: 30,
                ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.33,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// Format price helper
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
