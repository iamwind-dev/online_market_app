import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_state.dart';

class SellerOrderCubit extends Cubit<SellerOrderState> {
  SellerOrderCubit() : super(const SellerOrderState());

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final orders = [
        const SellerOrder(
          id: '1',
          orderId: '#DN12345',
          customerName: 'Phạm Thị Quỳnh Như',
          orderTime: 'Hôm nay, 9:36',
          items: '300g cà rốt, 1kg khoai lang, 500g bông cải xanh',
          amount: 150000,
          status: OrderStatus.pending,
        ),
        const SellerOrder(
          id: '2',
          orderId: '#DN12346',
          customerName: 'Phạm Vĩnh Tường',
          orderTime: 'Hôm nay, 9:36',
          items: '300g cà rốt, 1kg khoai lang, 500g bông cải xanh',
          amount: 150000,
          status: OrderStatus.delivering,
        ),
        const SellerOrder(
          id: '3',
          orderId: '#DN12346',
          customerName: 'Nguyễn Ngọc Phương Nhi',
          orderTime: 'Hôm nay, 9:36',
          items: '300g cà rốt, 1kg khoai lang, 500g bông cải xanh',
          amount: 150000,
          status: OrderStatus.completed,
        ),
      ];

      emit(state.copyWith(
        isLoading: false,
        orders: orders,
        totalToday: 1350000,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách đơn hàng',
      ));
    }
  }

  void confirmOrder(String orderId) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId && order.status == OrderStatus.pending) {
        return SellerOrder(
          id: order.id,
          orderId: order.orderId,
          customerName: order.customerName,
          orderTime: order.orderTime,
          items: order.items,
          amount: order.amount,
          status: OrderStatus.delivering,
        );
      }
      return order;
    }).toList();

    emit(state.copyWith(orders: updatedOrders));
  }

  void contactCustomer(String orderId) {
    // TODO: Implement contact customer logic
  }

  void setSelectedNavIndex(int index) {
    emit(state.copyWith(selectedNavIndex: index));
  }

  void navigateToHome() {
    // TODO: Navigate to home
  }

  void navigateToIngredient() {
    // TODO: Navigate to ingredient
  }

  void navigateToAnalytics() {
    // TODO: Navigate to analytics
  }

  void navigateToAccount() {
    // TODO: Navigate to account
  }
}
