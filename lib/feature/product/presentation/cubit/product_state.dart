import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final String selectedCategory;
  final String searchQuery;
  final int selectedBottomNavIndex;
  final List<String> selectedFilters; // Bộ lọc: Công thức, Món ngon, Yêu thích

  const ProductLoaded({
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
    this.selectedBottomNavIndex = 1, // 1 = Sản phẩm tab
    this.selectedFilters = const [],
  });

  ProductLoaded copyWith({
    String? selectedCategory,
    String? searchQuery,
    int? selectedBottomNavIndex,
    List<String>? selectedFilters,
  }) {
    return ProductLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }

  @override
  List<Object?> get props =>
      [selectedCategory, searchQuery, selectedBottomNavIndex, selectedFilters];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
