import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:DNGO/core/dependency/injection.dart';
import 'package:DNGO/core/services/category_service.dart';
import 'package:DNGO/core/services/mon_an_service.dart';
import 'package:DNGO/core/services/auth/auth_service.dart';
import 'package:DNGO/core/services/khu_vuc_service.dart';
import 'package:DNGO/core/services/cho_service.dart';
import 'package:DNGO/core/error/exceptions.dart';
import 'package:DNGO/core/models/mon_an_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final CategoryService _categoryService = getIt<CategoryService>();
  final MonAnService _monAnService = getIt<MonAnService>();
  final KhuVucService _khuVucService = getIt<KhuVucService>();
  final ChoService _choService = getIt<ChoService>();

  ProductCubit() : super(ProductInitial());

  /// Load trang sản phẩm + fetch categories và món ăn từ API
  Future<void> loadProductData() async {
    emit(ProductLoading());
    
    try {
      // 1. Fetch categories từ API
      final categories = await _categoryService.getDanhMucMonAn(page: 1, limit: 20);
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      // 2. Fetch danh sách món ăn từ API (trang 1) với metadata
      final response = await _monAnService.getMonAnListWithMeta(
        page: 1,
        limit: 12,
        sort: 'ten_mon_an',
        order: 'asc',
      );
      
      // Check if cubit is still open before continuing
      if (isClosed) return;
      
      print('✅ [ProductCubit] Initial load: ${response.data.length} products');
      print('   Total: ${response.meta.total}, HasNext: ${response.meta.hasNext}');
      
      // 3. Fetch chi tiết (ảnh) cho từng món ăn
      final monAnWithImages = await _fetchMonAnImages(response.data);
      
      // Check if cubit is still open before emitting final state
      if (isClosed) return;
      
      // 4. Emit loaded state với categories và món ăn
      emit(ProductLoaded(
        categories: categories,
        monAnList: monAnWithImages,
        currentPage: 1,
        hasMore: response.meta.hasNext, // Dùng hasNext từ API
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

  /// Load thêm món ăn (pagination)
  Future<void> loadMoreProducts() async {
    // Chỉ load khi đang ở state ProductLoaded và không đang load
    if (state is! ProductLoaded) return;
    
    final currentState = state as ProductLoaded;
    
    // Nếu không còn data hoặc đang load thì return
    if (!currentState.hasMore || currentState.isLoadingMore) return;
    
    print('📄 [ProductCubit] Loading more products - page ${currentState.currentPage + 1}');
    
    // Emit state đang load more
    emit(currentState.copyWith(isLoadingMore: true));
    
    try {
      // Fetch trang tiếp theo
      final nextPage = currentState.currentPage + 1;
      final response = await _monAnService.getMonAnListWithMeta(
        page: nextPage,
        limit: 12,
        sort: 'ten_mon_an',
        order: 'asc',
      );
      
      // Check if cubit is still open
      if (isClosed) return;
      
      print('✅ [ProductCubit] Loaded ${response.data.length} products from page $nextPage');
      print('   Total: ${response.meta.total}, HasNext: ${response.meta.hasNext}');
      
      // Fetch ảnh cho món ăn mới
      final newMonAnWithImages = await _fetchMonAnImages(response.data);
      
      // Check if cubit is still open
      if (isClosed) return;
      
      // Merge danh sách cũ với danh sách mới
      final updatedList = [...currentState.monAnList, ...newMonAnWithImages];
      
      print('📊 [ProductCubit] Total products after merge: ${updatedList.length}');
      
      // Emit state mới với dữ liệu đã merge
      emit(currentState.copyWith(
        monAnList: updatedList,
        currentPage: nextPage,
        hasMore: response.meta.hasNext, // Dùng hasNext từ API
        isLoadingMore: false,
      ));
    } catch (e) {
      // Nếu lỗi, chỉ tắt loading indicator
      print('❌ [ProductCubit] Lỗi khi load thêm món ăn: $e');
      if (!isClosed && state is ProductLoaded) {
        emit((state as ProductLoaded).copyWith(isLoadingMore: false));
      }
    }
  }

  /// Fetch chi tiết (ảnh, thời gian nấu, độ khó, khẩu phần) cho danh sách món ăn
  /// 
  /// Gọi API detail cho từng món để lấy URL ảnh và thông tin chi tiết
  Future<List<MonAnWithImage>> _fetchMonAnImages(List<MonAnModel> monAnList) async {
    final result = <MonAnWithImage>[];
    
    for (final monAn in monAnList) {
      try {
        // Gọi API detail để lấy ảnh và thông tin chi tiết
        final detail = await _monAnService.getMonAnDetail(monAn.maMonAn);
        result.add(MonAnWithImage(
          monAn: monAn,
          imageUrl: detail.hinhAnh,
          cookTime: detail.khoangThoiGian ?? 40, // khoang_thoi_gian
          difficulty: detail.doKho ?? 'Dễ', // do_kho
          servings: detail.khauPhanTieuChuan ?? 4, // khau_phan_tieu_chuan
        ));
      } catch (e) {
        // Nếu lỗi, dùng giá trị mặc định
        print('Lỗi khi lấy chi tiết cho món ${monAn.maMonAn}: $e');
        result.add(MonAnWithImage(
          monAn: monAn,
          imageUrl: '',
          cookTime: 40,
          difficulty: 'Dễ',
          servings: 4,
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

  /// Thêm vào giỏ hàng
  void addToCart() {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(
        cartItemCount: currentState.cartItemCount + 1,
      ));
    }
  }

  /// Fetch danh sách khu vực từ API
  Future<void> fetchKhuVucList() async {
    if (state is! ProductLoaded) {
      print('⚠️ [ProductCubit] Cannot fetch khu vuc - state is not ProductLoaded');
      return;
    }
    
    try {
      print('🔍 [ProductCubit] Fetching khu vuc list...');
      final khuVucList = await _khuVucService.getKhuVucList(
        page: 1,
        limit: 12,
        sort: 'phuong',
        order: 'asc',
      );
      
      print('✅ [ProductCubit] Fetched ${khuVucList.length} khu vuc');
      
      if (!isClosed && state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(currentState.copyWith(khuVucList: khuVucList));
        print('✅ [ProductCubit] State updated with khu vuc list');
      }
    } catch (e, stackTrace) {
      print('❌ [ProductCubit] Lỗi khi fetch khu vực: $e');
      print('   StackTrace: $stackTrace');
      
      // Emit empty list để dialog không bị treo
      if (!isClosed && state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(currentState.copyWith(khuVucList: []));
      }
    }
  }

  /// Fetch danh sách chợ theo khu vực
  Future<void> fetchChoListByKhuVuc(String maKhuVuc) async {
    if (state is! ProductLoaded) {
      print('⚠️ [ProductCubit] Cannot fetch cho - state is not ProductLoaded');
      return;
    }
    
    try {
      print('🔍 [ProductCubit] Fetching cho list for khu vuc: $maKhuVuc');
      final choList = await _choService.getChoListByKhuVuc(
        maKhuVuc: maKhuVuc,
        page: 1,
        limit: 12,
        sort: 'ten_cho',
        order: 'asc',
      );
      
      print('✅ [ProductCubit] Fetched ${choList.length} cho');
      
      if (!isClosed && state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(currentState.copyWith(choList: choList));
        print('✅ [ProductCubit] State updated with cho list');
      }
    } catch (e, stackTrace) {
      print('❌ [ProductCubit] Lỗi khi fetch chợ: $e');
      print('   StackTrace: $stackTrace');
      
      // Emit empty list để dialog không bị treo
      if (!isClosed && state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        emit(currentState.copyWith(choList: []));
      }
    }
  }

  /// Chọn khu vực
  void selectRegion(String maKhuVuc, String phuong) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      print('🔍 [DEBUG] Chọn khu vực: $phuong (Mã: $maKhuVuc)');
      emit(currentState.copyWith(
        selectedRegionMa: maKhuVuc,
        selectedRegion: phuong,
        selectedMarketMa: null, // Reset chợ khi đổi khu vực
        selectedMarket: null,
        choList: [], // Reset danh sách chợ
      ));
      print('🔍 [DEBUG] State sau khi chọn: ${(state as ProductLoaded).selectedRegion}');
      
      // Fetch danh sách chợ cho khu vực mới
      fetchChoListByKhuVuc(maKhuVuc);
    }
  }

  /// Chọn chợ
  void selectMarket(String maCho, String tenCho) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      print('🔍 [DEBUG] Chọn chợ: $tenCho (Mã: $maCho)');
      emit(currentState.copyWith(
        selectedMarketMa: maCho,
        selectedMarket: tenCho,
      ));
    }
  }
}
