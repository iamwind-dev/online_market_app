import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_ingredient_state.dart';

class AddIngredientCubit extends Cubit<AddIngredientState> {
  AddIngredientCubit() : super(AddIngredientState.initial());

  /// Khởi tạo và load danh sách danh mục
  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock categories
      const mockCategories = [
        Category(id: '1', name: 'Rau củ'),
        Category(id: '2', name: 'Thịt'),
        Category(id: '3', name: 'Cá'),
        Category(id: '4', name: 'Hải sản'),
        Category(id: '5', name: 'Gia vị'),
        Category(id: '6', name: 'Trái cây'),
      ];

      emit(state.copyWith(
        isLoading: false,
        categories: mockCategories,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh mục: ${e.toString()}',
      ));
    }
  }

  /// Cập nhật tên sản phẩm
  void updateProductName(String name) {
    emit(state.copyWith(
      productName: name,
      isFormValid: _validateForm(name, state.imagePath, state.selectedCategory),
    ));
  }

  /// Cập nhật ảnh sản phẩm
  void updateImage(String? path) {
    emit(state.copyWith(
      imagePath: path,
      isFormValid: _validateForm(state.productName, path, state.selectedCategory),
    ));
  }

  /// Chọn danh mục
  void selectCategory(Category category) {
    emit(state.copyWith(
      selectedCategory: category,
      isFormValid: _validateForm(state.productName, state.imagePath, category),
    ));
  }

  /// Mở picker chọn ảnh
  Future<void> pickImage() async {
    // TODO: Implement image picker
    // Simulate selecting an image
    updateImage('assets/img/seller_add_ingredient_placeholder.png');
  }

  /// Validate form
  bool _validateForm(String name, String? imagePath, Category? category) {
    return name.length >= 15 && imagePath != null && category != null;
  }

  /// Đăng sản phẩm
  Future<void> submitProduct() async {
    if (!state.canSubmit) {
      emit(state.copyWith(
        errorMessage: 'Vui lòng điền đầy đủ thông tin sản phẩm',
      ));
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Đăng sản phẩm thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Không thể đăng sản phẩm: ${e.toString()}',
      ));
    }
  }

  /// Hủy bỏ
  void cancel() {
    // TODO: Navigate back
  }

  /// Quay lại
  void goBack() {
    // TODO: Navigate back
  }

  /// Chuyển tab bottom navigation
  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  /// Clear messages
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}
