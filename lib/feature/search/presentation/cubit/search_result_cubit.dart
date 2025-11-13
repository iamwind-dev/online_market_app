import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_result_state.dart';

/// Cubit for managing SearchResult screen state and business logic
class SearchResultCubit extends Cubit<SearchResultState> {
  SearchResultCubit() : super(SearchResultInitial());

  /// Load search results with products
  Future<void> loadSearchResults({String query = 'Cá'}) async {
    emit(SearchResultLoading());

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data for search results
      final products = [
        const SearchResultProduct(
          name: 'Cá diêu hồng',
          price: '94,000 ₫ / Ký',
          salesCount: '106 lượt bán',
          shopName: 'Cô Hồng',
          imagePath: 'assets/img/search_result_product_1.png',
          isHighlighted: false,
        ),
        const SearchResultProduct(
          name: 'Cá chét tươi',
          price: '80,000 ₫ / Ký',
          salesCount: '16 lượt bán',
          shopName: 'Cô Sen',
          imagePath: 'assets/img/search_result_product_1.png',
          isHighlighted: false,
        ),
        const SearchResultProduct(
          name: 'Cá cờ gòn, 500g',
          price: '91,000 ₫ / Gói',
          salesCount: '186 lượt bán',
          shopName: 'Cô Như',
          imagePath: 'assets/img/search_result_product_1.png',
          isHighlighted: false,
        ),
        const SearchResultProduct(
          name: 'Đầu cá hồi nhập khẩu, 300g..',
          price: '59,000 ₫ / Ký',
          salesCount: '196 lượt bán',
          shopName: 'Cô Nhi',
          imagePath: 'assets/img/search_result_product_2.png',
          isHighlighted: false,
        ),
        const SearchResultProduct(
          name: 'Xúc xích Bò BBQ – San Mi...',
          price: '47.000đ',
          salesCount: '106 lượt bán',
          shopName: 'Cô Hồng',
          imagePath: 'assets/img/search_result_product_1.png',
          badge: 'Đang bán chạy',
          isHighlighted: true,
        ),
        const SearchResultProduct(
          name: 'Xúc Xích Bò Chorizo Premi...',
          price: '63.000đ',
          salesCount: '56 lượt bán',
          shopName: 'Cô Sen',
          imagePath: 'assets/img/search_result_product_2.png',
          badge: 'Đang bán chạy',
          isHighlighted: true,
        ),
      ];

      emit(SearchResultLoaded(
        searchQuery: query,
        selectedMarket: 'MM, ĐÀ NẴNG',
        selectedLocation: 'Chợ Bắc Mỹ An',
        products: products,
        selectedBottomNavIndex: 0,
      ));
    } catch (e) {
      emit(SearchResultError('Failed to load search results: $e'));
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (state is SearchResultLoaded) {
      emit((state as SearchResultLoaded).copyWith(searchQuery: query));
    }
  }

  /// Quick add item to cart
  void quickAddItem(String productName) {
    print('Quick adding item: $productName');
    // In a real app, this would add the item to cart
  }

  /// Navigate to product detail
  void navigateToProductDetail(SearchResultProduct product) {
    print('Navigating to product: ${product.name}');
    // In a real app, this would navigate to product detail screen
  }

  /// Navigate to filter screen
  void navigateToFilter() {
    print('Navigating to filter');
    // In a real app, this would navigate to filter screen
  }

  /// Handle market/location selection
  void selectMarketLocation(String market, String location) {
    if (state is SearchResultLoaded) {
      emit((state as SearchResultLoaded).copyWith(
        selectedMarket: market,
        selectedLocation: location,
      ));
    }
  }

  /// Handle bottom navigation bar item tap
  void changeBottomNavIndex(int index) {
    if (state is SearchResultLoaded) {
      emit((state as SearchResultLoaded).copyWith(selectedBottomNavIndex: index));
    }
  }

  /// Navigate back
  void navigateBack() {
    print('Navigating back');
    // In a real app, this would pop the navigation stack
  }
}
