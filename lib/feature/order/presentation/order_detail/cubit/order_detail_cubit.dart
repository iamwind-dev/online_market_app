import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/app_logger.dart';

part 'order_detail_state.dart';

/// Cubit quản lý logic cho OrderDetail
/// 
/// Chức năng:
/// - Tải chi tiết đơn hàng
/// - Hủy đơn hàng
/// - Đặt lại đơn hàng
/// - Đánh giá đơn hàng
class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit() : super(const OrderDetailInitial());

  /// Tải chi tiết đơn hàng
  Future<void> loadOrderDetail(String orderId) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('Loading order detail for orderId: $orderId');
    }

    emit(const OrderDetailLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if cubit is still open before continuing
      if (isClosed) return;

      // Generate mock data
      final orderDetail = _generateMockOrderDetail(orderId);

      if (AppConfig.enableApiLogging) {
        AppLogger.info('Order detail loaded successfully');
      }

      emit(OrderDetailLoaded(orderDetail: orderDetail));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('Failed to load order detail: $e');
      }

      if (!isClosed) {
        emit(OrderDetailFailure(
          errorMessage: 'Không thể tải chi tiết đơn hàng. Vui lòng thử lại.',
        ));
      }
    }
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(String orderId, String reason) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('Cancelling order: $orderId, reason: $reason');
    }

    emit(const OrderDetailProcessing());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if cubit is still open before continuing
      if (isClosed) return;

      if (AppConfig.enableApiLogging) {
        AppLogger.info('Order cancelled successfully');
      }

      emit(OrderDetailCancelled(
        message: 'Đơn hàng đã được hủy thành công',
        orderId: orderId,
      ));

      // Reload order detail to show updated status
      await loadOrderDetail(orderId);
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('Failed to cancel order: $e');
      }

      if (!isClosed) {
        emit(OrderDetailFailure(
          errorMessage: 'Không thể hủy đơn hàng. Vui lòng thử lại.',
        ));
      }
    }
  }

  /// Đặt lại đơn hàng
  Future<void> reorder(String orderId) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('Reordering: $orderId');
    }

    emit(const OrderDetailProcessing());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if cubit is still open before continuing
      if (isClosed) return;

      // Generate new order ID
      final newOrderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      if (AppConfig.enableApiLogging) {
        AppLogger.info('Reorder successful, new order ID: $newOrderId');
      }

      emit(OrderDetailReordered(
        message: 'Đặt lại đơn hàng thành công',
        newOrderId: newOrderId,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('Failed to reorder: $e');
      }

      if (!isClosed) {
        emit(OrderDetailFailure(
          errorMessage: 'Không thể đặt lại đơn hàng. Vui lòng thử lại.',
        ));
      }
    }
  }

  /// Generate mock order detail
  OrderDetail _generateMockOrderDetail(String orderId) {
    return OrderDetail(
      orderId: orderId,
      orderNumber: '#DN12345',
      status: OrderStatus.delivered,
      shopName: 'Thịt heo - Cô Nhi',
      shopAvatar: 'L',
      items: [
        const OrderDetailItem(
          productId: '1',
          productName: 'Thịt heo',
          productImage: 'assets/img/cart_product_1.png',
          weight: 0.8,
          unit: 'kg',
          price: 125000,
          quantity: 1,
          totalPrice: 100000,
        ),
      ],
      pickupAddress: '12 Mỹ An Đông, Mỹ An, Ngũ Hành Sơn',
      deliveryAddress: '123 Đa Mặn, Mỹ An, Ngũ Hành Sơn',
      subtotal: 100000,
      shippingFee: 26000,
      discount: 0,
      total: 126000,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      deliveryDate: DateTime.now(),
      note: null,
    );
  }
}
