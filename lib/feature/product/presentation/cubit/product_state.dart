import 'package:equatable/equatable.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/models/mon_an_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<CategoryModel> categories;
  final List<MonAnWithImage> monAnList; // Danh sách món ăn kèm URL ảnh
  final String selectedCategory;
  final String searchQuery;
  final int selectedBottomNavIndex;
  final List<String> selectedFilters; // Bộ lọc: Công thức, Món ngon, Yêu thích

  const ProductLoaded({
    this.categories = const [],
    this.monAnList = const [],
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
    this.selectedBottomNavIndex = 1, // 1 = Sản phẩm tab
    this.selectedFilters = const [],
  });

  ProductLoaded copyWith({
    List<CategoryModel>? categories,
    List<MonAnWithImage>? monAnList,
    String? selectedCategory,
    String? searchQuery,
    int? selectedBottomNavIndex,
    List<String>? selectedFilters,
  }) {
    return ProductLoaded(
      categories: categories ?? this.categories,
      monAnList: monAnList ?? this.monAnList,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }

  @override
  List<Object?> get props =>
      [categories, monAnList, selectedCategory, searchQuery, selectedBottomNavIndex, selectedFilters];
}

/// Model kết hợp món ăn với URL ảnh
class MonAnWithImage {
  final MonAnModel monAn;
  final String imageUrl; // URL ảnh từ API detail

  MonAnWithImage({
    required this.monAn,
    required this.imageUrl,
  });
}

class ProductError extends ProductState {
  final String message;
  final bool requiresLogin;

  const ProductError(this.message, {this.requiresLogin = false});

  @override
  List<Object?> get props => [message, requiresLogin];
}
