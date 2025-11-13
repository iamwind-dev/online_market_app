import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  /// Load trang sản phẩm
  void loadProductData() {
    emit(ProductLoading());
    
    // Simulate loading - trong thực tế có thể load data từ API
    emit(const ProductLoaded());
  }

  /// Chọn danh mục sản phẩm
  void selectCategory(String category) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  /// Cập nhật search query
  void updateSearchQuery(String query) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Tìm kiếm sản phẩm
  void performSearch() {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      print('Searching for: ${currentState.searchQuery}');
      // Implement search logic here
    }
  }

  /// Toggle filter (Công thức, Món ngon, Yêu thích)
  void toggleFilter(String filterName) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final filters = List<String>.from(currentState.selectedFilters);
      
      if (filters.contains(filterName)) {
        filters.remove(filterName);
      } else {
        filters.add(filterName);
      }
      
      emit(currentState.copyWith(selectedFilters: filters));
    }
  }

  /// Thay đổi bottom nav index
  void changeBottomNavIndex(int index) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(selectedBottomNavIndex: index));
    }
  }

  /// Xem chi tiết sản phẩm
  void viewProductDetail(String productId) {
    print('View product detail: $productId');
    // Navigate to product detail screen
  }

  /// Thêm/bỏ yêu thích
  void toggleFavorite(String productId) {
    print('Toggle favorite for product: $productId');
    // Implement favorite logic
  }

  /// Mở bộ lọc
  void openFilterDialog() {
    print('Open filter dialog');
    // Show filter dialog
  }
}
