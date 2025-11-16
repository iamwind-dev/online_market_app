part of 'order_detail_cubit.dart';

/// Base state cho OrderDetail
abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

/// State khởi tạo ban đầu
class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

/// State đang tải dữ liệu
class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

/// State đã tải dữ liệu thành công
class OrderDetailLoaded extends OrderDetailState {
  final OrderDetail orderDetail;

  const OrderDetailLoaded({
    required this.orderDetail,
  });

  @override
  List<Object?> get props => [orderDetail];
}

/// State đang xử lý thao tác (hủy đơn, đặt lại)
class OrderDetailProcessing extends OrderDetailState {
  const OrderDetailProcessing();
}

/// State hủy đơn thành công
class OrderDetailCancelled extends OrderDetailState {
  final String message;
  final String orderId;

  const OrderDetailCancelled({
    required this.message,
    required this.orderId,
  });

  @override
  List<Object?> get props => [message, orderId];
}

/// State đặt lại đơn hàng thành công
class OrderDetailReordered extends OrderDetailState {
  final String message;
  final String newOrderId;

  const OrderDetailReordered({
    required this.message,
    required this.newOrderId,
  });

  @override
  List<Object?> get props => [message, newOrderId];
}

/// State thất bại
class OrderDetailFailure extends OrderDetailState {
  final String errorMessage;

  const OrderDetailFailure({
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [errorMessage];
}

/// Enum cho trạng thái đơn hàng
enum OrderStatus {
  pending,      // Chờ xử lý
  confirmed,    // Đã xác nhận
  processing,   // Đang xử lý
  shipping,     // Đang giao
  delivered,    // Đã giao
  cancelled,    // Đã hủy
  returned,     // Đã trả hàng
}

/// Extension để lấy tên hiển thị của trạng thái
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã trả hàng';
    }
  }

  bool get canCancel {
    return this == OrderStatus.pending || 
           this == OrderStatus.confirmed;
  }

  bool get canReorder {
    return this == OrderStatus.delivered || 
           this == OrderStatus.cancelled;
  }

  bool get canReview {
    return this == OrderStatus.delivered;
  }
}

/// Model cho chi tiết đơn hàng
class OrderDetail extends Equatable {
  final String orderId;
  final String orderNumber;
  final OrderStatus status;
  final String shopName;
  final String shopAvatar;
  final List<OrderDetailItem> items;
  final String pickupAddress;
  final String deliveryAddress;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? note;

  const OrderDetail({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.shopName,
    required this.shopAvatar,
    required this.items,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.orderDate,
    this.deliveryDate,
    this.note,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderDetail copyWith({
    String? orderId,
    String? orderNumber,
    OrderStatus? status,
    String? shopName,
    String? shopAvatar,
    List<OrderDetailItem>? items,
    String? pickupAddress,
    String? deliveryAddress,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? total,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? note,
  }) {
    return OrderDetail(
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      shopName: shopName ?? this.shopName,
      shopAvatar: shopAvatar ?? this.shopAvatar,
      items: items ?? this.items,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        status,
        shopName,
        shopAvatar,
        items,
        pickupAddress,
        deliveryAddress,
        subtotal,
        shippingFee,
        discount,
        total,
        orderDate,
        deliveryDate,
        note,
      ];
}

/// Model cho item trong đơn hàng
class OrderDetailItem extends Equatable {
  final String productId;
  final String productName;
  final String productImage;
  final double weight;
  final String unit;
  final double price;
  final int quantity;
  final double totalPrice;

  const OrderDetailItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.weight,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        productImage,
        weight,
        unit,
        price,
        quantity,
        totalPrice,
      ];
}
