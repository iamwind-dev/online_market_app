import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';

class SellerOrderScreen extends StatelessWidget {
  const SellerOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerOrderCubit()..loadOrders(),
      child: const SellerOrderView(),
    );
  }
}

class SellerOrderView extends StatelessWidget {
  const SellerOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<SellerOrderCubit, SellerOrderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SellerOrderCubit>().loadOrders();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildOrderList(context, state),
                ),
                _buildBottomNavigation(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SellerOrderState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng của tôi',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, size: 28),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, size: 28),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tổng hôm nay: ${_formatCurrency(state.totalToday)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusTabs(),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Row(
      children: [
        _buildStatusTab('Chờ xác nhận', const Color(0xFFD7FFBD), Icons.repeat, const Color(0xFFBF6A02)),
        const SizedBox(width: 8),
        _buildStatusTab('Đang giao', Colors.grey.shade300, Icons.local_shipping, const Color(0xFFEC221F)),
        const SizedBox(width: 8),
        _buildStatusTab('Hoàn tất', Colors.grey.shade300, Icons.check_circle, const Color(0xFF009951)),
      ],
    );
  }

  Widget _buildStatusTab(String label, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202020),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, SellerOrderState state) {
    return RefreshIndicator(
      onRefresh: () => context.read<SellerOrderCubit>().loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, SellerOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202020),
                  ),
                ),
                Text(
                  order.orderTime,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202020),
                  ),
                ),
                Text(
                  _formatCurrency(order.amount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.items,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF202020),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    order,
                    isConfirmButton: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    order,
                    isConfirmButton: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, SellerOrder order, {required bool isConfirmButton}) {
    final cubit = context.read<SellerOrderCubit>();

    if (isConfirmButton) {
      String label;
      Color bgColor;
      Color textColor;
      IconData? icon;

      switch (order.status) {
        case OrderStatus.pending:
          label = 'Xác nhận';
          bgColor = const Color(0xFF21A036);
          textColor = Colors.white;
          icon = null;
          break;
        case OrderStatus.delivering:
          label = 'Xác nhận';
          bgColor = const Color(0xFF21A036);
          textColor = Colors.white;
          icon = null;
          break;
        case OrderStatus.completed:
          label = 'Xác nhận';
          bgColor = const Color(0xFF21A036);
          textColor = Colors.white;
          icon = null;
          break;
      }

      return ElevatedButton(
        onPressed: order.status == OrderStatus.pending
            ? () => cubit.confirmOrder(order.id)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          disabledBackgroundColor: bgColor.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: () => cubit.contactCustomer(order.id),
        icon: const Icon(Icons.phone, size: 18, color: Colors.black),
        label: const Text(
          'Liên hệ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: BorderSide.none,
          backgroundColor: const Color(0xFFD9D9D9),
        ),
      );
    }
  }

  Widget _buildBottomNavigation(BuildContext context, SellerOrderState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.receipt_outlined,
            label: 'Đơn hàng',
            isSelected: true,
            onTap: () {},
          ),
          _buildNavItem(
            context,
            icon: Icons.card_giftcard,
            label: 'Sản phẩm',
            isSelected: false,
            onTap: () => context.read<SellerOrderCubit>().navigateToIngredient(),
          ),
          _buildNavItemWithAvatar(context),
          _buildNavItem(
            context,
            icon: Icons.attach_money,
            label: 'Doanh số',
            isSelected: false,
            onTap: () => context.read<SellerOrderCubit>().navigateToAnalytics(),
          ),
          _buildNavItem(
            context,
            icon: Icons.account_circle_outlined,
            label: 'Tài khoản',
            isSelected: false,
            onTap: () => context.read<SellerOrderCubit>().navigateToAccount(),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF21A036) : Colors.black,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF21A036) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<SellerOrderCubit>().navigateToHome(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/img/seller_home_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 32);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }
}
