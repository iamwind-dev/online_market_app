import 'package:equatable/equatable.dart';

/// Model đại diện cho một nguyên liệu/sản phẩm của người bán
class SellerIngredient extends Equatable {
  final String id;
  final String name;
  final double price;
  final String unit;
  final int availableQuantity;
  final String imageUrl;

  const SellerIngredient({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.availableQuantity,
    required this.imageUrl,
  });

  /// Format giá tiền
  String get formattedPrice {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$formatted ₫ / $unit';
  }

  @override
  List<Object?> get props => [id, name, price, unit, availableQuantity, imageUrl];
}

/// State chính của Seller Ingredient
class SellerIngredientState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<SellerIngredient> ingredients;
  final String searchQuery;
  final int currentTabIndex;

  const SellerIngredientState({
    this.isLoading = false,
    this.errorMessage,
    this.ingredients = const [],
    this.searchQuery = '',
    this.currentTabIndex = 1, // Tab Sản phẩm mặc định
  });

  /// Factory tạo state ban đầu
  factory SellerIngredientState.initial() {
    return const SellerIngredientState(isLoading: true);
  }

  /// Lọc danh sách theo search query
  List<SellerIngredient> get filteredIngredients {
    if (searchQuery.isEmpty) return ingredients;
    final query = searchQuery.toLowerCase();
    return ingredients.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);
    }).toList();
  }

  SellerIngredientState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SellerIngredient>? ingredients,
    String? searchQuery,
    int? currentTabIndex,
  }) {
    return SellerIngredientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      ingredients: ingredients ?? this.ingredients,
      searchQuery: searchQuery ?? this.searchQuery,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        ingredients,
        searchQuery,
        currentTabIndex,
      ];
}
