import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/vnpay_service.dart';
import '../../../../core/services/cart_api_service.dart';

part 'payment_state.dart';

/// Payment Cubit quản lý logic nghiệp vụ của thanh toán
/// 
/// Chức năng chính:
/// - Tải thông tin đơn hàng
/// - Chọn phương thức thanh toán
/// - Xử lý thanh toán
class PaymentCubit extends Cubit<PaymentState> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  OrderSummary? _orderSummary;
  String? _maDonHang; // Mã đơn hàng từ API cart hoặc tạo mới
  
  PaymentCubit() : super(PaymentInitial());

  /// Tải thông tin đơn hàng
  Future<void> loadOrderSummary({
    bool isBuyNow = false,
    bool isFromCart = false,
    Map<String, dynamic>? orderData,
  }) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🎯 [PAYMENT] Bắt đầu tải thông tin đơn hàng');
      AppLogger.info('🎯 [PAYMENT] isBuyNow: $isBuyNow, isFromCart: $isFromCart');
    }

    try {
      emit(PaymentLoading());

      if (isBuyNow && orderData != null) {
        // Mua ngay - tạo order summary từ dữ liệu truyền vào
        print('💳 [PAYMENT CUBIT] Creating order from buy now data');
        _orderSummary = _createOrderFromBuyNowData(orderData);
      } else if (isFromCart && orderData != null) {
        // Từ giỏ hàng - tạo order summary từ các items đã chọn
        print('💳 [PAYMENT CUBIT] Creating order from cart data');
        _orderSummary = _createOrderFromCartData(orderData);
      } else {
        // Fallback - Mock data
        await Future.delayed(const Duration(seconds: 1));
        
        // Check if cubit is still open before continuing
        if (isClosed) return;
        
        _orderSummary = _generateMockOrderSummary();
      }

      if (AppConfig.enableApiLogging) {
        AppLogger.info('✅ [PAYMENT] Tải thành công thông tin đơn hàng');
        AppLogger.info('💰 [PAYMENT] Tổng tiền: ${_orderSummary!.total}đ');
      }

      emit(PaymentLoaded(
        orderSummary: _orderSummary!,
        selectedPaymentMethod: _selectedPaymentMethod,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Lỗi khi tải thông tin: ${e.toString()}');
      }
      if (!isClosed) {
        emit(PaymentFailure(
          errorMessage: 'Không thể tải thông tin đơn hàng: ${e.toString()}',
        ));
      }
    }
  }

  /// Tạo order summary từ dữ liệu "Mua ngay"
  OrderSummary _createOrderFromBuyNowData(Map<String, dynamic> data) {
    print('💳 [PAYMENT CUBIT] Buy now data: $data');
    
    // Parse giá từ string (ví dụ: "89,000 đ" -> 89000)
    final priceStr = data['gia'] as String? ?? '0';
    final priceValue = double.tryParse(
      priceStr.replaceAll(RegExp(r'[^\d]'), '')
    ) ?? 0;
    
    final soLuong = data['soLuong'] as int? ?? 1;
    final totalPrice = priceValue * soLuong;
    
    return OrderSummary(
      customerName: 'Phạm Thị Quỳnh Như',
      phoneNumber: '(+84) 03******12',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn, Đà Nẵng, Việt Nam',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: [
        OrderItem(
          id: data['maNguyenLieu'] as String? ?? '',
          shopName: data['tenGianHang'] as String? ?? '',
          productName: data['tenNguyenLieu'] as String? ?? '',
          productImage: data['hinhAnh'] as String? ?? 'assets/img/payment_product.png',
          price: priceValue,
          weight: 1.0,
          unit: data['donVi'] as String? ?? 'KG',
          quantity: soLuong,
        ),
      ],
      subtotal: totalPrice,
      shippingFee: 15000,
      total: totalPrice + 15000,
    );
  }

  /// Tạo order summary từ dữ liệu giỏ hàng
  OrderSummary _createOrderFromCartData(Map<String, dynamic> data) {
    print('💳 [PAYMENT CUBIT] Cart data: $data');
    
    final selectedItems = data['selectedItems'] as List<dynamic>? ?? [];
    final totalAmount = data['totalAmount'] as double? ?? 0;
    
    // Lưu mã đơn hàng nếu có (từ cart API)
    _maDonHang = data['orderCode'] as String?;
    
    // Convert selected items to OrderItem list
    final orderItems = selectedItems.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final priceStr = itemMap['gia'] as String? ?? '0';
      final priceValue = double.tryParse(
        priceStr.replaceAll(RegExp(r'[^\d.]'), '')
      ) ?? 0;
      
      return OrderItem(
        id: itemMap['maNguyenLieu'] as String? ?? '',
        shopName: itemMap['tenGianHang'] as String? ?? '',
        productName: itemMap['tenNguyenLieu'] as String? ?? '',
        productImage: itemMap['hinhAnh'] as String? ?? '',
        price: priceValue,
        weight: 1.0,
        unit: 'Cái',
        quantity: itemMap['soLuong'] as int? ?? 1,
      );
    }).toList();
    
    return OrderSummary(
      customerName: 'Phạm Thị Quỳnh Như',
      phoneNumber: '(+84) 03******12',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn, Đà Nẵng, Việt Nam',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: orderItems,
      subtotal: totalAmount,
      shippingFee: 15000,
      total: totalAmount + 15000,
    );
  }

  /// Chọn phương thức thanh toán
  void selectPaymentMethod(PaymentMethod method) {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] Chọn phương thức: ${method.name}');
    }

    _selectedPaymentMethod = method;

    if (_orderSummary != null) {
      emit(PaymentLoaded(
        orderSummary: _orderSummary!,
        selectedPaymentMethod: _selectedPaymentMethod,
      ));
    }
  }

  /// Xử lý thanh toán
  Future<void> processPayment() async {
    if (_orderSummary == null) {
      if (!isClosed) {
        emit(const PaymentFailure(
          errorMessage: 'Không có thông tin đơn hàng',
        ));
      }
      return;
    }

    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] Bắt đầu xử lý thanh toán');
      AppLogger.info('💳 [PAYMENT] Phương thức: ${_selectedPaymentMethod.name}');
      AppLogger.info('💰 [PAYMENT] Tổng tiền: ${_orderSummary!.total}đ');
    }

    try {
      emit(PaymentProcessing());

      if (_selectedPaymentMethod == PaymentMethod.vnpay) {
        // Xử lý thanh toán VNPay
        // Fetch cart API để lấy mã đơn hàng mới nhất
        String maDonHang;
        
        try {
          if (AppConfig.enableApiLogging) {
            AppLogger.info('💳 [PAYMENT] Fetching cart to get order code...');
          }
          
          final cartService = CartApiService();
          final cartResponse = await cartService.getCart();
          maDonHang = cartResponse.cart.maDonHang;
          
          if (AppConfig.enableApiLogging) {
            AppLogger.info('💳 [PAYMENT] Got order code from cart: $maDonHang');
          }
        } catch (e) {
          // Nếu không lấy được từ cart, dùng mã đã lưu hoặc tạo mới
          maDonHang = _maDonHang ?? 'DH${DateTime.now().millisecondsSinceEpoch}';
          
          if (AppConfig.enableApiLogging) {
            AppLogger.warning('⚠️ [PAYMENT] Failed to get cart, using fallback: $maDonHang');
          }
        }
        
        final vnpayService = VNPayService();
        final vnpayResponse = await vnpayService.createVNPayCheckout(
          maDonHang: maDonHang,
          bankCode: 'MBBANK',
        );
        
        if (vnpayResponse.success && vnpayResponse.redirect.isNotEmpty) {
          // Mở URL VNPay trong trình duyệt
          final url = Uri.parse(vnpayResponse.redirect);
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication, // Mở trong trình duyệt mặc định
            );
            
            if (AppConfig.enableApiLogging) {
              AppLogger.info('🎉 [PAYMENT] Đã mở VNPay payment URL');
              AppLogger.info('📝 [PAYMENT] Mã thanh toán: ${vnpayResponse.maThanhToan}');
            }
            
            // Emit success với thông tin VNPay
            if (!isClosed) {
              emit(PaymentSuccess(
                message: 'Đang chuyển đến VNPay để thanh toán...',
                orderId: vnpayResponse.maThanhToan,
              ));
            }
          } else {
            throw Exception('Không thể mở URL thanh toán VNPay');
          }
        } else {
          throw Exception('Không nhận được URL thanh toán từ VNPay');
        }
      } else {
        // Thanh toán khi nhận hàng
        await Future.delayed(const Duration(seconds: 2));

        // Check if cubit is still open before continuing
        if (isClosed) return;

        final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

        if (AppConfig.enableApiLogging) {
          AppLogger.info('🎉 [PAYMENT] Đặt hàng thành công!');
          AppLogger.info('📝 [PAYMENT] Mã đơn hàng: $orderId');
        }

        emit(PaymentSuccess(
          message: 'Đặt hàng thành công! Thanh toán khi nhận hàng.',
          orderId: orderId,
        ));
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Lỗi khi xử lý thanh toán: ${e.toString()}');
      }
      if (!isClosed) {
        emit(PaymentFailure(
          errorMessage: 'Không thể xử lý thanh toán: ${e.toString()}',
        ));
      }
    }
  }

  /// Get phương thức thanh toán đã chọn
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  /// Get tên phương thức thanh toán
  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'Thanh toán khi giao';
      case PaymentMethod.vnpay:
        return 'VNpay';
    }
  }

  /// Generate mock order summary
  OrderSummary _generateMockOrderSummary() {
    return const OrderSummary(
      customerName: 'Phạm Thị Quỳnh Như',
      phoneNumber: '(+84) 03******12',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn, Đà Nẵng, Việt Nam',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: [
        OrderItem(
          id: '1',
          shopName: 'Cô Nhi',
          productName: 'Thịt đùi',
          productImage: 'assets/img/payment_product.png',
          price: 89000,
          weight: 0.7,
          unit: 'KG',
          quantity: 1,
        ),
      ],
      subtotal: 89000,
      shippingFee: 15000,
      total: 104000,
    );
  }

  /// Reset state về initial
  void resetState() {
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _orderSummary = null;
    emit(PaymentInitial());
  }
}
