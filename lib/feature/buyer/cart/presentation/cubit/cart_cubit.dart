import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/services/cart_api_service.dart';

part 'cart_state.dart';

/// Cart Cubit quản lý logic nghiệp vụ của giỏ hàng
class CartCubit extends Cubit<CartState> {
  List<CartItem> _cartItems = [];
  Set<String> _selectedItemIds = {};
  
  CartCubit() : super(CartInitial());

  Future<void> loadCart() async {
    if (AppConfig.enableApiLogging) AppLogger.info('🎯 [CART] Bắt đầu tải giỏ hàng');

    try {
      emit(CartLoading());
      final cartApiService = CartApiService();
      final cartResponse = await cartApiService.getCart();
      
      if (isClosed) return;
      
      _cartItems = cartResponse.items.map((item) {
        if (AppConfig.enableApiLogging) {
          AppLogger.info('🛒 [CART] Item: maNguyenLieu=${item.maNguyenLieu}, maGianHang=${item.maGianHang}');
        }
        return CartItem(
          id: '${item.maNguyenLieu}_${item.maGianHang}',
          productId: item.maNguyenLieu,
          shopId: item.maGianHang,
          shopName: item.tenGianHang,
          productName: item.tenNguyenLieu,
          productImage: item.hinhAnh ?? '',
          price: item.giaCuoi,
          quantity: item.soLuong,
          isSelected: false,
        );
      }).toList();
      
      final totalAmount = _calculateTotalAmount();

      if (AppConfig.enableApiLogging) {
        AppLogger.info('✅ [CART] Tải thành công ${_cartItems.length} sản phẩm');
        AppLogger.info('💰 [CART] Tổng tiền từ API: ${cartResponse.cart.tongTien}đ');
      }

      emit(CartLoaded(
        items: _cartItems,
        totalAmount: totalAmount,
        selectedItemIds: _selectedItemIds,
        apiTotalAmount: cartResponse.cart.tongTien,
        orderCode: cartResponse.cart.maDonHang,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) AppLogger.error('❌ [CART] Lỗi khi tải giỏ hàng: ${e.toString()}');
      if (!isClosed) emit(CartFailure(errorMessage: 'Không thể tải giỏ hàng: ${e.toString()}'));
    }
  }

  void toggleItemSelection(String itemId) {
    if (AppConfig.enableApiLogging) AppLogger.info('🔘 [CART] Toggle selection cho item: $itemId');

    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }

    _cartItems = _cartItems.map((item) {
      if (item.id == itemId) return item.copyWith(isSelected: !item.isSelected);
      return item;
    }).toList();

    emit(CartLoaded(items: _cartItems, totalAmount: _calculateTotalAmount(), selectedItemIds: _selectedItemIds));
  }

  void toggleSelectAll() {
    if (AppConfig.enableApiLogging) AppLogger.info('🔘 [CART] Toggle select all');

    final allSelected = _selectedItemIds.length == _cartItems.length;

    if (allSelected) {
      _selectedItemIds.clear();
      _cartItems = _cartItems.map((item) => item.copyWith(isSelected: false)).toList();
    } else {
      _selectedItemIds = _cartItems.map((item) => item.id).toSet();
      _cartItems = _cartItems.map((item) => item.copyWith(isSelected: true)).toList();
    }

    emit(CartLoaded(items: _cartItems, totalAmount: _calculateTotalAmount(), selectedItemIds: _selectedItemIds));
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) { await removeItem(itemId); return; }
    if (AppConfig.enableApiLogging) AppLogger.info('🔢 [CART] Cập nhật số lượng item $itemId: $newQuantity');

    try {
      emit(CartUpdating());
      await Future.delayed(const Duration(milliseconds: 300));

      _cartItems = _cartItems.map((item) {
        if (item.id == itemId) return item.copyWith(quantity: newQuantity);
        return item;
      }).toList();

      emit(CartLoaded(items: _cartItems, totalAmount: _calculateTotalAmount(), selectedItemIds: _selectedItemIds));
    } catch (e) {
      if (AppConfig.enableApiLogging) AppLogger.error('❌ [CART] Lỗi khi cập nhật số lượng: ${e.toString()}');
      emit(CartFailure(errorMessage: 'Không thể cập nhật số lượng: ${e.toString()}'));
    }
  }

  Future<void> removeItem(String itemId) async {
    if (AppConfig.enableApiLogging) AppLogger.info('🗑️ [CART] Xóa item: $itemId');

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _cartItems = _cartItems.where((item) => item.id != itemId).toList();
      _selectedItemIds.remove(itemId);

      emit(CartItemRemoved());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(CartLoaded(items: _cartItems, totalAmount: _calculateTotalAmount(), selectedItemIds: _selectedItemIds));
    } catch (e) {
      if (AppConfig.enableApiLogging) AppLogger.error('❌ [CART] Lỗi khi xóa sản phẩm: ${e.toString()}');
      emit(CartFailure(errorMessage: 'Không thể xóa sản phẩm: ${e.toString()}'));
    }
  }

  Future<String?> checkout() async {
    if (_selectedItemIds.isEmpty) {
      emit(const CartFailure(errorMessage: 'Vui lòng chọn ít nhất một sản phẩm để thanh toán'));
      return null;
    }

    if (AppConfig.enableApiLogging) AppLogger.info('💳 [CART] Bắt đầu thanh toán ${_selectedItemIds.length} sản phẩm');

    try {
      emit(CartCheckoutInProgress());

      final selectedItems = _cartItems
          .where((item) => _selectedItemIds.contains(item.id))
          .map((item) => {'ma_nguyen_lieu': item.productId, 'ma_gian_hang': item.shopId ?? ''})
          .toList();

      if (AppConfig.enableApiLogging) AppLogger.info('💳 [CART] Selected items: $selectedItems');

      final cartApiService = CartApiService();
      final checkoutResponse = await cartApiService.checkout(selectedItems: selectedItems);

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🎉 [CART] Checkout thành công! Mã đơn hàng: ${checkoutResponse.maDonHang}');
      }

      emit(const CartCheckoutSuccess(message: '✅ Đặt hàng thành công!'));
      return checkoutResponse.maDonHang;
    } catch (e) {
      if (AppConfig.enableApiLogging) AppLogger.error('❌ [CART] Lỗi khi thanh toán: ${e.toString()}');
      emit(CartFailure(errorMessage: 'Không thể thanh toán: ${e.toString()}'));
      return null;
    }
  }

  double _calculateTotalAmount() {
    return _cartItems.where((item) => _selectedItemIds.contains(item.id)).fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get selectedItemCount => _selectedItemIds.length;
  int get totalItemCount => _cartItems.length;
  bool get isAllSelected => _selectedItemIds.length == _cartItems.length && _cartItems.isNotEmpty;

  void resetState() {
    _cartItems.clear();
    _selectedItemIds.clear();
    emit(CartInitial());
  }
}
