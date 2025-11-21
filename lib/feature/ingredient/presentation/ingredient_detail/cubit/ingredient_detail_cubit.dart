import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ingredient_detail_state.dart';
import '../../../../../core/services/nguyen_lieu_service.dart';
import '../../../../../core/dependency/injection.dart';
import '../../../../../core/utils/price_formatter.dart';
import '../../../../../core/services/cart_api_service.dart';
import '../../../../../core/widgets/cart_badge_icon.dart';

/// Cubit quản lý state cho IngredientDetail
class IngredientDetailCubit extends Cubit<IngredientDetailState> {
  NguyenLieuService? _nguyenLieuService;

  IngredientDetailCubit() : super(const IngredientDetailState()) {
    try {
      _nguyenLieuService = getIt<NguyenLieuService>();
    } catch (e) {
      print('⚠️ NguyenLieuService not registered');
    }
  }

  /// Load thông tin chi tiết nguyên liệu từ API
  Future<void> loadIngredientDetails({
    String? maNguyenLieu,
    String? ingredientName,
    String? ingredientImage,
    String? price,
    String? unit,
    String? shopName,
  }) async {
    emit(state.copyWith(isLoading: true));

    // Nếu không có mã nguyên liệu, dùng mock data
    if (maNguyenLieu == null || maNguyenLieu.isEmpty) {
      _loadMockData(ingredientName, ingredientImage, price, unit, shopName);
      return;
    }

    try {
      if (_nguyenLieuService != null) {
        final response = await _nguyenLieuService!.getNguyenLieuDetail(maNguyenLieu);
        
        final detail = response.detail;
        
        // Convert sellers từ API
        final sellers = response.sellers.data.map((seller) {
          return Seller(
            maGianHang: seller.maGianHang,
            tenGianHang: seller.tenGianHang,
            viTri: seller.viTri,
            price: _formatPrice(seller.giaCuoi, seller.giaGoc),
            originalPrice: _formatOriginalPrice(seller.giaGoc, seller.giaCuoi),
            hasDiscount: _hasDiscount(seller.giaGoc, seller.giaCuoi),
            imagePath: seller.hinhAnh,
            soldCount: seller.soLuongBan,
            unit: seller.donViBan,
          );
        }).toList();
        
        // Tính tổng số lượng bán
        final totalSold = sellers.fold<int>(0, (sum, seller) => sum + seller.soldCount);
        
        // Lấy giá từ seller đầu tiên hoặc từ detail
        final displayPrice = sellers.isNotEmpty 
            ? sellers.first.price 
            : _formatPrice(detail.giaCuoi, detail.giaGoc);
        final displayUnit = sellers.isNotEmpty && sellers.first.unit != null
            ? sellers.first.unit!
            : (detail.donVi ?? 'Ký');
        
        print('✅ Loaded ingredient detail: ${detail.tenNguyenLieu} with ${sellers.length} sellers');
        
        emit(state.copyWith(
          maNguyenLieu: detail.maNguyenLieu,
          ingredientName: detail.tenNguyenLieu,
          ingredientImage: detail.hinhAnhMoiNhat ?? '',
          price: displayPrice,
          unit: displayUnit,
          shopName: detail.tenNhomNguyenLieu,
          soldCount: totalSold,
          sellers: sellers,
          selectedSeller: sellers.isNotEmpty ? sellers.first : null, // Chọn seller đầu tiên mặc định
          description: 'Có ${detail.soGianHang} gian hàng đang bán sản phẩm này',
          relatedProducts: const [], // TODO: Fetch related products
          recommendedProducts: const [], // TODO: Fetch recommended products
          isLoading: false,
        ));
      } else {
        throw Exception('NguyenLieuService not available');
      }
    } catch (e) {
      print('⚠️ Lỗi khi fetch chi tiết nguyên liệu: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông tin nguyên liệu',
      ));
      // Fallback to mock data
      _loadMockData(ingredientName, ingredientImage, price, unit, shopName);
    }
  }

  /// Load mock data khi không có API
  void _loadMockData(String? ingredientName, String? ingredientImage, String? price, String? unit, String? shopName) {
    final relatedProducts = [
      const RelatedProduct(
        name: 'Cá diêu hồng',
        price: '94,000 đ / Ký',
        imagePath: 'assets/img/ingredient_detail_related_1.png',
        shopName: 'Cô Hồng',
        soldCount: 106,
      ),
      const RelatedProduct(
        name: 'Cá chét tươi',
        price: '80,000 đ / Ký',
        imagePath: 'assets/img/ingredient_detail_related_2.png',
        shopName: 'Cô Sen',
        soldCount: 16,
      ),
    ];

    emit(state.copyWith(
      ingredientName: ingredientName ?? '',
      ingredientImage: ingredientImage ?? '',
      price: price ?? '',
      unit: unit ?? 'Ký',
      shopName: shopName ?? 'Cô Hồng',
      rating: 4.8,
      soldCount: 59,
      description: 'Sản phẩm tươi ngon, được nhập khẩu trực tiếp từ các nông trại uy tín.',
      relatedProducts: relatedProducts,
      recommendedProducts: relatedProducts,
      isLoading: false,
    ));
  }

  // ==================== Helper Methods ====================

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

  String? _formatOriginalPrice(double? giaGoc, String? giaCuoi) {
    if (giaGoc == null || giaGoc <= 0) return null;
    if (giaCuoi == null || giaCuoi.isEmpty || giaCuoi == 'null') return null;
    return PriceFormatter.formatPrice(giaGoc);
  }

  bool _hasDiscount(double? giaGoc, String? giaCuoi) {
    if (giaGoc == null || giaGoc <= 0) return false;
    if (giaCuoi == null || giaCuoi.isEmpty || giaCuoi == 'null') return false;
    return true;
  }

  /// Toggle favorite status
  void toggleFavorite() {
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }

  /// Add to cart
  Future<void> addToCart() async {
    print('🛒 [ADD TO CART] Starting...');
    print('🛒 [ADD TO CART] maNguyenLieu: ${state.maNguyenLieu}');
    print('🛒 [ADD TO CART] selectedSeller: ${state.selectedSeller?.tenGianHang} (${state.selectedSeller?.maGianHang})');
    
    if (state.maNguyenLieu == null || state.maNguyenLieu!.isEmpty) {
      print('⚠️ Không có mã nguyên liệu');
      return;
    }

    // Lấy gian hàng được chọn (selectedSeller)
    if (state.selectedSeller == null) {
      print('⚠️ Chưa chọn gian hàng nào');
      return;
    }

    final maGianHang = state.selectedSeller!.maGianHang;
    print('🛒 [ADD TO CART] Calling API with maGianHang: $maGianHang');

    try {
      final cartService = CartApiService();
      final response = await cartService.addToCart(
        maNguyenLieu: state.maNguyenLieu!,
        maGianHang: maGianHang,
        soLuong: state.quantity,
      );

      if (response.success) {
        // Refresh cart badge
        refreshCartBadge();
        
        // Update local count (optional)
        emit(state.copyWith(cartItemCount: state.cartItemCount + 1));
        
        print('✅ Đã thêm vào giỏ hàng: ${state.selectedSeller!.tenGianHang} (${maGianHang})');
      } else {
        print('❌ Thêm vào giỏ hàng thất bại: ${response.message}');
      }
    } catch (e) {
      print('❌ Lỗi khi thêm vào giỏ hàng: $e');
    }
  }

  /// Update cart item count
  void updateCartItemCount(int count) {
    emit(state.copyWith(cartItemCount: count));
  }

  /// Buy now action - Chuyển thẳng sang trang thanh toán với thông tin sản phẩm
  void buyNow(BuildContext context) {
    print('🛍️ [BUY NOW] Starting...');
    
    if (state.maNguyenLieu == null || state.maNguyenLieu!.isEmpty) {
      print('⚠️ Không có mã nguyên liệu');
      return;
    }

    if (state.selectedSeller == null) {
      print('⚠️ Chưa chọn gian hàng nào');
      return;
    }

    print('🛍️ [BUY NOW] Navigating to payment with:');
    print('  - Nguyên liệu: ${state.ingredientName}');
    print('  - Mã: ${state.maNguyenLieu}');
    print('  - Gian hàng: ${state.selectedSeller!.tenGianHang}');
    print('  - Mã gian hàng: ${state.selectedSeller!.maGianHang}');
    print('  - Giá: ${state.price}');
    
    // Navigate to payment page với thông tin sản phẩm
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'isBuyNow': true,
        'maNguyenLieu': state.maNguyenLieu,
        'tenNguyenLieu': state.ingredientName,
        'maGianHang': state.selectedSeller!.maGianHang,
        'tenGianHang': state.selectedSeller!.tenGianHang,
        'hinhAnh': state.ingredientImage,
        'gia': state.price,
        'donVi': state.unit,
        'soLuong': state.quantity,
      },
    );
  }

  /// Chat with shop
  void chatWithShop() {
    // Implement chat logic
  }

  /// Select seller (chọn gian hàng để mua)
  void selectSeller(Seller seller) {
    print('🏪 [SELECT SELLER] Before: ${state.selectedSeller?.maGianHang}');
    print('🏪 [SELECT SELLER] Selecting: ${seller.maGianHang} - ${seller.tenGianHang}');
    
    // Cập nhật thông tin hiển thị và lưu seller được chọn
    emit(state.copyWith(
      selectedSeller: seller,
      price: seller.price,
      unit: seller.unit ?? state.unit,
      shopName: seller.tenGianHang,
    ));
    
    print('🏪 [SELECT SELLER] After: ${state.selectedSeller?.maGianHang}');
    print('✅ Đã chọn gian hàng: ${seller.tenGianHang} (${seller.maGianHang}) - ${seller.price}');
  }

  /// Tăng số lượng
  void increaseQuantity() {
    emit(state.copyWith(quantity: state.quantity + 1));
    print('➕ Số lượng: ${state.quantity}');
  }

  /// Giảm số lượng (tối thiểu là 1)
  void decreaseQuantity() {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
      print('➖ Số lượng: ${state.quantity}');
    }
  }
}
