import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_market_app/core/dependency/injection.dart';
import 'package:online_market_app/core/services/category_service.dart';
import 'package:online_market_app/core/services/mon_an_service.dart';
import 'package:online_market_app/core/services/auth/auth_service.dart';
import 'package:online_market_app/core/error/exceptions.dart';
import 'package:online_market_app/core/models/mon_an_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final CategoryService _categoryService = getIt<CategoryService>();
  final MonAnService _monAnService = getIt<MonAnService>();

  ProductCubit() : super(ProductInitial());

  /// Load trang sản phẩm + fetch categories và món ăn từ API
  Future<void> loadProductData() async {
    emit(ProductLoading());
    
    try {
      // 1. Fetch categories từ API
      final categories = await _categoryService.getDanhMucMonAn(page: 1, limit: 20);
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      // 2. Fetch danh sách món ăn từ API
      final monAnList = await _monAnService.getMonAnList(page: 1, limit: 12);
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      // 3. Fetch chi tiết (ảnh) cho từng món ăn
      final monAnWithImages = await _fetchMonAnImages(monAnList);
      
      // Check if cubit is still open before emitting final state
      if (isClosed) return;
      
      // 4. Emit loaded state với categories và món ăn
      emit(ProductLoaded(
        categories: categories,
        monAnList: monAnWithImages,
      ));
    } on UnauthorizedException {
      // Token hết hạn - logout và yêu cầu đăng nhập lại
      final authService = getIt<AuthService>();
      await authService.logout();
      if (!isClosed) {
        emit(const ProductError(
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          requiresLogin: true,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ProductError('Lỗi khi tải dữ liệu: $e'));
      }
    }
  }

  /// Fetch ảnh cho danh sách món ăn
  /// 
  /// Gọi API detail cho từng món để lấy URL ảnh
  Future<List<MonAnWithImage>> _fetchMonAnImages(List<MonAnModel> monAnList) async {
    final result = <MonAnWithImage>[];
    
    for (final monAn in monAnList) {
      try {
        // Gọi API detail để lấy ảnh
        final detail = await _monAnService.getMonAnDetail(monAn.maMonAn);
        result.add(MonAnWithImage(
          monAn: monAn,
          imageUrl: detail.hinhAnh,
        ));
      } catch (e) {
        // Nếu lỗi, dùng ảnh mặc định hoặc bỏ qua
        print('Lỗi khi lấy ảnh cho món ${monAn.maMonAn}: $e');
        result.add(MonAnWithImage(
          monAn: monAn,
          imageUrl: '', // Ảnh mặc định hoặc để trống
        ));
      }
    }
    
    return result;
  }

  /// Chọn danh mục sản phẩm
  void selectCategory(String categoryId) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(selectedCategory: categoryId));
    }
  }

  /// Cập nhật search query
  void updateSearchQuery(String query) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Tìm kiếm sản phẩm
  void performSearch() {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      print('Searching for: ${currentState.searchQuery}');
      // Implement search logic here
    }
  }

  /// Toggle filter (Công thức, Món ngon, Yêu thích)
  void toggleFilter(String filterName) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final filters = List<String>.from(currentState.selectedFilters);
      
      if (filters.contains(filterName)) {
        filters.remove(filterName);
      } else {
        filters.add(filterName);
      }
      
      emit(currentState.copyWith(selectedFilters: filters));
    }
  }

  /// Thay đổi bottom nav index
  void changeBottomNavIndex(int index) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(selectedBottomNavIndex: index));
    }
  }

  /// Xem chi tiết sản phẩm
  void viewProductDetail(String productId) {
    print('View product detail: $productId');
    // Navigate to product detail screen
  }

  /// Thêm/bỏ yêu thích
  void toggleFavorite(String productId) {
    print('Toggle favorite for product: $productId');
    // Implement favorite logic
  }

  /// Mở bộ lọc
  void openFilterDialog() {
    print('Open filter dialog');
    // Show filter dialog
  }
}
