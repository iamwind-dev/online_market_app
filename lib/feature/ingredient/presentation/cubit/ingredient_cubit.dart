import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_market_app/feature/ingredient/presentation/cubit/ingredient_state.dart';

/// Cubit quản lý state cho Ingredient Screen
class IngredientCubit extends Cubit<IngredientState> {
  IngredientCubit() : super(const IngredientInitial());

  /// Load dữ liệu ban đầu
  void loadIngredientData() {
    emit(const IngredientLoading());

    // Mock data - trong thực tế sẽ fetch từ API/repository
    final categories = [
      const Category(
        name: 'Rau củ',
        imagePath: 'assets/img/ingredient_category_rau_cu.png',
      ),
      const Category(
        name: 'Trái cây',
        imagePath: 'assets/img/ingredient_category_trai_cay-2bc751.png',
      ),
      const Category(
        name: 'Thịt',
        imagePath: 'assets/img/ingredient_category_thit.png',
      ),
      const Category(
        name: 'Thuỷ sản',
        imagePath: 'assets/img/ingredient_category_thuy_san-42d575.png',
      ),
      const Category(
        name: 'Bánh kẹo',
        imagePath: 'assets/img/ingredient_category_banh_keo-512c43.png',
      ),
    ];

    final additionalCategories = [
      const Category(
        name: 'Dưỡng thể',
        imagePath: 'assets/img/ingredient_category_duong_the.png',
      ),
      const Category(
        name: 'Gia vị',
        imagePath: 'assets/img/ingredient_category_gia_vi-122bd9.png',
      ),
      const Category(
        name: 'Sữa các loại',
        imagePath: 'assets/img/ingredient_category_sua-b32339.png',
      ),
      const Category(
        name: 'Đồ uống',
        imagePath: 'assets/img/ingredient_category_do_uong.png',
      ),
    ];

    final products = [
      const Product(
        name: 'TRỨNG GÀ CÔNG NGHIỆP VỈ 30 QUẢ',
        price: '48.000đ',
        imagePath: 'assets/img/ingredient_product_2-46bf93.png',
        shopName: 'Cô Hồng',
        badge: 'Flash sale',
        hasDiscount: true,
        originalPrice: '59.000đ',
      ),
      const Product(
        name: 'CÁNH GÀ CÔNG NGHIỆP ĐÔNG LẠNH VFOOD CHẤT LƯỢNG',
        price: '59.000đ',
        imagePath: 'assets/img/ingredient_product_1.png',
        shopName: 'Cô Hồng',
        badge: 'Đang bán chạy',
      ),
      const Product(
        name: 'CÁNH GÀ CÔNG NGHIỆP ĐÔNG LẠNH VFOOD CHẤT LƯỢNG',
        price: '19.000đ',
        imagePath: 'assets/img/ingredient_product_1.png',
        shopName: 'Cô Như',
        badge: 'Đã bán 129',
      ),
      const Product(
        name: 'SOCOLA ĐEN COMPOUND DẠNG KEM QUE 8CM',
        price: '143.000đ',
        imagePath: 'assets/img/ingredient_product_1.png',
        shopName: 'Cô Nhi',
        badge: 'Đã bán 56',
      ),
    ];

    final shopNames = ['Cô Hồng', 'Cô Như', 'Cô Nhi'];

    emit(IngredientLoaded(
      categories: categories,
      additionalCategories: additionalCategories,
      products: products,
      shopNames: shopNames,
    ));
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Perform search
  void performSearch() {
    if (state is IngredientLoaded) {
      // Implement search logic here
      // For now, just keep the current state
    }
  }

  /// Select category
  void selectCategory(String categoryName) {
    // Navigate to category detail or filter products
  }

  /// Change bottom navigation index
  void changeBottomNavIndex(int index) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(currentState.copyWith(selectedBottomNavIndex: index));
    }
  }

  /// Navigate to filter
  void navigateToFilter() {
    // Navigation will be handled by screen
  }

  /// Buy product now
  void buyNow(Product product) {
    // Implement buy now logic
  }
}
