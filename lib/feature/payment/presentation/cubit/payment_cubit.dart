import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/config/app_config.dart';

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
  
  PaymentCubit() : super(PaymentInitial());

  /// Tải thông tin đơn hàng
  Future<void> loadOrderSummary() async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🎯 [PAYMENT] Bắt đầu tải thông tin đơn hàng');
    }

    try {
      emit(PaymentLoading());

      // TODO: Gọi API để lấy thông tin đơn hàng
      // await _paymentRepository.getOrderSummary();
      
      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      _orderSummary = _generateMockOrderSummary();

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

      // TODO: Gọi API để xử lý thanh toán
      // if (_selectedPaymentMethod == PaymentMethod.vnpay) {
      //   await _paymentRepository.processVNPayPayment(_orderSummary!);
      // } else {
      //   await _paymentRepository.createCashOnDeliveryOrder(_orderSummary!);
      // }
      
      await Future.delayed(const Duration(seconds: 2));

      // Check if cubit is still open before continuing
      if (isClosed) return;

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🎉 [PAYMENT] Thanh toán thành công!');
        AppLogger.info('📝 [PAYMENT] Mã đơn hàng: $orderId');
      }

      emit(PaymentSuccess(
        message: _selectedPaymentMethod == PaymentMethod.vnpay
            ? 'Thanh toán VNPay thành công!'
            : 'Đặt hàng thành công! Thanh toán khi nhận hàng.',
        orderId: orderId,
      ));
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
