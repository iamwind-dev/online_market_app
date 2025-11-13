import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';

/// Cubit for managing Search screen state and business logic
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  /// Load initial search data with history and recommendations
  Future<void> loadSearchData() async {
    emit(SearchLoading());

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data for search history
      final searchHistory = [
        'Thịt gà VFOOD',
        'Xúc xích bò',
        'Kim chi Aquanf',
        'Nấm đông cô nấu lẩu',
        'Bắp cải tím',
      ];

      // Mock data for quick add items (same as search history)
      final quickAddItems = [
        'Thịt gà VFOOD',
        'Xúc xích bò',
        'Kim chi Aquanf',
        'Nấm đông cô nấu lẩu',
        'Bắp cải tím',
      ];

      // Mock data for recommended products
      final recommendedProducts = [
        const Product(
          name: 'Dưa cải chua ngọt King\'s cara nhà làm',
          imagePath: 'assets/img/search_product_1-4e14c3.png',
        ),
        const Product(
          name: 'Lốc 4 hộp sữa có đường Vinamilk ',
          imagePath: 'assets/img/search_product_2-66e6e5.png',
        ),
        const Product(
          name: 'Cá trứng đông lạnh Choice đông lạnh',
          imagePath: 'assets/img/search_product_3-41d077.png',
        ),
      ];

      emit(SearchLoaded(
        searchQuery: 'Cá thu ',
        searchHistory: searchHistory,
        quickAddItems: quickAddItems,
        recommendedProducts: recommendedProducts,
        selectedBottomNavIndex: 0,
      ));
    } catch (e) {
      emit(SearchError('Failed to load search data: $e'));
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(searchQuery: query));
    }
  }

  /// Perform search with the current query
  void performSearch() {
    if (state is SearchLoaded) {
      final query = (state as SearchLoaded).searchQuery;
      final currentHistory = (state as SearchLoaded).searchHistory;
      
      // Add to search history if not empty
      if (query.isNotEmpty && !currentHistory.contains(query)) {
        final updatedHistory = [query, ...currentHistory].take(10).toList();
        
        emit((state as SearchLoaded).copyWith(
          searchHistory: updatedHistory,
        ));
      }

      // In a real app, this would trigger a search API call
      print('Performing search for: $query');
    }
  }

  /// Add item from search history to cart/quick add
  void quickAddItem(String item) {
    print('Quick adding item: $item');
    // In a real app, this would add the item to cart
  }

  /// Remove item from search history
  void removeFromHistory(String item) {
    if (state is SearchLoaded) {
      final updatedHistory = List<String>.from((state as SearchLoaded).searchHistory)
        ..remove(item);
      final updatedQuickAddItems =
          List<String>.from((state as SearchLoaded).quickAddItems)..remove(item);

      emit((state as SearchLoaded).copyWith(
        searchHistory: updatedHistory,
        quickAddItems: updatedQuickAddItems,
      ));
    }
  }

  /// Navigate to product detail
  void navigateToProductDetail(Product product) {
    print('Navigating to product: ${product.name}');
    // In a real app, this would navigate to product detail screen
  }

  /// Handle bottom navigation bar item tap
  void changeBottomNavIndex(int index) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(selectedBottomNavIndex: index));
    }
  }

  /// Navigate back
  void navigateBack() {
    print('Navigating back');
    // In a real app, this would pop the navigation stack
  }

  /// Execute search action (button press)
  void executeSearch() {
    if (state is SearchLoaded) {
      final query = (state as SearchLoaded).searchQuery;
      print('Executing search for: $query');
      // In a real app, this would trigger search and navigate to results
    }
  }
}
