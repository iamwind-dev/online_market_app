import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/app_logger.dart';

part 'order_state.dart';

/// Cubit quản lý logic cho Order
/// 
/// Chức năng:
/// - Tải danh sách đơn hàng
/// - Lọc đơn hàng theo trạng thái
/// - Mở rộng/thu gọn chi tiết đơn hàng
class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderInitial());

  List<Order> _allOrders = [];
  OrderFilterType _currentFilter = OrderFilterType.all;

  /// Tải danh sách đơn hàng
  Future<void> loadOrders() async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('Loading orders');
    }

    emit(const OrderLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if cubit is still open before continuing
      if (isClosed) return;

      // Generate mock data
      _allOrders = _generateMockOrders();

      if (AppConfig.enableApiLogging) {
        AppLogger.info('Orders loaded successfully: ${_allOrders.length} orders');
      }

      _emitFilteredOrders();
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('Failed to load orders: $e');
      }

      if (!isClosed) {
        emit(OrderFailure(
          errorMessage: 'Không thể tải danh sách đơn hàng. Vui lòng thử lại.',
        ));
      }
    }
  }

  /// Lọc đơn hàng theo trạng thái
  void filterOrders(OrderFilterType filterType) {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('Filtering orders by: ${filterType.displayName}');
    }

    _currentFilter = filterType;
    _emitFilteredOrders();
  }

  /// Mở rộng/thu gọn đơn hàng
  void toggleOrderExpansion(String orderId) {
    final updatedOrders = _allOrders.map((order) {
      if (order.orderId == orderId) {
        return order.copyWith(isExpanded: !order.isExpanded);
      }
      return order;
    }).toList();

    _allOrders = updatedOrders;
    _emitFilteredOrders();
  }

  /// Emit danh sách đơn hàng đã lọc
  void _emitFilteredOrders() {
    List<Order> filteredOrders;

    switch (_currentFilter) {
      case OrderFilterType.all:
        filteredOrders = _allOrders;
        break;
      case OrderFilterType.pending:
        filteredOrders = _allOrders
            .where((order) => order.status == OrderStatusType.pending)
            .toList();
        break;
      case OrderFilterType.processing:
        filteredOrders = _allOrders
            .where((order) => order.status == OrderStatusType.processing)
            .toList();
        break;
      case OrderFilterType.shipping:
        filteredOrders = _allOrders
            .where((order) => order.status == OrderStatusType.shipping)
            .toList();
        break;
      case OrderFilterType.delivered:
        filteredOrders = _allOrders
            .where((order) => order.status == OrderStatusType.delivered)
            .toList();
        break;
    }

    // Calculate counts for each status
    final pendingCount = _allOrders
        .where((order) => order.status == OrderStatusType.pending)
        .length;
    final processingCount = _allOrders
        .where((order) => order.status == OrderStatusType.processing)
        .length;
    final shippingCount = _allOrders
        .where((order) => order.status == OrderStatusType.shipping)
        .length;
    final deliveredCount = _allOrders
        .where((order) => order.status == OrderStatusType.delivered)
        .length;

    emit(OrderLoaded(
      orders: filteredOrders,
      filterType: _currentFilter,
      pendingCount: pendingCount,
      processingCount: processingCount,
      shippingCount: shippingCount,
      deliveredCount: deliveredCount,
    ));
  }

  /// Generate mock orders
  List<Order> _generateMockOrders() {
    return [
      // Recent orders
      Order(
        orderId: 'ORD001',
        shopName: 'Thịt heo - Cô Nhi',
        items: [
          const OrderItem(
            productId: 'P001',
            productName: 'Thịt kho tàu',
            productImage: 'assets/img/order_meal_image.png',
            weight: 0.8,
            unit: 'kg',
            price: 125000,
            quantity: 1,
          ),
        ],
        totalAmount: 100000,
        status: OrderStatusType.shipping,
        orderDate: DateTime(2025, 11, 15, 10, 45),
      ),
      Order(
        orderId: 'ORD002',
        shopName: 'Trứng gà - Cô Thảo',
        items: [
          const OrderItem(
            productId: 'P002',
            productName: 'Trứng gà',
            productImage: 'assets/img/cart_product_2.png',
            weight: 4,
            unit: 'quả',
            price: 5000,
            quantity: 4,
          ),
        ],
        totalAmount: 20000,
        status: OrderStatusType.processing,
        orderDate: DateTime(2025, 11, 14, 14, 30),
      ),
      Order(
        orderId: 'ORD003',
        shopName: 'Nước mắm - Cô Trinh',
        items: [
          const OrderItem(
            productId: 'P003',
            productName: 'Nước mắm',
            productImage: 'assets/img/cart_product_3.png',
            weight: 1,
            unit: 'chai',
            price: 45000,
            quantity: 1,
          ),
        ],
        totalAmount: 45000,
        status: OrderStatusType.pending,
        orderDate: DateTime(2025, 11, 13, 9, 15),
      ),
      // Older orders
      Order(
        orderId: 'ORD004',
        shopName: 'Thịt heo - Cô Nhi',
        items: [
          const OrderItem(
            productId: 'P004',
            productName: 'Bún bò Huế',
            productImage: 'assets/img/order_dish_image.png',
            weight: 0.8,
            unit: 'kg',
            price: 125000,
            quantity: 1,
          ),
        ],
        totalAmount: 100000,
        status: OrderStatusType.delivered,
        orderDate: DateTime(2025, 1, 11, 11, 11),
      ),
      Order(
        orderId: 'ORD005',
        shopName: 'Thịt bò - Cô Thảo',
        items: [
          const OrderItem(
            productId: 'P005',
            productName: 'Thịt bò',
            productImage: 'assets/img/cart_product_1.png',
            weight: 0.5,
            unit: 'kg',
            price: 180000,
            quantity: 1,
          ),
        ],
        totalAmount: 90000,
        status: OrderStatusType.delivered,
        orderDate: DateTime(2025, 1, 10, 16, 20),
      ),
      Order(
        orderId: 'ORD006',
        shopName: 'Nước mắm - Cô Trinh',
        items: [
          const OrderItem(
            productId: 'P006',
            productName: 'Nước mắm',
            productImage: 'assets/img/cart_product_3.png',
            weight: 1,
            unit: 'chai',
            price: 45000,
            quantity: 1,
          ),
        ],
        totalAmount: 45000,
        status: OrderStatusType.delivered,
        orderDate: DateTime(2025, 1, 9, 8, 45),
      ),
      Order(
        orderId: 'ORD007',
        shopName: 'Mắm ruốc - Cô Trinh',
        items: [
          const OrderItem(
            productId: 'P007',
            productName: 'Mắm ruốc',
            productImage: 'assets/img/cart_product_3.png',
            weight: 1,
            unit: 'chai',
            price: 40000,
            quantity: 1,
          ),
        ],
        totalAmount: 40000,
        status: OrderStatusType.delivered,
        orderDate: DateTime(2025, 1, 8, 13, 30),
      ),
    ];
  }
}
