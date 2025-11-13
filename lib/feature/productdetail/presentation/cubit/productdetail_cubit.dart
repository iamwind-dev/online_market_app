import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_market_app/feature/productdetail/presentation/cubit/productdetail_state.dart';

/// Cubit quản lý state cho ProductDetail
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailState());

  /// Load thông tin chi tiết sản phẩm
  void loadProductDetails({
    String? productName,
    String? productImage,
    String? price,
    String? priceUnit,
    double? rating,
    int? soldCount,
    String? shopName,
    String? category,
  }) {
    emit(state.copyWith(isLoading: true));

    // Simulate loading data
    emit(state.copyWith(
      productName: productName ??
          'Đùi gà công nghiệp Đông Tảo VLT, 1 kg tươi ngon, chất lượng',
      productImage: productImage ?? 'assets/img/productdetail_main_image.png',
      price: price ?? '116.000',
      priceUnit: priceUnit ?? 'đ/ Ký',
      rating: rating ?? 4.8,
      soldCount: soldCount ?? 59,
      shopName: shopName ?? 'Gian hàng cô Hồng - Chợ Bắc Mỹ An',
      category: category ?? 'Gà',
      description: 'Tên Sản Phẩm: Đùi gà công nghiệp Đông Tảo\nDanh mục: Gà\nGiá: 116.000 đồng/ Ký',
      reviews: const [
        Review(stars: 5, count: 10, percentage: 0.8),
        Review(stars: 4, count: 2, percentage: 0.2),
        Review(stars: 3, count: 0, percentage: 0.0),
        Review(stars: 2, count: 0, percentage: 0.0),
        Review(stars: 1, count: 0, percentage: 0.0),
      ],
      isLoading: false,
    ));
  }

  /// Toggle favorite status
  void toggleFavorite() {
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }

  /// Add to cart
  void addToCart() {
    emit(state.copyWith(cartItemCount: state.cartItemCount + 1));
  }

  /// Update cart item count
  void updateCartItemCount(int count) {
    emit(state.copyWith(cartItemCount: count));
  }

  /// Buy now action
  void buyNow() {
    // Implement buy now logic
    addToCart();
  }

  /// Chat with shop
  void chatWithShop() {
    // Implement chat logic
  }
}
