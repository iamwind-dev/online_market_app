import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/services/cart_api_service.dart';

part 'cart_state.dart';

/// Cart Cubit quản lý logic nghiệp vụ của giỏ hàng
/// 
/// Chức năng chính:
/// - Tải danh sách sản phẩm trong giỏ hàng
/// - Thêm/xóa/cập nhật sản phẩm
/// - Chọn/bỏ chọn sản phẩm
/// - Tính toán tổng tiền
/// - Xử lý thanh toán
class CartCubit extends Cubit<CartState> {
  List<CartItem> _cartItems = [];
  Set<String> _selectedItemIds = {};
  
  CartCubit() : super(CartInitial());

  /// Tải giỏ hàng
  Future<void> loadCart() async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🎯 [CART] Bắt đầu tải giỏ hàng');
    }

    try {
      emit(CartLoading());

      // Gọi API để lấy giỏ hàng
      final cartApiService = CartApiService();
      final cartResponse = await cartApiService.getCart();
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      // Convert API response to CartItem list
      _cartItems = cartResponse.items.map((item) {
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
        AppLogger.info('💰 [CART] Tổng tiền tính toán: $totalAmount đ');
      }

      emit(CartLoaded(
        items: _cartItems,
        totalAmount: totalAmount,
        selectedItemIds: _selectedItemIds,
        apiTotalAmount: cartResponse.cart.tongTien,
        orderCode: cartResponse.cart.maDonHang,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [CART] Lỗi khi tải giỏ hàng: ${e.toString()}');
      }
      if (!isClosed) {
        emit(CartFailure(
          errorMessage: 'Không thể tải giỏ hàng: ${e.toString()}',
        ));
      }
    }
  }

  /// Toggle chọn/bỏ chọn một item
  void toggleItemSelection(String itemId) {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🔘 [CART] Toggle selection cho item: $itemId');
    }

    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }

    // Update item's isSelected status
    _cartItems = _cartItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();

    final totalAmount = _calculateTotalAmount();

    emit(CartLoaded(
      items: _cartItems,
      totalAmount: totalAmount,
      selectedItemIds: _selectedItemIds,
    ));
  }

  /// Toggle chọn/bỏ chọn tất cả
  void toggleSelectAll() {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🔘 [CART] Toggle select all');
    }

    final allSelected = _selectedItemIds.length == _cartItems.length;

    if (allSelected) {
      _selectedItemIds.clear();
      _cartItems = _cartItems.map((item) => item.copyWith(isSelected: false)).toList();
    } else {
      _selectedItemIds = _cartItems.map((item) => item.id).toSet();
      _cartItems = _cartItems.map((item) => item.copyWith(isSelected: true)).toList();
    }

    final totalAmount = _calculateTotalAmount();

    emit(CartLoaded(
      items: _cartItems,
      totalAmount: totalAmount,
      selectedItemIds: _selectedItemIds,
    ));
  }

  /// Cập nhật số lượng sản phẩm
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(itemId);
      return;
    }

    if (AppConfig.enableApiLogging) {
      AppLogger.info('🔢 [CART] Cập nhật số lượng item $itemId: $newQuantity');
    }

    try {
      emit(CartUpdating());

      // TODO: Gọi API để cập nhật số lượng
      // await _cartRepository.updateQuantity(itemId, newQuantity);
      
      await Future.delayed(const Duration(milliseconds: 300));

      _cartItems = _cartItems.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).toList();

      final totalAmount = _calculateTotalAmount();

      emit(CartLoaded(
        items: _cartItems,
        totalAmount: totalAmount,
        selectedItemIds: _selectedItemIds,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [CART] Lỗi khi cập nhật số lượng: ${e.toString()}');
      }
      emit(CartFailure(
        errorMessage: 'Không thể cập nhật số lượng: ${e.toString()}',
      ));
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeItem(String itemId) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🗑️ [CART] Xóa item: $itemId');
    }

    try {
      // Tìm item để lấy maNguyenLieu và maGianHang
      final itemToDelete = _cartItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Item not found: $itemId'),
      );

      // Gọi API xóa item
      final cartApiService = CartApiService();
      final deleteResponse = await cartApiService.deleteCartItem(
        maNguyenLieu: itemToDelete.productId,
        maGianHang: itemToDelete.shopId ?? '',
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('✅ [CART] Xóa item thành công');
        AppLogger.info('   Tổng tiền sau xóa: ${deleteResponse.tongTien}');
        AppLogger.info('   Tiết kiệm: ${deleteResponse.tietKiem}');
      }

      // Xóa item khỏi list
      _cartItems = _cartItems.where((item) => item.id != itemId).toList();
      _selectedItemIds.remove(itemId);

      final totalAmount = _calculateTotalAmount();

      emit(CartItemRemoved());

      await Future.delayed(const Duration(milliseconds: 500));

      emit(CartLoaded(
        items: _cartItems,
        totalAmount: totalAmount,
        selectedItemIds: _selectedItemIds,
        apiTotalAmount: deleteResponse.tongTien,
        orderCode: deleteResponse.maDonHang,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [CART] Lỗi khi xóa sản phẩm: ${e.toString()}');
      }
      emit(CartFailure(
        errorMessage: 'Không thể xóa sản phẩm: ${e.toString()}',
      ));
    }
  }

  /// Xử lý thanh toán - gọi API checkout và trả về mã đơn hàng
  Future<String?> checkout() async {
    if (_selectedItemIds.isEmpty) {
      emit(const CartFailure(
        errorMessage: 'Vui lòng chọn ít nhất một sản phẩm để thanh toán',
      ));
      return null;
    }

    if (AppConfig.enableApiLogging) {
      AppLogger.info('💳 [CART] Bắt đầu thanh toán ${_selectedItemIds.length} sản phẩm');
    }

    try {
      emit(CartCheckoutInProgress());

      // Lấy danh sách items đã chọn
      final selectedItems = _cartItems
          .where((item) => _selectedItemIds.contains(item.id))
          .map((item) => {
                'ma_nguyen_lieu': item.productId,
                'ma_gian_hang': item.shopId ?? '',
              })
          .toList();

      if (AppConfig.enableApiLogging) {
        AppLogger.info('💳 [CART] Selected items: $selectedItems');
      }

      // Gọi API checkout
      final cartApiService = CartApiService();
      final checkoutResponse = await cartApiService.checkout(
        selectedItems: selectedItems,
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🎉 [CART] Checkout thành công!');
        AppLogger.info('   Mã đơn hàng: ${checkoutResponse.maDonHang}');
        AppLogger.info('   Tổng tiền: ${checkoutResponse.tongTien}');
        AppLogger.info('   Items checkout: ${checkoutResponse.itemsCheckout}');
        AppLogger.info('   Items remaining: ${checkoutResponse.itemsRemaining}');
      }

      // Emit success state
      emit(const CartCheckoutSuccess(
        message: '✅ Đặt hàng thành công!',
      ));

      // Return mã đơn hàng để navigate sang payment page
      return checkoutResponse.maDonHang;
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [CART] Lỗi khi thanh toán: ${e.toString()}');
      }
      emit(CartFailure(
        errorMessage: 'Không thể thanh toán: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Tính tổng tiền của các sản phẩm đã chọn
  double _calculateTotalAmount() {
    return _cartItems
        .where((item) => _selectedItemIds.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get số lượng sản phẩm đã chọn
  int get selectedItemCount => _selectedItemIds.length;

  /// Get tổng số sản phẩm
  int get totalItemCount => _cartItems.length;

  /// Check xem đã chọn hết chưa
  bool get isAllSelected => _selectedItemIds.length == _cartItems.length && _cartItems.isNotEmpty;

  /// Reset state về initial
  void resetState() {
    _cartItems.clear();
    _selectedItemIds.clear();
    emit(CartInitial());
  }
}
