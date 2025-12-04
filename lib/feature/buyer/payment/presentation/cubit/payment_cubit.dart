import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/services/vnpay_service.dart';
import '../../../../../core/services/auth/auth_service.dart';
import '../../../../../core/dependency/injection.dart';

part 'payment_state.dart';

/// Payment Cubit quản lý logic nghiệp vụ của thanh toán
/// 
/// Chức năng chính:
/// - Tải thông tin đơn hàng
/// - Chọn phương thức thanh toán
/// - Xử lý thanh toán
class PaymentCubit extends Cubit<PaymentState> {
  final AuthService _authService = getIt<AuthService>();
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
        _orderSummary = await _createOrderFromBuyNowData(orderData);
      } else if (isFromCart && orderData != null) {
        // Từ giỏ hàng - tạo order summary từ các items đã chọn
        print('💳 [PAYMENT CUBIT] Creating order from cart data');
        _orderSummary = await _createOrderFromCartData(orderData);
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
        orderCode: orderData?['orderCode'] as String?,
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
  Future<OrderSummary> _createOrderFromBuyNowData(Map<String, dynamic> data) async {
    print('💳 [PAYMENT CUBIT] Buy now data: $data');
    
    // Lưu mã đơn hàng nếu có
    _maDonHang = data['orderCode'] as String?;
    
    // Lấy thông tin user
    String customerName = 'Khách hàng';
    String phoneNumber = '';
    String deliveryAddress = '';
    
    try {
      final user = await _authService.getCurrentUser();
      customerName = user.tenNguoiDung.isNotEmpty ? user.tenNguoiDung : 'Khách hàng';
      phoneNumber = user.sdt ?? '';
      deliveryAddress = user.diaChi ?? '';
    } catch (e) {
      print('💳 [PAYMENT CUBIT] Lỗi lấy user data: $e');
    }
    
    // Parse giá từ string (ví dụ: "89,000 đ" -> 89000)
    final priceStr = data['gia'] as String? ?? '0';
    final priceValue = double.tryParse(
      priceStr.replaceAll(RegExp(r'[^\d]'), '')
    ) ?? 0;
    
    final soLuong = data['soLuong'] as int? ?? 1;
    final totalPrice = priceValue * soLuong;
    
    return OrderSummary(
      customerName: customerName,
      phoneNumber: phoneNumber,
      deliveryAddress: deliveryAddress.isNotEmpty ? deliveryAddress : '(Chưa cập nhật địa chỉ)',
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
      shippingFee: 0,
      total: totalPrice,
    );
  }

  /// Tạo order summary từ dữ liệu giỏ hàng
  Future<OrderSummary> _createOrderFromCartData(Map<String, dynamic> data) async {
    print('💳 [PAYMENT CUBIT] Cart data: $data');
    
    final selectedItems = data['selectedItems'] as List<dynamic>? ?? [];
    final totalAmount = data['totalAmount'] as double? ?? 0;
    
    // Lưu mã đơn hàng nếu có (từ cart API)
    _maDonHang = data['orderCode'] as String?;
    
    // Lấy thông tin user
    String customerName = 'Khách hàng';
    String phoneNumber = '';
    String deliveryAddress = '';
    
    try {
      final user = await _authService.getCurrentUser();
      customerName = user.tenNguoiDung.isNotEmpty ? user.tenNguoiDung : 'Khách hàng';
      phoneNumber = user.sdt ?? '';
      deliveryAddress = user.diaChi ?? '';
    } catch (e) {
      print('💳 [PAYMENT CUBIT] Lỗi lấy user data: $e');
    }
    
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
      customerName: customerName,
      phoneNumber: phoneNumber,
      deliveryAddress: deliveryAddress.isNotEmpty ? deliveryAddress : '(Chưa cập nhật địa chỉ)',
      estimatedDelivery: 'Nhận vào 2 giờ tới',
      items: orderItems,
      subtotal: totalAmount,
      shippingFee: 0,
      total: totalAmount,
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
        orderCode: _maDonHang,
      ));
    }
  }

  /// Check payment status (gọi khi app resume từ browser VNPay)
  /// Lấy mã đơn hàng đã có sẵn ở trang payment và navigate đến order detail
  Future<void> checkPaymentStatus() async {
    final currentState = state;
    String? maDonHang;
    
    // Lấy mã đơn hàng từ state hoặc biến instance
    if (currentState is PaymentLoaded && currentState.orderCode != null) {
      maDonHang = currentState.orderCode;
    } else {
      maDonHang = _maDonHang;
    }
    
    if (maDonHang == null || maDonHang.isEmpty) {
      if (AppConfig.enableApiLogging) {
        AppLogger.warning('⚠️ [PAYMENT] No order code available');
      }
      return;
    }

    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] App resumed from browser');
      AppLogger.info('💳 [PAYMENT] Using existing order code: $maDonHang');
    }

    // Khi user quay lại từ VNPay browser, ta giả định thanh toán thành công
    // và navigate đến order detail với mã đơn hàng đã có
    if (!isClosed) {
      emit(PaymentSuccess(
        message: 'Thanh toán thành công!',
        orderId: maDonHang,
      ));
    }
  }

  /// Verify payment result từ VNPay callback
  Future<void> verifyVNPayReturn(Map<String, String> queryParams) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [PAYMENT] Verifying VNPay return...');
      AppLogger.info('💳 [PAYMENT] Query params: $queryParams');
    }

    try {
      emit(PaymentProcessing());

      final vnpayService = VNPayService();
      final result = await vnpayService.verifyPaymentReturn(
        queryParams: queryParams,
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('💳 [PAYMENT] Verify result: ${result.success}');
        AppLogger.info('💳 [PAYMENT] Message: ${result.message}');
        AppLogger.info('💳 [PAYMENT] Order: ${result.maDonHang}');
        AppLogger.info('💳 [PAYMENT] Clear cart: ${result.clearCart}');
      }

      if (!isClosed) {
        if (result.success) {
          emit(PaymentSuccess(
            message: result.message,
            orderId: result.maDonHang,
          ));
        } else {
          emit(PaymentFailure(
            errorMessage: result.message,
          ));
        }
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [PAYMENT] Verify error: $e');
      }
      if (!isClosed) {
        emit(PaymentFailure(
          errorMessage: 'Không thể xác minh kết quả thanh toán: ${e.toString()}',
        ));
      }
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
      // Lấy mã đơn hàng TRƯỚC khi emit PaymentProcessing
      final currentState = state;
      String maDonHang;
      
      if (currentState is PaymentLoaded && currentState.orderCode != null && currentState.orderCode!.isNotEmpty) {
        maDonHang = currentState.orderCode!;
        if (AppConfig.enableApiLogging) {
          AppLogger.info('💳 [PAYMENT] Using order code from state: $maDonHang');
        }
      } else if (_maDonHang != null && _maDonHang!.isNotEmpty) {
        maDonHang = _maDonHang!;
        if (AppConfig.enableApiLogging) {
          AppLogger.info('💳 [PAYMENT] Using order code from instance: $maDonHang');
        }
      } else {
        // Fallback: tạo mã đơn hàng mới
        maDonHang = 'DH${DateTime.now().millisecondsSinceEpoch}';
        if (AppConfig.enableApiLogging) {
          AppLogger.warning('⚠️ [PAYMENT] No order code found, generating new: $maDonHang');
        }
      }
      
      emit(PaymentProcessing());

      if (_selectedPaymentMethod == PaymentMethod.vnpay) {
        // Xử lý thanh toán VNPay
        final vnpayService = VNPayService();
        final vnpayResponse = await vnpayService.createVNPayCheckout(
          maDonHang: maDonHang,
          bankCode: 'NCB',
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
              AppLogger.info('📝 [PAYMENT] Mã đơn hàng: $maDonHang');
              AppLogger.info('📝 [PAYMENT] Mã thanh toán: ${vnpayResponse.maThanhToan}');
            }
            
            // Quay lại state PaymentLoaded để chờ user thanh toán xong và quay lại app
            // Khi app resume, checkPaymentStatus() sẽ được gọi
            if (!isClosed) {
              emit(PaymentLoaded(
                orderSummary: _orderSummary!,
                selectedPaymentMethod: _selectedPaymentMethod,
                orderCode: maDonHang, // Giữ mã đơn hàng để check status sau
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

        if (AppConfig.enableApiLogging) {
          AppLogger.info('🎉 [PAYMENT] Đặt hàng thành công!');
          AppLogger.info('📝 [PAYMENT] Mã đơn hàng: $maDonHang');
        }

        emit(PaymentSuccess(
          message: 'Đặt hàng thành công! Thanh toán khi nhận hàng.',
          orderId: maDonHang,
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
      shippingFee: 0,
      total: 89000,
    );
  }

  /// Reset state về initial
  void resetState() {
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _orderSummary = null;
    emit(PaymentInitial());
  }
}
