import 'package:flutter_bloc/flutter_bloc.dart';
import 'ingredient_state.dart';

class SellerIngredientCubit extends Cubit<SellerIngredientState> {
  SellerIngredientCubit() : super(SellerIngredientState.initial());

  /// Khởi tạo và load danh sách nguyên liệu
  Future<void> loadIngredients() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data theo Figma design
      final mockIngredients = [
        const SellerIngredient(
          id: '1713091230134',
          name: 'Cá diêu hồng',
          price: 91000,
          unit: 'Ký',
          availableQuantity: 9,
          imageUrl: 'assets/img/seller_ingredient_fish1.png',
        ),
        const SellerIngredient(
          id: '1713091230135',
          name: 'Cá diêu hồng',
          price: 91000,
          unit: 'Ký',
          availableQuantity: 9,
          imageUrl: 'assets/img/seller_ingredient_fish2.png',
        ),
        const SellerIngredient(
          id: '1713091230136',
          name: 'Cá diêu hồng',
          price: 91000,
          unit: 'Ký',
          availableQuantity: 9,
          imageUrl: 'assets/img/seller_ingredient_fish2.png',
        ),
        const SellerIngredient(
          id: '1713091230137',
          name: 'Cá diêu hồng',
          price: 91000,
          unit: 'Ký',
          availableQuantity: 9,
          imageUrl: 'assets/img/seller_ingredient_fish2.png',
        ),
        const SellerIngredient(
          id: '1713091230138',
          name: 'Cá diêu hồng',
          price: 91000,
          unit: 'Ký',
          availableQuantity: 9,
          imageUrl: 'assets/img/seller_ingredient_fish2.png',
        ),
      ];

      emit(state.copyWith(
        isLoading: false,
        ingredients: mockIngredients,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách sản phẩm: ${e.toString()}',
      ));
    }
  }

  /// Cập nhật search query
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Thực hiện tìm kiếm
  void performSearch() {
    // Đã filter tự động qua getter filteredIngredients
    // Có thể thêm logic gọi API search ở đây nếu cần
  }

  /// Chuyển tab bottom navigation
  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  /// Điều hướng đến trang thêm sản phẩm
  void navigateToAddIngredient() {
    // TODO: Implement navigation
  }

  /// Điều hướng đến trang chỉnh sửa sản phẩm
  void navigateToEditIngredient(SellerIngredient ingredient) {
    // TODO: Implement navigation
  }

  /// Xóa sản phẩm
  Future<void> deleteIngredient(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedList = state.ingredients.where((item) => item.id != id).toList();
      emit(state.copyWith(ingredients: updatedList));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Không thể xóa sản phẩm: ${e.toString()}',
      ));
    }
  }

  /// Quay lại trang trước
  void goBack() {
    // TODO: Implement navigation back
  }

  /// Refresh dữ liệu
  Future<void> refreshData() async {
    await loadIngredients();
  }
}
