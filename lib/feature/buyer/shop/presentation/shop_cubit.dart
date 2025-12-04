import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/config/app_config.dart';

part 'shop_state.dart';

/// Shop Cubit quản lý logic nghiệp vụ của trang gian hàng
/// 
/// Chức năng chính:
/// - Tải thông tin cửa hàng
/// - Tải danh sách sản phẩm của cửa hàng
/// - Toggle yêu thích sản phẩm
/// - Chuyển đổi tab danh mục
class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(ShopInitial());

  /// Tải thông tin cửa hàng và sản phẩm theo shopId
  Future<void> loadShop(String shopId) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🏪 [SHOP] Bắt đầu tải thông tin cửa hàng: $shopId');
    }

    try {
      emit(ShopLoading());

      // Tạo mock data cho demo
      // TODO: Gọi API thực tế để lấy thông tin cửa hàng
      await Future.delayed(const Duration(milliseconds: 500));

      final shopInfo = ShopInfo(
        shopId: shopId,
        shopName: 'Cô Nhi',
        shopImage: 'assets/img/shop_seller_1.png',
        shopRating: 5.0,
        soldCount: 120,
        productCount: 30,
        categories: const ['Gia vị', 'Thịt heo'],
      );

      final products = [
        ShopProduct(
          productId: 'P001',
          productName: 'TRỨNG GÀ CÔNG NGHIỆP VỈ 30 QUẢ',
          productImage: 'assets/img/shop_product_1.png',
          price: 48000,
          badge: '',
          shopId: shopId,
        ),
        ShopProduct(
          productId: 'P002',
          productName: 'Đùi gà công nghiệp Đông Tảo VLT',
          productImage: 'assets/img/shop_product_1.png',
          price: 116000,
          badge: 'Flash sale',
          soldCount: 0,
          shopId: shopId,
        ),
        ShopProduct(
          productId: 'P003',
          productName: 'Sườn heo đông lanh',
          productImage: 'assets/img/shop_product_1.png',
          price: 19000,
          badge: 'Đang bán chạy',
          soldCount: 129,
          shopId: shopId,
        ),
        ShopProduct(
          productId: 'P004',
          productName: 'Thịt heo đùi',
          productImage: 'assets/img/shop_product_1.png',
          price: 143000,
          badge: 'Đã bán 56',
          soldCount: 56,
          shopId: shopId,
        ),
      ];

      if (AppConfig.enableApiLogging) {
        AppLogger.info('✅ [SHOP] Tải thành công: ${shopInfo.shopName}');
        AppLogger.info('   Số sản phẩm: ${products.length}');
      }

      emit(ShopLoaded(
        shopInfo: shopInfo,
        products: products,
      ));
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [SHOP] Lỗi khi tải cửa hàng: ${e.toString()}');
      }
      emit(ShopFailure(
        errorMessage: 'Không thể tải thông tin cửa hàng: ${e.toString()}',
      ));
    }
  }

  /// Toggle yêu thích sản phẩm
  void toggleProductFavorite(String productId) {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      
      // Tìm sản phẩm và toggle trạng thái yêu thích
      final updatedProducts = currentState.products.map((product) {
        if (product.productId == productId) {
          if (AppConfig.enableApiLogging) {
            AppLogger.info('❤️ [SHOP] Toggle yêu thích: $productId (${!product.isFavorite})');
          }
          return product.copyWith(isFavorite: !product.isFavorite);
        }
        return product;
      }).toList();

      emit(currentState.copyWith(products: updatedProducts));
      emit(ShopProductFavoriteToggled(
        productId: productId,
        isFavorite: updatedProducts
            .firstWhere((p) => p.productId == productId)
            .isFavorite,
      ));
    }
  }

  /// Chuyển đổi tab danh mục
  void selectCategory(int tabIndex) {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      
      if (AppConfig.enableApiLogging) {
        AppLogger.info('📂 [SHOP] Chọn tab: $tabIndex');
      }

      emit(currentState.copyWith(selectedTabIndex: tabIndex));
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(String productId, int quantity) async {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      final product = currentState.products
          .firstWhere((p) => p.productId == productId);

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🛒 [SHOP] Thêm vào giỏ hàng: ${product.productName} x$quantity');
      }

      try {
        // TODO: Gọi API để thêm vào giỏ hàng
        await Future.delayed(const Duration(milliseconds: 300));

        if (AppConfig.enableApiLogging) {
          AppLogger.info('✅ [SHOP] Thêm giỏ hàng thành công');
        }
      } catch (e) {
        if (AppConfig.enableApiLogging) {
          AppLogger.error('❌ [SHOP] Lỗi khi thêm giỏ hàng: $e');
        }
      }
    }
  }
}
