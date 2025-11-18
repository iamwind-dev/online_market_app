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
  final int currentPage; // Trang hiện tại
  final bool hasMore; // Còn dữ liệu để load không
  final bool isLoadingMore; // Đang load thêm dữ liệu

  const ProductLoaded({
    this.categories = const [],
    this.monAnList = const [],
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
    this.selectedBottomNavIndex = 1, // 1 = Sản phẩm tab
    this.selectedFilters = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ProductLoaded copyWith({
    List<CategoryModel>? categories,
    List<MonAnWithImage>? monAnList,
    String? selectedCategory,
    String? searchQuery,
    int? selectedBottomNavIndex,
    List<String>? selectedFilters,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductLoaded(
      categories: categories ?? this.categories,
      monAnList: monAnList ?? this.monAnList,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [categories, monAnList, selectedCategory, searchQuery, selectedBottomNavIndex, selectedFilters, currentPage, hasMore, isLoadingMore];
}

/// Model kết hợp món ăn với URL ảnh và thông tin chi tiết
class MonAnWithImage {
  final MonAnModel monAn;
  final String imageUrl; // URL ảnh từ API detail
  final int? cookTime; // Thời gian nấu (phút) - từ khoang_thoi_gian
  final String? difficulty; // Độ khó - từ do_kho
  final int? servings; // Số khẩu phần - từ khau_phan_tieu_chuan

  MonAnWithImage({
    required this.monAn,
    required this.imageUrl,
    this.cookTime,
    this.difficulty,
    this.servings,
  });
}

class ProductError extends ProductState {
  final String message;
  final bool requiresLogin;

  const ProductError(this.message, {this.requiresLogin = false});

  @override
  List<Object?> get props => [message, requiresLogin];
}
