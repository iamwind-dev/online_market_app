import 'package:equatable/equatable.dart';

/// Base state class for SearchResult feature
abstract class SearchResultState extends Equatable {
  const SearchResultState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class SearchResultInitial extends SearchResultState {}

/// State while loading search results
class SearchResultLoading extends SearchResultState {}

/// State when search results are successfully loaded
class SearchResultLoaded extends SearchResultState {
  final String searchQuery;
  final String selectedMarket;
  final String selectedLocation;
  final List<SearchResultProduct> products;
  final int selectedBottomNavIndex;

  const SearchResultLoaded({
    this.searchQuery = '',
    this.selectedMarket = 'MM, ĐÀ NẴNG',
    this.selectedLocation = 'Chợ Bắc Mỹ An',
    this.products = const [],
    this.selectedBottomNavIndex = 0,
  });

  SearchResultLoaded copyWith({
    String? searchQuery,
    String? selectedMarket,
    String? selectedLocation,
    List<SearchResultProduct>? products,
    int? selectedBottomNavIndex,
  }) {
    return SearchResultLoaded(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMarket: selectedMarket ?? this.selectedMarket,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      products: products ?? this.products,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        selectedMarket,
        selectedLocation,
        products,
        selectedBottomNavIndex,
      ];
}

/// State when an error occurs
class SearchResultError extends SearchResultState {
  final String message;

  const SearchResultError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Model for search result product
class SearchResultProduct extends Equatable {
  final String name;
  final String price;
  final String salesCount;
  final String shopName;
  final String imagePath;
  final String? badge; // Optional badge like "Đang bán chạy"
  final bool isHighlighted; // Whether product has special background color

  const SearchResultProduct({
    required this.name,
    required this.price,
    required this.salesCount,
    required this.shopName,
    required this.imagePath,
    this.badge,
    this.isHighlighted = false,
  });

  @override
  List<Object?> get props => [
        name,
        price,
        salesCount,
        shopName,
        imagePath,
        badge,
        isHighlighted,
      ];
}
