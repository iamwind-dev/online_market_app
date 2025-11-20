import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../cubit/order_cubit.dart';
import '../../order_detail/screen/order_detail_page.dart';
import '../../../../../core/theme/app_colors.dart';

/// Màn hình đơn hàng
/// 
/// Chức năng:
/// - Hiển thị danh sách đơn hàng
/// - Lọc đơn hàng theo trạng thái
/// - Xem chi tiết đơn hàng
/// - Quản lý thông tin người dùng
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  static const String routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderCubit()..loadOrders(),
      child: const OrderView(),
    );
  }
}

/// View của màn hình đơn hàng
class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B40F),
                      ),
                    );
                  }

                  if (state is OrderLoaded) {
                    return _buildContent(context, state);
                  }

                  if (state is OrderFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Color(0xFFFF0000),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    );
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
    );
  }

  /// Header
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00B40F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Color(0xFF00B40F),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Đơn hàng của tôi',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }

  /// Header
  

  /// Content
  Widget _buildContent(BuildContext context, OrderLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Status filter tabs
          _buildStatusTabs(context, state),
          
          const SizedBox(height: 20),
          
          // Recent orders section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B40F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF00B40F),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Gần đây',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Orders list
          if (state.orders.isEmpty)
            _buildEmptyState()
          else
            ...state.orders.map((order) => _buildOrderCard(context, order)),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Status filter tabs
  Widget _buildStatusTabs(BuildContext context, OrderLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildStatusTab(
            context,
            'Chờ Xác Nhận',
            state.pendingCount.toString(),
            OrderFilterType.pending,
            state.filterType == OrderFilterType.pending,
          ),
          const SizedBox(width: 7),
          _buildStatusTab(
            context,
            'Đang Xử Lý',
            '0',
            OrderFilterType.processing,
            state.filterType == OrderFilterType.processing,
          ),
          const SizedBox(width: 7),
          _buildStatusTab(
            context,
            'Đang Giao',
            state.shippingCount.toString(),
            OrderFilterType.shipping,
            state.filterType == OrderFilterType.shipping,
          ),
          const SizedBox(width: 7),
          _buildStatusTab(
            context,
            'Giao Thành Công',
            state.deliveredCount.toString(),
            OrderFilterType.delivered,
            state.filterType == OrderFilterType.delivered,
          ),
        ],
      ),
    );
  }

  /// Status tab
  Widget _buildStatusTab(
    BuildContext context,
    String label,
    String count,
    OrderFilterType filterType,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<OrderCubit>().filterOrders(filterType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      const Color(0xFF00B40F).withValues(alpha: 0.15),
                      const Color(0xFF00B40F).withValues(alpha: 0.08),
                    ]
                  : [
                      AppColors.getCardBackground(),
                      AppColors.getCardBackground(alpha: 0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00B40F)
                  : Colors.black.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00B40F).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Count
              Text(
                count,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: isSelected ? const Color(0xFF00B40F) : const Color(0xFF292D32),
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Label
              SizedBox(
                height: 28,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: -0.16,
                      color: isSelected ? const Color(0xFF00B40F) : const Color(0xFF2CCE75),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Order card
  Widget _buildOrderCard(BuildContext context, Order order) {
    final isExpanded = order.isExpanded;
    
    return GestureDetector(
      onTap: () {
        // Navigate to order detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: order.orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(),
          borderRadius: BorderRadius.circular(16),
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
            // Shop name and expand button
            Row(
              children: [
                // Shop image (first item)
                if (order.items.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        order.items.first.productImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 12),
                
                // Date and Shop name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date with icon
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(order.orderDate),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Shop name with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B40F).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.store,
                              size: 12,
                              color: Color(0xFF00B40F),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.shopName,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF202020),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Expand/collapse button
                GestureDetector(
                  onTap: () {
                    context.read<OrderCubit>().toggleOrderExpansion(order.orderId);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Transform.rotate(
                      angle: isExpanded ? 3.14159 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Divider
            Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.08),
            ),
            
            const SizedBox(height: 12),
            
            // Items list (show first item or all if expanded)
            ...order.items
                .take(isExpanded ? order.items.length : 1)
                .map((item) => _buildOrderItemRow(item)),
            
            if (!isExpanded && order.items.length > 1)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+ ${order.items.length - 1} sản phẩm khác',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Divider
            Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.08),
            ),
            
            const SizedBox(height: 12),
            
            const SizedBox(height: 12),
            
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                Text(
                  '${_formatPrice(order.totalAmount)}đ',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF00B40F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Order item row
  Widget _buildOrderItemRow(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              color: const Color(0xFF00B40F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item.weight}${item.unit}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF00B40F),
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

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
  }
}
