import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/payment_cubit.dart';

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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header with background
              _buildHeader(context),
              
              // Divider
              Container(
                height: 2,
                color: const Color(0xFFF0F0F0),
              ),
              
              // Content
              Expanded(
                child: BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
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
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              
              // Title row
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/img/arrow_left_cart.svg',
                      width: 25,
                      height: 26,
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
                  const SizedBox(width: 25),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Address row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/location_icon_small.png',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 4),
                  BlocBuilder<PaymentCubit, PaymentState>(
                    builder: (context, state) {
                      if (state is PaymentLoaded) {
                        return Flexible(
                          child: Text(
                            '${state.orderSummary.customerName} ${state.orderSummary.phoneNumber}',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              height: 1.29,
                              color: Color(0xFF000000),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    'assets/img/chevron_right.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFB3B3B3),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
    return Text(
      orderSummary.deliveryAddress,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 17,
        height: 1.29,
        color: Color(0xFF000000),
      ),
    );
  }

  /// Order items section
  Widget _buildOrderItems(OrderSummary orderSummary) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD7FFBD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name
          Text(
            orderSummary.items.first.shopName,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
              color: Color(0xFF202020),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Products
          ...orderSummary.items.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  /// Single order item
  Widget _buildOrderItem(OrderItem item) {
    return Row(
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.productImage,
            width: 91,
            height: 91,
            fit: BoxFit.cover,
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
                '${item.productName} - (${item.weight}${item.unit})',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 1.375,
                  color: Color(0xFF202020),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Price
              Text(
                '${_formatPrice(item.totalPrice)}đ',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  height: 1.29,
                  color: Color(0xFFFF0000),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Delivery time
  Widget _buildDeliveryTime(OrderSummary orderSummary) {
    return Text(
      orderSummary.estimatedDelivery,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 17,
        height: 1.29,
        color: Color(0xFF000000),
      ),
    );
  }

  /// Order summary section
  Widget _buildOrderSummary(OrderSummary orderSummary) {
    return Column(
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
        
        // Subtotal
        _buildSummaryRow('Tổng phụ', orderSummary.subtotal),
        
        const SizedBox(height: 12),
        
        // Shipping
        _buildSummaryRow('Vận chuyển', orderSummary.shippingFee),
        
        const SizedBox(height: 12),
        
        // Total
        _buildSummaryRow('Tổng', orderSummary.total),
      ],
    );
  }

  /// Summary row
  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 17,
            height: 1.29,
            color: Color(0xFF000000),
          ),
        ),
        Text(
          _formatPrice(amount),
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

  /// Payment method section
  Widget _buildPaymentMethod(BuildContext context, PaymentLoaded state) {
    final cubit = context.read<PaymentCubit>();
    
    return Column(
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
        
        // Cash on delivery
        _buildPaymentMethodOption(
          context,
          PaymentMethod.cashOnDelivery,
          'Thanh toán khi giao',
          'assets/img/payment_cash_icon.png',
          state.selectedPaymentMethod == PaymentMethod.cashOnDelivery,
          () => cubit.selectPaymentMethod(PaymentMethod.cashOnDelivery),
        ),
        
        const SizedBox(height: 16),
        
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
      child: Row(
        children: [
          // Icon
          if (isLogo)
            Image.asset(
              iconPath,
              width: 62,
              height: 19,
              fit: BoxFit.contain,
            )
          else
            Image.asset(
              iconPath,
              width: 45,
              height: 45,
            ),
          
          const SizedBox(width: 16),
          
          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 20,
                height: 1.1,
                color: Color(0xFF202020),
              ),
            ),
          ),
          
          // Checkbox
          Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
              color: isSelected ? Colors.black : Colors.white,
            ),
            child: isSelected
                ? SvgPicture.asset(
                    'assets/img/payment_check_icon.svg',
                    width: 11,
                    height: 9,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  /// Total section
  Widget _buildTotalSection(OrderSummary orderSummary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tổng (${orderSummary.totalItemCount} mặt hàng)',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.1,
            color: Color(0xFF000000),
          ),
        ),
        Text(
          '${_formatPrice(orderSummary.total)}đ',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            height: 1.29,
            color: Color(0xFF000000),
          ),
        ),
      ],
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
              color: const Color(0xFF2F8000),
              borderRadius: BorderRadius.circular(18),
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
                    'XÁC NHẬN ĐẶT HÀNG THÀNH CÔNG!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1.21,
                      color: Colors.white,
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
                color: Color(0xFF2F8000),
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
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F8000),
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
