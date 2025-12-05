import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/payment_cubit.dart';
import '../../../../../core/config/route_name.dart';
import '../../../../../core/theme/app_colors.dart';

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
    // Lấy arguments
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isBuyNow = arguments?['isBuyNow'] == true;
    final isFromCart = arguments?['isFromCart'] == true;
    
    print('💳 [PAYMENT PAGE] isBuyNow: $isBuyNow, isFromCart: $isFromCart');
    if (isBuyNow) {
      print('💳 [PAYMENT PAGE] Buy now data: $arguments');
    } else if (isFromCart) {
      print('💳 [PAYMENT PAGE] Cart data: ${arguments?['selectedItems']?.length} items');
    }
    
    return BlocProvider(
      create: (context) => PaymentCubit()..loadOrderSummary(
        isBuyNow: isBuyNow,
        isFromCart: isFromCart,
        orderData: arguments,
      ),
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

class _PaymentViewState extends State<PaymentView> with WidgetsBindingObserver {
  bool _hasProcessedReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Khi app resume từ background (user quay lại từ browser)
    if (state == AppLifecycleState.resumed && !_hasProcessedReturn) {
      _hasProcessedReturn = true;
      
      print('💳 [PAYMENT PAGE] App resumed - checking payment status');
      
      // Đợi 1 giây để đảm bảo server đã xử lý xong callback từ VNPay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Gọi method check payment status
          context.read<PaymentCubit>().checkPaymentStatus();
        }
      });
    }
  }

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
        } else if (state is PaymentPendingVNPay) {
          // Hiển thị dialog thông báo cần thanh toán
          _showPendingPaymentDialog(context, state);
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
                  if (state is PaymentLoading || state is PaymentProcessing) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B40F),
                      ),
                    );
                  }

                  if (state is PaymentLoaded) {
                    return _buildContent(context, state);
                  }
                  
                  if (state is PaymentPendingVNPay) {
                    // Hiển thị UI chờ thanh toán
                    return _buildPendingPaymentContent(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            
            // Bottom navigation
            
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
              
              const SizedBox(height: 8),
              
              // Order code row
              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoaded && state.orderCode != null && state.orderCode!.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 16,
                            color: Color(0xFF8E8E93),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Mã đơn: ${state.orderCode}',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
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

  /// Order items section - Nhóm theo gian hàng
  Widget _buildOrderItems(OrderSummary orderSummary) {
    // Nhóm items theo shop
    final itemsByShop = <String, List<OrderItem>>{};
    for (final item in orderSummary.items) {
      if (!itemsByShop.containsKey(item.shopName)) {
        itemsByShop[item.shopName] = [];
      }
      itemsByShop[item.shopName]!.add(item);
    }

    return Column(
      children: itemsByShop.entries.map((entry) {
        final shopName = entry.key;
        final items = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                      shopName,
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
              
              // Products của shop này
              ...items.asMap().entries.map((entry) {
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
      }).toList(),
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
              child: _buildProductImage(item.productImage),
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
          // _buildSummaryRow('Vận chuyển', orderSummary.shippingFee, false),
          
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
      builder: (BuildContext dialogContext) {
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
                  Navigator.of(dialogContext).pop(); // Close dialog
                  // Navigate to order detail page with order ID
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteName.orderDetail,
                    (route) => route.settings.name == RouteName.main || route.isFirst,
                    arguments: state.orderId,
                  );
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
                  'Xem chi tiết đơn hàng',
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

  /// Dialog thông báo cần thanh toán VNPay
  void _showPendingPaymentDialog(BuildContext context, PaymentPendingVNPay state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Color(0xFFFF9500),
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Chờ thanh toán',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Color(0xFF202020),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Message
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Order code
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mã đơn: ${state.orderId}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // Hủy button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop(); // Quay lại trang trước
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Thanh toán lại button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Gọi lại thanh toán VNPay
                          context.read<PaymentCubit>().processPayment();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B40F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Thanh toán',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// UI hiển thị khi đang chờ thanh toán VNPay
  Widget _buildPendingPaymentContent(BuildContext context, PaymentPendingVNPay state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Warning icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payment,
              color: Color(0xFFFF9500),
              size: 50,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Đơn hàng chờ thanh toán',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF202020),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Message
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Order code card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF9500).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFFF9500),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mã đơn hàng: ${state.orderId}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Thanh toán button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<PaymentCubit>().processPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B40F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Thanh toán ngay',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Quay lại button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Quay lại',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build product image - support both URL and asset
  Widget _buildProductImage(String imagePath) {
    final isNetworkImage = imagePath.startsWith('http://') || 
                          imagePath.startsWith('https://');
    
    final placeholderWidget = Container(
      width: 91,
      height: 91,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );

    if (imagePath.isEmpty) {
      return placeholderWidget;
    }

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        width: 91,
        height: 91,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 91,
            height: 91,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: const Color(0xFF00B40F),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => placeholderWidget,
      );
    } else {
      return Image.asset(
        imagePath,
        width: 91,
        height: 91,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholderWidget,
      );
    }
  }

  /// Format price helper
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
