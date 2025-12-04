import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/config/app_config.dart';
import '../../../../../../core/utils/app_logger.dart';
import '../../../../../../core/services/order_service.dart';

part 'order_detail_state.dart';

/// Cubit quản lý logic cho OrderDetail
/// 
/// Chức năng:
/// - Tải chi tiết đơn hàng
/// - Hủy đơn hàng
/// - Đặt lại đơn hàng
/// - Đánh giá đơn hàng
class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrderService _orderService = OrderService();
  
  OrderDetailCubit() : super(const OrderDetailInitial());

  /// Tải chi tiết đơn hàng từ API
  Future<void> loadOrderDetail(String orderId) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('Loading order detail for orderId: $orderId');
    }

    emit(const OrderDetailLoading());

    try {
      final response = await _orderService.getOrderDetail(orderId);

      // Check if cubit is still open before continuing
      if (isClosed) return;

      if (AppConfig.enableApiLogging) {
        AppLogger.info('Order detail loaded successfully');
      }

      emit(OrderDetailLoaded(orderDetail: response.data));
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
      // TODO: Implement cancel order API
      await Future.delayed(const Duration(seconds: 1));

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
      // TODO: Implement reorder API
      await Future.delayed(const Duration(seconds: 1));

      if (isClosed) return;

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
}
