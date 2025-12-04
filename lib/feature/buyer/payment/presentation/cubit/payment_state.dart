part of 'payment_cubit.dart';

/// Base class cho tất cả các state của Payment
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// State khởi tạo ban đầu
class PaymentInitial extends PaymentState {}

/// State đang tải thông tin thanh toán
class PaymentLoading extends PaymentState {}

/// State tải thông tin thành công
class PaymentLoaded extends PaymentState {
  final OrderSummary orderSummary;
  final PaymentMethod selectedPaymentMethod;
  final String? orderCode; // Mã đơn hàng từ checkout

  const PaymentLoaded({
    required this.orderSummary,
    required this.selectedPaymentMethod,
    this.orderCode,
  });

  @override
  List<Object?> get props => [orderSummary, selectedPaymentMethod, orderCode];

  PaymentLoaded copyWith({
    OrderSummary? orderSummary,
    PaymentMethod? selectedPaymentMethod,
    String? orderCode,
  }) {
    return PaymentLoaded(
      orderSummary: orderSummary ?? this.orderSummary,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      orderCode: orderCode ?? this.orderCode,
    );
  }
}

/// State đang xử lý thanh toán
class PaymentProcessing extends PaymentState {}

/// State thanh toán thành công
class PaymentSuccess extends PaymentState {
  final String message;
  final String orderId;

  const PaymentSuccess({
    required this.message,
    required this.orderId,
  });

  @override
  List<Object?> get props => [message, orderId];
}

/// State thanh toán thất bại
class PaymentFailure extends PaymentState {
  final String errorMessage;

  const PaymentFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Enum cho phương thức thanh toán
enum PaymentMethod {
  cashOnDelivery,
  vnpay,
}

/// Model cho OrderSummary
class OrderSummary {
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final String estimatedDelivery;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double total;

  const OrderSummary({
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.estimatedDelivery,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      estimatedDelivery: json['estimatedDelivery'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'estimatedDelivery': estimatedDelivery,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
    };
  }

  int get totalItemCount => items.length;
}

/// Model cho OrderItem
class OrderItem {
  final String id;
  final String shopName;
  final String productName;
  final String productImage;
  final double price;
  final double weight;
  final String unit;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.shopName,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.weight,
    this.unit = 'KG',
    this.quantity = 1,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      shopName: json['shopName'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'KG',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'weight': weight,
      'unit': unit,
      'quantity': quantity,
    };
  }

  double get totalPrice => price * quantity;
}
