import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/payment_cubit.dart';
import '../../../../core/config/route_name.dart';
import '../../../../core/theme/app_colors.dart';

/// Màn hình thanh toán
/// 
/// Chức năng:
/// - Hiển thị tổng quan đơn hàng
/// - Chọn phương thức thanh toán
/// - Xác nhận đặt hàng
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  static const String routeName = '/payment';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit()..loadOrderSummary(),
      child: const PaymentView(),
    );
  }
}

/// View của màn hình thanh toán
class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          // Show success dialog or navigate to success page
          _showSuccessDialog(context, state);
        } else if (state is PaymentFailure) {
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
        body: Column(
          children: [
            // Header with background
            _buildHeader(context),
            
            // Content
            Expanded(
              child: BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B40F),
                      ),
                    );
                  }

                  if (state is PaymentLoaded) {
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
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Title row
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/img/arrow_left_cart.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  const Text(
                    'Tổng quan đơn hàng',
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
                  const SizedBox(width: 40),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Address row
              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoaded) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B40F).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/img/location_icon_small.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${state.orderSummary.customerName} ${state.orderSummary.phoneNumber}',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.29,
                              color: Color(0xFF000000),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/img/chevron_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF999999),
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox(height: 30);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Content
  Widget _buildContent(BuildContext context, PaymentLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery address
          _buildDeliveryAddress(state.orderSummary),
          
          const SizedBox(height: 16),
          
          // Order items
          _buildOrderItems(state.orderSummary),
          
          const SizedBox(height: 16),
          
          // Delivery time
          _buildDeliveryTime(state.orderSummary),
          
          const SizedBox(height: 24),
          
          // Order summary
          _buildOrderSummary(state.orderSummary),
          
          const SizedBox(height: 24),
          
          // Payment method
          _buildPaymentMethod(context, state),
          
          const SizedBox(height: 24),
          
          // Total section
          _buildTotalSection(state.orderSummary),
          
          const SizedBox(height: 24),
          
          // Order button
          _buildOrderButton(context, state),
        ],
      ),
    );
  }

  /// Delivery address section
  Widget _buildDeliveryAddress(OrderSummary orderSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00B40F).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00B40F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF00B40F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderSummary.deliveryAddress,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Order items section
  Widget _buildOrderItems(OrderSummary orderSummary) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF00B40F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  orderSummary.items.first.shopName,
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
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Products
          ...orderSummary.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 16),
                _buildOrderItem(item),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Single order item
  Widget _buildOrderItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.productImage,
                width: 91,
                height: 91,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.375,
                    color: Color(0xFF202020),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Weight
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.weight}${item.unit}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Price
                Row(
                  children: [
                    Text(
                      '${_formatPrice(item.totalPrice)}đ',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 1.29,
                        color: Color(0xFFFF0000),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Delivery time
  Widget _buildDeliveryTime(OrderSummary orderSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B40F).withValues(alpha: 0.1),
            const Color(0xFF00B40F).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00B40F).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00B40F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thời gian giao hàng dự kiến',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderSummary.estimatedDelivery,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF00B40F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Order summary section
  Widget _buildOrderSummary(OrderSummary orderSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Subtotal
          _buildSummaryRow('Tổng phụ', orderSummary.subtotal, false),
          
          const SizedBox(height: 12),
          
          // Shipping
          _buildSummaryRow('Vận chuyển', orderSummary.shippingFee, false),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Total
          _buildSummaryRow('Tổng cộng', orderSummary.total, true),
        ],
      ),
    );
  }

  /// Summary row
  Widget _buildSummaryRow(String label, double amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            fontSize: isTotal ? 18 : 16,
            height: 1.29,
            color: isTotal ? const Color(0xFF000000) : const Color(0xFF666666),
          ),
        ),
        Text(
          '${_formatPrice(amount)}đ',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 20 : 16,
            height: 1.29,
            color: isTotal ? const Color(0xFF00B40F) : const Color(0xFF000000),
          ),
        ),
      ],
    );
  }

  /// Payment method section
  Widget _buildPaymentMethod(BuildContext context, PaymentLoaded state) {
    final cubit = context.read<PaymentCubit>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
              color: Color(0xFF202020),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Cash on delivery
          _buildPaymentMethodOption(
            context,
            PaymentMethod.cashOnDelivery,
            'Thanh toán khi giao',
            'assets/img/payment_cash_icon.png',
            state.selectedPaymentMethod == PaymentMethod.cashOnDelivery,
            () => cubit.selectPaymentMethod(PaymentMethod.cashOnDelivery),
          ),
          
          const SizedBox(height: 12),
          
          // VNPay
          _buildPaymentMethodOption(
            context,
            PaymentMethod.vnpay,
            'VNpay',
            'assets/img/payment_vnpay_logo-3a23a6.png',
            state.selectedPaymentMethod == PaymentMethod.vnpay,
            () => cubit.selectPaymentMethod(PaymentMethod.vnpay),
            isLogo: true,
          ),
        ],
      ),
    );
  }

  /// Payment method option
  Widget _buildPaymentMethodOption(
    BuildContext context,
    PaymentMethod method,
    String label,
    String iconPath,
    bool isSelected,
    VoidCallback onTap, {
    bool isLogo = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF00B40F).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF00B40F)
                : Colors.black.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
              alignment: Alignment.center,
              child: isLogo
                  ? Image.asset(
                      iconPath,
                      width: 40,
                      height: 15,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      iconPath,
                      width: 30,
                      height: 30,
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 17,
                  height: 1.1,
                  color: const Color(0xFF202020),
                ),
              ),
            ),
            
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF00B40F)
                      : Colors.black.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF00B40F) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Total section
  Widget _buildTotalSection(OrderSummary orderSummary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B40F).withValues(alpha: 0.15),
            const Color(0xFF00B40F).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B40F).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${orderSummary.totalItemCount} mặt hàng',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
          Text(
            '${_formatPrice(orderSummary.total)}đ',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1.2,
              color: Color(0xFF00B40F),
            ),
          ),
        ],
      ),
    );
  }

  /// Order button
  Widget _buildOrderButton(BuildContext context, PaymentLoaded state) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, currentState) {
        final isProcessing = currentState is PaymentProcessing;
        
        return GestureDetector(
          onTap: isProcessing
              ? null
              : () => context.read<PaymentCubit>().processPayment(),
          child: Container(
            height: 59,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProcessing
                    ? [
                        const Color(0xFF00B40F),
                        const Color(0xFF00B40F),
                      ]
                    : [
                        Color(0xFF00B40F),
                        Color(0xFF00B40F),
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: isProcessing
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF00B40F).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Xác nhận đặt hàng',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1.21,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, PaymentSuccess state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00B40F),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.21,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã đơn hàng: ${state.orderId}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close payment page
                  // Navigate to order page
                  Navigator.of(context).pushNamed(RouteName.orderList);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B40F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
