import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ingredient_detail_cubit.dart';
import '../cubit/ingredient_detail_state.dart';
import '../../../../../../core/widgets/ingredient_grid_card.dart';
import '../../../../../../core/widgets/cart_badge_icon.dart';
import '../../../../../../core/widgets/buyer_loading.dart';
import '../../../../../../core/services/review_api_service.dart';

class IngredientDetailPage extends StatelessWidget {
  final String? maNguyenLieu;
  final String ingredientName;
  final String ingredientImage;
  final String price;
  final String? unit;
  final String? shopName;

  const IngredientDetailPage({
    super.key,
    this.maNguyenLieu,
    required this.ingredientName,
    required this.ingredientImage,
    required this.price,
    this.unit,
    this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IngredientDetailCubit()
        ..loadIngredientDetails(
          maNguyenLieu: maNguyenLieu,
          ingredientName: ingredientName,
          ingredientImage: ingredientImage,
          price: price,
          unit: unit,
          shopName: shopName,
        ),
      child: const _IngredientDetailView(),
    );
  }
}

class _IngredientDetailView extends StatelessWidget {
  const _IngredientDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<IngredientDetailCubit, IngredientDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const BuyerLoading(
              message: 'Đang tải chi tiết nguyên liệu...',
            );
          }

          return Stack(
            children: [
              _buildScrollableContent(context, state),
              _buildHeader(context, state),
              _buildBottomAction(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, IngredientDetailState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 82),
          _buildProductImage(state),
          _buildProductInfo(state),
          const Divider(height: 2, thickness: 2, color: Color(0xFFD9D9D9)),
          
          // Danh sách gian hàng bán sản phẩm này
          if (state.sellers.isNotEmpty) ...[
            _buildSellersSection(context, state),
            const Divider(height: 2, thickness: 2, color: Color(0xFFD9D9D9)),
          ],
          
          // Đánh giá của gian hàng được chọn
          if (state.selectedSeller != null) ...[
            _buildReviewsSection(context, state),
            const Divider(height: 2, thickness: 2, color: Color(0xFFD9D9D9)),
          ],
          
          _buildRelatedProducts(context, state),
          const SizedBox(height: 24),
          _buildRecommendedProducts(context, state),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, IngredientDetailState state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const CartBadgeIcon(
                      iconSize: 26,
                      iconColor: Color(0xFF00B40F),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.more_vert,
                      size: 24,
                      color: Color(0xFF00B40F),
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

  Widget _buildProductImage(IngredientDetailState state) {
    final imagePath = state.ingredientImage;
    final isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');
    
    final placeholderWidget = Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 80, color: Colors.grey),
    );

    return SizedBox(
      height: 308,
      width: double.infinity,
      child: imagePath.isEmpty
          ? placeholderWidget
          : isNetworkImage
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 3,
                          color: const Color(0xFF00B40F),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => placeholderWidget,
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => placeholderWidget,
                ),
    );
  }

  Widget _buildProductInfo(IngredientDetailState state) {
    return BlocBuilder<IngredientDetailCubit, IngredientDetailState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${state.price} / ${state.unit}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F0F0F),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<IngredientDetailCubit>().toggleFavorite(),
                    child: Icon(
                      state.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                state.ingredientName,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 0.94,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              if (state.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.description,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                'Đã bán ${state.soldCount}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSellersSection(BuildContext context, IngredientDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 16, 17, 12),
          child: Row(
            children: [
              const Icon(
                Icons.store,
                size: 20,
                color: Color(0xFF00B40F),
              ),
              const SizedBox(width: 8),
              Text(
                'Chọn gian hàng (${state.sellers.length})',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 17),
          itemCount: state.sellers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final seller = state.sellers[index];
            return _buildSellerCard(context, seller, state);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSellerCard(BuildContext context, Seller seller, IngredientDetailState state) {
    final isNetworkImage = seller.imagePath != null && 
        (seller.imagePath!.startsWith('http://') || seller.imagePath!.startsWith('https://'));
    final isSelected = state.selectedSeller?.maGianHang == seller.maGianHang;
    
    return GestureDetector(
      onTap: () {
        print('👆 [UI] Bấm vào gian hàng: ${seller.tenGianHang}');
        print('👆 [UI] Mã gian hàng: ${seller.maGianHang}');
        context.read<IngredientDetailCubit>().selectSeller(seller);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 206, 233, 208) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B40F) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm từ seller
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: seller.imagePath != null && seller.imagePath!.isNotEmpty
                  ? (isNetworkImage
                      ? Image.network(
                          seller.imagePath!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : Image.asset(
                          seller.imagePath!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        ))
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),
            
            // Thông tin seller
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên gian hàng
                  Text(
                    seller.tenGianHang,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Vị trí
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF8E8E93),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          seller.viTri,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Giá và đơn vị
                  Row(
                    children: [
                      if (seller.hasDiscount && seller.originalPrice != null) ...[
                        Text(
                          seller.originalPrice!,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        seller.price,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                      if (seller.unit != null) ...[
                        const Text(
                          ' / ',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        Text(
                          seller.unit!,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Đã bán
                  Text(
                    'Đã bán ${seller.soldCount}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            
            // Icon chọn
            Icon(
              isSelected ? Icons.check_circle : Icons.chevron_right,
              size: 24,
              color: isSelected ? const Color(0xFF00B40F) : const Color(0xFF8E8E93),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(
        Icons.shopping_basket,
        size: 32,
        color: Color(0xFF00B40F),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, IngredientDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 16, 17, 12),
          child: Row(
            children: [
              const Icon(
                Icons.star,
                size: 20,
                color: Color(0xFFFFB800),
              ),
              const SizedBox(width: 8),
              Text(
                'Đánh giá ${state.selectedSeller?.tenGianHang ?? ""}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              const Spacer(),
              if (state.totalReviews > 0)
                Text(
                  '${state.avgRating.toStringAsFixed(1)} (${state.totalReviews})',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFB800),
                  ),
                ),
            ],
          ),
        ),
        
        // Loading indicator
        if (state.isLoadingReviews)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00B40F),
              ),
            ),
          )
        else if (state.reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có đánh giá nào',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 17),
            itemCount: state.reviews.length > 5 ? 5 : state.reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              return _buildReviewItem(review);
            },
          ),
        
        // Xem tất cả đánh giá
        if (state.reviews.length > 5)
          Padding(
            padding: const EdgeInsets.all(17),
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to all reviews
              },
              child: const Center(
                child: Text(
                  'Xem tất cả đánh giá',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00B40F),
                  ),
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewItem(StoreReviewItem review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tên người đánh giá + Rating
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B40F).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: Color(0xFF00B40F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.nguoiDanhGia?.tenHienThi ?? 'Người dùng',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        // Stars
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: const Color(0xFFFFB800),
                          );
                        }),
                        const SizedBox(width: 8),
                        // Date
                        if (review.ngayDanhGia != null)
                          Text(
                            _formatDate(review.ngayDanhGia!),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Comment
          if (review.binhLuan.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 46),
              child: Text(
                review.binhLuan,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF3C3C43),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} tuần trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildRelatedProducts(BuildContext context, IngredientDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          child: Text(
            'Sản phẩm liên quan',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            itemCount: state.relatedProducts.length,
            itemBuilder: (context, index) {
              final product = state.relatedProducts[index];
              return _buildProductCard(context, product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedProducts(BuildContext context, IngredientDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          child: Text(
            'Sản phẩm có thể bạn thích',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF020202),
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            itemCount: state.recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = state.recommendedProducts[index];
              return _buildProductCard(context, product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, RelatedProduct product) {
    return Container(
      width: 173,
      margin: const EdgeInsets.only(right: 18),
      child: IngredientGridCard(
        name: product.name,
        price: product.price,
        imagePath: product.imagePath,
        shopName: product.shopName,
        onTap: () {
          // Navigate to ingredient detail
          if (product.maNguyenLieu != null) {
            Navigator.pushNamed(
              context,
              '/ingredient-detail',
              arguments: {
                'maNguyenLieu': product.maNguyenLieu,
                'name': product.name,
                'image': product.imagePath,
                'price': product.price,
                'shopName': product.shopName,
              },
            );
          }
        },
        onAddToCart: () {
          // Add to cart - TODO: implement
          debugPrint('Thêm vào giỏ hàng: ${product.name}');
        },
        onBuyNow: () {
          // Buy now - TODO: implement
          debugPrint('Mua ngay: ${product.name}');
        },
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, IngredientDetailState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.read<IngredientDetailCubit>().chatWithShop(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/img/chat_icon-261e64.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.chat_bubble_outline,
                        size: 24,
                        color: Color(0xFF00B40F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Trò chuyện',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00B40F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Quantity controls
              BlocBuilder<IngredientDetailCubit, IngredientDetailState>(
                builder: (context, state) {
                  return Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrease button
                        GestureDetector(
                          onTap: () => context.read<IngredientDetailCubit>().decreaseQuantity(),
                          child: Container(
                            width: 32,
                            height: 40,
                            decoration: BoxDecoration(
                              color: state.quantity > 1 
                                  ? const Color(0xFFF5F5F5) 
                                  : const Color(0xFFE0E0E0),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 18,
                              color: state.quantity > 1 
                                  ? const Color(0xFF00B40F) 
                                  : const Color(0xFF999999),
                            ),
                          ),
                        ),
                        
                        // Quantity display
                        Container(
                          width: 40,
                          height: 40,
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              '${state.quantity}',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ),
                        
                        // Increase button
                        GestureDetector(
                          onTap: () => context.read<IngredientDetailCubit>().increaseQuantity(),
                          child: Container(
                            width: 32,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Color(0xFF00B40F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<IngredientDetailCubit>().addToCart(),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF00B40F)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Thêm vào \ngiỏ hàng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00B40F),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<IngredientDetailCubit>().buyNow(context),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Mua ngay',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
