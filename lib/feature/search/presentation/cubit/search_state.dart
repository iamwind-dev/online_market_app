import 'package:equatable/equatable.dart';

/// Base state class for Search feature
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class SearchInitial extends SearchState {}

/// State while loading search data
class SearchLoading extends SearchState {}

/// State when search data is successfully loaded
class SearchLoaded extends SearchState {
  final String searchQuery;
  final List<String> searchHistory;
  final List<String> quickAddItems;
  final List<Product> recommendedProducts;
  final int selectedBottomNavIndex;

  const SearchLoaded({
    this.searchQuery = '',
    this.searchHistory = const [],
    this.quickAddItems = const [],
    this.recommendedProducts = const [],
    this.selectedBottomNavIndex = 0,
  });

  SearchLoaded copyWith({
    String? searchQuery,
    List<String>? searchHistory,
    List<String>? quickAddItems,
    List<Product>? recommendedProducts,
    int? selectedBottomNavIndex,
  }) {
    return SearchLoaded(
      searchQuery: searchQuery ?? this.searchQuery,
      searchHistory: searchHistory ?? this.searchHistory,
      quickAddItems: quickAddItems ?? this.quickAddItems,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        searchHistory,
        quickAddItems,
        recommendedProducts,
        selectedBottomNavIndex,
      ];
}

/// State when an error occurs
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Model for recommended product
class Product extends Equatable {
  final String name;
  final String imagePath;

  const Product({
    required this.name,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [name, imagePath];
}
