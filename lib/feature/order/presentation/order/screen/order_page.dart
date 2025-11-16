import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../cubit/order_cubit.dart';
import '../../order_detail/screen/order_detail_page.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is OrderLoaded) {
                    return _buildContent(context, state);
                  }

                  if (state is OrderFailure) {
                    return Center(
                      child: Text(state.errorMessage),
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
  

  /// Content
  Widget _buildContent(BuildContext context, OrderLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          
          // "Đơn hàng của tôi" title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Đơn hàng của tôi',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 1.1,
                color: Color(0xFF202020),
              ),
            ),
          ),
          
          const SizedBox(height: 19),
          
          // Status filter tabs
          _buildStatusTabs(context, state),
          
          const SizedBox(height: 11),
          
          // Recent orders section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Gần đây',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 1.1,
                color: Color(0xFF202020),
              ),
            ),
          ),
          
          const SizedBox(height: 17),
          
          // Orders list
          ...state.orders.map((order) => _buildOrderCard(context, order)),
          
          const SizedBox(height: 16),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD7FFBD).withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(color: const Color(0xFF2CCE75), width: 2)
                : null,
          ),
          child: Column(
            children: [
              // Count
              Text(
                count,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  height: 0.73,
                  color: Color(0xFF292D32),
                ),
              ),
              
              const SizedBox(height: 5),
              
              // Label
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.25,
                  letterSpacing: -0.16,
                  color: Color(0xFF2CCE75),
                ),
                textAlign: TextAlign.center,
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD7FFBD).withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop name and expand button
            Row(
              children: [
                // Shop image (first item)
                if (order.items.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      order.items.first.productImage,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                // Date and Shop name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        _formatDateTime(order.orderDate),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                          height: 1.29,
                          color: Color(0xFF202020),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Shop name
                      Text(
                        order.shopName,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          height: 1.29,
                          color: Color(0xFF202020),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Expand/collapse button
                GestureDetector(
                  onTap: () {
                    context.read<OrderCubit>().toggleOrderExpansion(order.orderId);
                  },
                  child: Transform.rotate(
                    angle: isExpanded ? 3.14159 : 0,
                    child: SvgPicture.asset(
                      'assets/img/order_down_chevron.svg',
                      width: 15,
                      height: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Items list (show first item or all if expanded)
            ...order.items
                .take(isExpanded ? order.items.length : 1)
                .map((item) => _buildOrderItemRow(item)),
            
            if (!isExpanded && order.items.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '... và ${order.items.length - 1} sản phẩm khác',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Tổng: ',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    height: 1.29,
                    color: Color(0xFF202020),
                  ),
                ),
                Text(
                  _formatPrice(order.totalAmount),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    height: 1.29,
                    color: Color(0xFF202020),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Weight
          SizedBox(
            width: 60,
            child: Text(
              '${item.weight}${item.unit}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 1.375,
                color: Color(0xFF202020),
              ),
            ),
          ),
          
          // Product name
          Expanded(
            child: Text(
              item.productName,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.29,
                color: Color(0xFF202020),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Price
          Text(
            _formatPrice(item.totalPrice),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 17,
              height: 1.29,
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
