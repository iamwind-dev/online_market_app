import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/productdetail_cubit.dart';
import '../cubit/productdetail_state.dart';
import '../../../../core/widgets/product_card.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailCubit()..loadProductDetails(),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              _buildScrollableContent(context, state),
              _buildHeader(context, state),
              _buildBottomActions(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, ProductDetailState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 86),
          _buildProductImage(state),
          _buildPriceSection(state),
          _buildProductTitle(state),
          _buildRatingSection(state),
          const Divider(height: 2, thickness: 2, color: Color(0xFFD9D9D9)),
          _buildFavoriteIcon(context, state),
          _buildShopName(state),
          _buildProductInfo(state),
          _buildExpandButton(),
          _buildRelatedProductsTitle(),
          _buildRelatedProducts(context),
          const SizedBox(height: 20),
          _buildReviewSection(state),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProductDetailState state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 91,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 16),
                ),
                Row(
                  children: [
                    const Icon(Icons.share, size: 27),
                    const SizedBox(width: 7),
                    Stack(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 26),
                        if (state.cartItemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFDBDB),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              child: Text(
                                '${state.cartItemCount}',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF0000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductDetailState state) {
    return Image.asset(
      state.productImage,
      width: double.infinity,
      height: 308,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 308,
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 80),
        );
      },
    );
  }

  Widget _buildPriceSection(ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 17, top: 12),
      child: Text(
        '${state.price} ${state.priceUnit}',
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F0F0F),
        ),
      ),
    );
  }

  Widget _buildProductTitle(ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
      child: Text(
        state.productName,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRatingSection(ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Image.asset(
                'assets/img/productdetail_star_icon-239c62.png',
                width: 20,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '${state.rating}  |  Đã bán ${state.soldCount}',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.47,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon(BuildContext context, ProductDetailState state) {
    final cubit = context.read<ProductDetailCubit>();
    return Padding(
      padding: const EdgeInsets.only(top: 14, right: 30),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: cubit.toggleFavorite,
          child: Icon(
            state.isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 14,
            color: const Color(0xFF1C1B1F),
          ),
        ),
      ),
    );
  }

  Widget _buildShopName(ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        state.shopName,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.21,
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        state.description,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 155, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Xem thêm',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductsTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(84, 10, 84, 20),
      child: Text(
        'Sản phẩm có thể bạn thích',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.21,
          color: Color(0xFF020202),
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    final relatedProducts = [
      {
        'name': 'Cá diêu hồng',
        'price': '165.000đ',
        'sold': '120 lượt bán',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Cá chẽt tươi',
        'price': '145.000đ',
        'sold': '85 lượt bán',
        'image': 'assets/img/product_mm_logo.png'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.74,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: relatedProducts.length,
        itemBuilder: (context, index) {
          final product = relatedProducts[index];
          return ProductCard(
            title: product['name'] as String,
            price: product['price'] as String,
            soldCount: product['sold'] as String,
            imagePath: product['image'] as String,
            onFavoriteTap: () {
              // Toggle favorite
            },
            onAddToCart: () {
              // Add to cart
            },
            onBuyNow: () {
              // Buy now
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewSection(ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá từ khách hàng',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.21,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Rating score
              Column(
                children: [
                  Text(
                    '${state.rating}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 0.64,
                      color: Color(0xFF008EDB),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/img/productdetail_star_icon-239c62.png',
                    width: 21,
                    height: 19,
                  ),
                ],
              ),
              const SizedBox(width: 22),
              // Center: Star ratings
              Expanded(
                child: Column(
                  children: state.reviews.map((review) {
                    return _buildReviewRow(review);
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/img/productdetail_star_icon-239c62.png',
            width: 11,
            height: 10,
          ),
          const SizedBox(width: 5),
          Text(
            '${review.stars}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: Color(0xFF0C0D0D),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: review.percentage,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCC866),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${(review.percentage * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                height: 1.78,
                color: Color(0xFF0C0D0D),
              ),
            ),
          ),
          SizedBox(
            width: 84,
            child: Text(
              '${review.count} đánh giá',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.33,
                color: Color(0xFF0C0D0D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ProductDetailState state) {
    final cubit = context.read<ProductDetailCubit>();
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Row(
          children: [
            // Chat button
            GestureDetector(
              onTap: cubit.chatWithShop,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/productdetail_chat_icon-261e64.png',
                    width: 30,
                    height: 28,
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Trò chuyện',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.83,
                      color: Color(0xFF008EDB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 17),
            // Add to cart button
            Expanded(
              child: GestureDetector(
                onTap: cubit.addToCart,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF008EDB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Thêm vào \ngiỏ hàng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: Color(0xFF008EDB),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            // Buy now button
            Expanded(
              child: GestureDetector(
                onTap: cubit.buyNow,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F8000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Mua ngay',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.375,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
