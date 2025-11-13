import 'package:equatable/equatable.dart';

/// Base state for Ingredient Screen
abstract class IngredientState extends Equatable {
  const IngredientState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class IngredientInitial extends IngredientState {
  const IngredientInitial();
}

/// Loading state
class IngredientLoading extends IngredientState {
  const IngredientLoading();
}

/// Loaded state
class IngredientLoaded extends IngredientState {
  final String selectedMarket;
  final String searchQuery;
  final List<Category> categories;
  final List<Category> additionalCategories;
  final List<Product> products;
  final List<String> shopNames;
  final int selectedBottomNavIndex;

  const IngredientLoaded({
    this.selectedMarket = 'CHỢ BẮC MỸ AN',
    this.searchQuery = '',
    this.categories = const [],
    this.additionalCategories = const [],
    this.products = const [],
    this.shopNames = const [],
    this.selectedBottomNavIndex = 1,
  });

  IngredientLoaded copyWith({
    String? selectedMarket,
    String? searchQuery,
    List<Category>? categories,
    List<Category>? additionalCategories,
    List<Product>? products,
    List<String>? shopNames,
    int? selectedBottomNavIndex,
  }) {
    return IngredientLoaded(
      selectedMarket: selectedMarket ?? this.selectedMarket,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
      additionalCategories: additionalCategories ?? this.additionalCategories,
      products: products ?? this.products,
      shopNames: shopNames ?? this.shopNames,
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }

  @override
  List<Object?> get props => [
        selectedMarket,
        searchQuery,
        categories,
        additionalCategories,
        products,
        shopNames,
        selectedBottomNavIndex,
      ];
}

/// Error state
class IngredientError extends IngredientState {
  final String message;

  const IngredientError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Category model
class Category extends Equatable {
  final String name;
  final String imagePath;

  const Category({
    required this.name,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [name, imagePath];
}

/// Product model
class Product extends Equatable {
  final String name;
  final String price;
  final String imagePath;
  final String shopName;
  final String? badge;
  final bool hasDiscount;
  final String? originalPrice;

  const Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.shopName,
    this.badge,
    this.hasDiscount = false,
    this.originalPrice,
  });

  @override
  List<Object?> get props => [
        name,
        price,
        imagePath,
        shopName,
        badge,
        hasDiscount,
        originalPrice,
      ];
}
