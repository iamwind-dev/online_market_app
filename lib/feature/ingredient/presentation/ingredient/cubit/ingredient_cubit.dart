import 'package:flutter_bloc/flutter_bloc.dart';
import 'ingredient_state.dart';
import '../../../../../core/services/gian_hang_service.dart';
import '../../../../../core/services/danh_muc_nguyen_lieu_service.dart';
import '../../../../../core/services/nguyen_lieu_service.dart';
import '../../../../../core/dependency/injection.dart';
import '../../../../../core/utils/price_formatter.dart';

/// Cubit quản lý state cho Ingredient Screen
class IngredientCubit extends Cubit<IngredientState> {
  GianHangService? _gianHangService;
  DanhMucNguyenLieuService? _danhMucNguyenLieuService;
  NguyenLieuService? _nguyenLieuService;

  IngredientCubit() : super(const IngredientInitial()) {
    try {
      _gianHangService = getIt<GianHangService>();
      _danhMucNguyenLieuService = getIt<DanhMucNguyenLieuService>();
      _nguyenLieuService = getIt<NguyenLieuService>();
    } catch (e) {
      print('⚠️ Services not registered, will use mock data');
    }
  }

  /// Load dữ liệu ban đầu
  Future<void> loadIngredientData() async {
    emit(const IngredientLoading());

    // Fetch categories từ API
    List<Category> categories = [];
    List<Category> additionalCategories = [];
    
    try {
      if (_danhMucNguyenLieuService != null) {
        final response = await _danhMucNguyenLieuService!.getDanhMucNguyenLieuList(
          page: 1,
          limit: 20,
          sort: 'ten_nhom_nguyen_lieu',
          order: 'asc',
        );
        
        // Convert API data to Category model
        final allCategories = response.data.map((danhMuc) {
          return Category(
            name: danhMuc.tenNhomNguyenLieu,
            imagePath: '', // Không có ảnh từ API
          );
        }).toList();
        
        // Split into main and additional categories
        if (allCategories.length > 5) {
          categories = allCategories.sublist(0, 5);
          additionalCategories = allCategories.sublist(5);
        } else {
          categories = allCategories;
        }
        
        print('✅ Fetched ${allCategories.length} categories from API');
      } else {
        throw Exception('DanhMucNguyenLieuService not available');
      }
    } catch (e) {
      print('⚠️ Lỗi khi fetch danh mục: $e');
      // Fallback to mock data
      categories = [
        const Category(
          name: 'Rau củ',
          imagePath: 'assets/img/ingredient_category_rau_cu.png',
        ),
        const Category(
          name: 'Trái cây',
          imagePath: 'assets/img/ingredient_category_trai_cay-2bc751.png',
        ),
        const Category(
          name: 'Thịt',
          imagePath: 'assets/img/ingredient_category_thit.png',
        ),
        const Category(
          name: 'Thuỷ sản',
          imagePath: 'assets/img/ingredient_category_thuy_san-42d575.png',
        ),
        const Category(
          name: 'Bánh kẹo',
          imagePath: 'assets/img/ingredient_category_banh_keo-512c43.png',
        ),
      ];

      additionalCategories = [
        const Category(
          name: 'Dưỡng thể',
          imagePath: 'assets/img/ingredient_category_duong_the.png',
        ),
        const Category(
          name: 'Gia vị',
          imagePath: 'assets/img/ingredient_category_gia_vi-122bd9.png',
        ),
        const Category(
          name: 'Sữa các loại',
          imagePath: 'assets/img/ingredient_category_sua-b32339.png',
        ),
        const Category(
          name: 'Đồ uống',
          imagePath: 'assets/img/ingredient_category_do_uong.png',
        ),
      ];
    }

    // Fetch nguyên liệu từ API
    List<Product> products = [];
    List<String> shopNames = [];
    
    try {
      if (_nguyenLieuService != null) {
        final response = await _nguyenLieuService!.getNguyenLieuList(
          page: 1,
          limit: 12,
          sort: 'ten_nguyen_lieu',
          order: 'asc',
        );
        
        // Convert API data to Product model
        products = response.data.map((nguyenLieu) {
          return Product(
            maNguyenLieu: nguyenLieu.maNguyenLieu,
            name: nguyenLieu.tenNguyenLieu,
            price: _formatPrice(nguyenLieu.giaCuoi, nguyenLieu.giaGoc),
            imagePath: _getImagePath(nguyenLieu.hinhAnh),
            shopName: nguyenLieu.tenNhomNguyenLieu,
            badge: _getBadgeText(nguyenLieu.soGianHang),
            hasDiscount: _hasDiscount(nguyenLieu.giaGoc, nguyenLieu.giaCuoi),
            originalPrice: _formatOriginalPrice(nguyenLieu.giaGoc, nguyenLieu.giaCuoi),
          );
        }).toList();
        
        // Extract shop names from categories
        shopNames = response.data
            .map((nguyenLieu) => nguyenLieu.tenNhomNguyenLieu)
            .toSet()
            .toList();
        
        print('✅ Fetched ${products.length} nguyên liệu from API');
      } else {
        throw Exception('NguyenLieuService not available');
      }
    } catch (e) {
      print('⚠️ Lỗi khi fetch nguyên liệu: $e');
      // Fallback to mock data
      products = [
        const Product(
          name: 'TRỨNG GÀ CÔNG NGHIỆP VỈ 30 QUẢ',
          price: '48.000đ',
          imagePath: 'assets/img/ingredient_product_2-46bf93.png',
          shopName: 'Cô Hồng',
          badge: 'Flash sale',
          hasDiscount: true,
          originalPrice: '59.000đ',
        ),
        const Product(
          name: 'CÁNH GÀ CÔNG NGHIỆP ĐÔNG LẠNH VFOOD CHẤT LƯỢNG',
          price: '59.000đ',
          imagePath: 'assets/img/ingredient_product_1.png',
          shopName: 'Cô Hồng',
          badge: 'Đang bán chạy',
        ),
        const Product(
          name: 'CÁNH GÀ CÔNG NGHIỆP ĐÔNG LẠNH VFOOD CHẤT LƯỢNG',
          price: '19.000đ',
          imagePath: 'assets/img/ingredient_product_1.png',
          shopName: 'Cô Như',
          badge: 'Đã bán 129',
        ),
        const Product(
          name: 'SOCOLA ĐEN COMPOUND DẠNG KEM QUE 8CM',
          price: '143.000đ',
          imagePath: 'assets/img/ingredient_product_1.png',
          shopName: 'Cô Nhi',
          badge: 'Đã bán 56',
        ),
      ];
      shopNames = ['Cô Hồng', 'Cô Như', 'Cô Nhi'];
    }

    // Fetch shops từ API
    List<Shop> shops = [];
    try {
      if (_gianHangService != null) {
        final response = await _gianHangService!.getGianHangList(
          page: 1,
          limit: 12,
          sort: 'ten_gian_hang',
          order: 'asc',
        );
        
        shops = response.data.map((gianHang) {
          return Shop(
            name: gianHang.tenGianHang,
            imagePath: _getValidImagePath(gianHang.hinhAnh),
            rating: gianHang.danhGiaTb > 0 ? gianHang.danhGiaTb.toStringAsFixed(1) : null,
            distance: gianHang.viTri,
          );
        }).toList();
        print('✅ Fetched ${shops.length} shops from API');
      } else {
        throw Exception('GianHangService not available');
      }
    } catch (e) {
      print('⚠️ Lỗi khi fetch gian hàng: $e');
      // Fallback to mock data nếu API lỗi
      shops = [
        const Shop(
          name: 'Cô Hồng',
          rating: '4.8',
          distance: '1.2 km',
        ),
        const Shop(
          name: 'Cô Như',
          rating: '4.5',
          distance: '2.5 km',
        ),
        const Shop(
          name: 'Cô Nhi',
          rating: '4.7',
          distance: '0.8 km',
        ),
      ];
    }

    emit(IngredientLoaded(
      categories: categories,
      additionalCategories: additionalCategories,
      shops: shops,
      products: products,
      shopNames: shopNames,
      selectedBottomNavIndex: 3, // 3 = Nguyên liệu tab
      cartItemCount: 0,
      currentPage: 1,
      hasMoreProducts: true, // Assume có thêm products
      isLoadingMore: false,
    ));
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (state is! IngredientLoaded) return;
    
    final currentState = state as IngredientLoaded;
    
    // Nếu đang load hoặc không còn products, không làm gì
    if (currentState.isLoadingMore || !currentState.hasMoreProducts) {
      return;
    }

    // Set loading state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      if (_nguyenLieuService != null) {
        final nextPage = currentState.currentPage + 1;
        
        final response = await _nguyenLieuService!.getNguyenLieuList(
          page: nextPage,
          limit: 12,
          sort: 'ten_nguyen_lieu',
          order: 'asc',
        );
        
        // Convert API data to Product model
        final newProducts = response.data.map((nguyenLieu) {
          return Product(
            maNguyenLieu: nguyenLieu.maNguyenLieu,
            name: nguyenLieu.tenNguyenLieu,
            price: _formatPrice(nguyenLieu.giaCuoi, nguyenLieu.giaGoc),
            imagePath: _getImagePath(nguyenLieu.hinhAnh),
            shopName: nguyenLieu.tenNhomNguyenLieu,
            badge: _getBadgeText(nguyenLieu.soGianHang),
            hasDiscount: _hasDiscount(nguyenLieu.giaGoc, nguyenLieu.giaCuoi),
            originalPrice: _formatOriginalPrice(nguyenLieu.giaGoc, nguyenLieu.giaCuoi),
          );
        }).toList();
        
        // Merge với products hiện tại
        final allProducts = [...currentState.products, ...newProducts];
        
        // Extract shop names
        final newShopNames = response.data
            .map((nguyenLieu) => nguyenLieu.tenNhomNguyenLieu)
            .toSet()
            .toList();
        final allShopNames = {...currentState.shopNames, ...newShopNames}.toList();
        
        print('✅ Loaded page $nextPage: ${newProducts.length} more products');
        
        // Update state với products mới
        emit(currentState.copyWith(
          products: allProducts,
          shopNames: allShopNames,
          currentPage: nextPage,
          hasMoreProducts: response.meta.hasNext,
          isLoadingMore: false,
        ));
      } else {
        throw Exception('NguyenLieuService not available');
      }
    } catch (e) {
      print('⚠️ Lỗi khi load more nguyên liệu: $e');
      // Reset loading state nếu lỗi
      emit(currentState.copyWith(
        isLoadingMore: false,
        hasMoreProducts: false, // Không thử load nữa nếu lỗi
      ));
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Perform search
  void performSearch() {
    if (state is IngredientLoaded) {
      // Implement search logic here
      // For now, just keep the current state
    }
  }

  /// Select category
  void selectCategory(String categoryName) {
    // Navigate to category detail or filter products
  }

  /// Change bottom navigation index
  void changeBottomNavIndex(int index) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(currentState.copyWith(selectedBottomNavIndex: index));
    }
  }

  /// Navigate to filter
  void navigateToFilter() {
    // Navigation will be handled by screen
  }

  /// Buy product now
  void buyNow(Product product) {
    // Implement buy now logic
  }

  /// Add to cart
  void addToCart(Product product) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(currentState.copyWith(
        cartItemCount: currentState.cartItemCount + 1,
      ));
    }
  }

  // ==================== Helper Methods ====================

  /// Format giá hiển thị (giá chính - hiển thị to)
  /// Nếu có giaCuoi thì hiển thị giaCuoi, không thì hiển thị giaGoc
  String _formatPrice(String? giaCuoi, double? giaGoc) {
    // Ưu tiên giaCuoi
    if (giaCuoi != null && giaCuoi.isNotEmpty && giaCuoi != 'null') {
      final parsed = PriceFormatter.parsePrice(giaCuoi);
      if (parsed != null && parsed > 0) {
        return PriceFormatter.formatPrice(parsed);
      }
    }
    
    // Nếu không có giaCuoi, dùng giaGoc
    if (giaGoc != null && giaGoc > 0) {
      return PriceFormatter.formatPrice(giaGoc);
    }
    
    return '0đ';
  }

  /// Format giá gốc (giá gạch ngang - hiển thị nhỏ)
  /// Luôn hiển thị giaGoc nếu có cả giaGoc và giaCuoi
  String? _formatOriginalPrice(double? giaGoc, String? giaCuoi) {
    if (giaGoc == null || giaGoc <= 0) return null;
    if (giaCuoi == null || giaCuoi.isEmpty || giaCuoi == 'null') return null;
    return PriceFormatter.formatPrice(giaGoc);
  }

  /// Kiểm tra có discount không
  /// Có discount khi có cả giaGoc và giaCuoi
  bool _hasDiscount(double? giaGoc, String? giaCuoi) {
    if (giaGoc == null || giaGoc <= 0) return false;
    if (giaCuoi == null || giaCuoi.isEmpty || giaCuoi == 'null') return false;
    return true;
  }

  /// Lấy đường dẫn hình ảnh
  /// Nếu hinhAnh null hoặc empty, dùng ảnh mặc định
  String _getImagePath(String? hinhAnh) {
    if (hinhAnh == null || hinhAnh.isEmpty || hinhAnh == 'null') {
      return 'assets/img/ingredient_product_1.png';
    }
    
    // Kiểm tra xem có phải URL hợp lệ không
    if (hinhAnh.startsWith('http://') || hinhAnh.startsWith('https://')) {
      return hinhAnh;
    }
    
    // Nếu không phải URL, có thể là đường dẫn local, dùng ảnh mặc định
    return 'assets/img/ingredient_product_1.png';
  }

  /// Lấy đường dẫn hình ảnh hợp lệ (cho shop/gian hàng)
  /// Trả về null nếu không có ảnh hợp lệ để widget tự hiển thị placeholder
  String? _getValidImagePath(String? hinhAnh) {
    if (hinhAnh == null || hinhAnh.isEmpty || hinhAnh == 'null') {
      return null;
    }
    
    // Chỉ trả về nếu là URL hợp lệ
    if (hinhAnh.startsWith('http://') || hinhAnh.startsWith('https://')) {
      return hinhAnh;
    }
    
    return null;
  }

  /// Tạo badge text dựa trên số gian hàng
  String? _getBadgeText(int soGianHang) {
    if (soGianHang <= 0) {
      return null;
    }
    
    if (soGianHang == 1) {
      return '1 gian hàng';
    }
    
    return '$soGianHang gian hàng';
  }
}
