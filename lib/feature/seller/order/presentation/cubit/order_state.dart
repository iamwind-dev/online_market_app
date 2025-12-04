import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending, // Chờ xác nhận
  delivering, // Đang giao
  completed, // Hoàn tất
}

class SellerOrder extends Equatable {
  final String id;
  final String orderId;
  final String customerName;
  final String orderTime;
  final String items;
  final double amount;
  final OrderStatus status;

  const SellerOrder({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.orderTime,
    required this.items,
    required this.amount,
    required this.status,
  });

  @override
  List<Object?> get props => [id, orderId, customerName, orderTime, items, amount, status];
}

class SellerOrderState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<SellerOrder> orders;
  final double totalToday;
  final int selectedNavIndex;

  const SellerOrderState({
    this.isLoading = false,
    this.errorMessage,
    this.orders = const [],
    this.totalToday = 0,
    this.selectedNavIndex = 0,
  });

  SellerOrderState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SellerOrder>? orders,
    double? totalToday,
    int? selectedNavIndex,
  }) {
    return SellerOrderState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      orders: orders ?? this.orders,
      totalToday: totalToday ?? this.totalToday,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, orders, totalToday, selectedNavIndex];
}
