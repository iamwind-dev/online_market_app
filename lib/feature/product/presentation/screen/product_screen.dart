import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';
import '../../../../core/widgets/product_list_item.dart';
import '../../../../core/widgets/cart_icon_with_badge.dart';
import '../../../../core/config/route_name.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit()..loadProductData(),
      child: const ProductView(),
    );
  }
}

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Lắng nghe scroll để load more
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Xử lý khi scroll đến cuối danh sách
  void _onScroll() {
    if (_isBottom) {
      context.read<ProductCubit>().loadMoreProducts();
    }
  }

  /// Kiểm tra đã scroll đến cuối chưa
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load khi còn cách đáy 200px
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductError && state.requiresLogin) {
          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildCategoryTitle(),
                  const SizedBox(height: 16),
                  _buildCategoryTabs(context),
                  const SizedBox(height: 10),
                  _buildProductList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoaded) {
            return SharedBottomNavigation(
              currentIndex: state.selectedBottomNavIndex,
              onTap: (index) => context.read<ProductCubit>().changeBottomNavIndex(index),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final selectedMarket = state is ProductLoaded ? 'CHỢ BẮC MỸ AN' : 'Chọn chợ';
        final searchQuery = state is ProductLoaded ? state.searchQuery : '';
        
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Market Selector
                _buildMarketSelector(selectedMarket),
                const SizedBox(height: 12),
                
                // Search Bar Row
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: _buildSearchBar(context, searchQuery),
                    ),
                    const SizedBox(width: 12),
                    
                    // Cart Icon with Badge
                    CartIconWithBadge(
                      itemCount: state is ProductLoaded ? state.cartItemCount : 0,
                      onTap: () {
                        AppRouter.navigateTo(context, RouteName.cart);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, String searchQuery) {
    return GestureDetector(
      onTap: () {
        AppRouter.navigateTo(context, RouteName.search);
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 20,
              color: Color(0xFF8E8E93),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tìm kiếm món ăn...',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketSelector(String selectedMarket) {
    return GestureDetector(
      onTap: () {
        print('Chọn chợ');
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF008EDB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF008EDB),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giao đến',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedMarket,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xFF8E8E93),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Category tabs (horizontal scrollable)
  Widget _buildCategoryTabs(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded && state.categories.isNotEmpty) {
          return Container(
            height: 35,
            margin: const EdgeInsets.only(left: 25),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final isSelected = state.selectedCategory == category.maDanhMucMonAn;
                
                return GestureDetector(
                  onTap: () {
                    // Debug: Print category info
                    print('🔍 [CATEGORY] Bấm vào danh mục');
                    print('   Mã danh mục: ${category.maDanhMucMonAn}');
                    print('   Tên danh mục: ${category.tenDanhMucMonAn}');
                    
                    // Navigate to category product screen
                    AppRouter.navigateTo(
                      context,
                      RouteName.categoryProducts,
                      arguments: {
                        'categoryId': category.maDanhMucMonAn,
                        'categoryName': category.tenDanhMucMonAn,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: isSelected ? Border.all(color: const Color(0xFF008EDB)) : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.tenDanhMucMonAn,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.5,
                        color: isSelected ? const Color(0xFF008EDB) : const Color(0xFF000000),
                        height: 1.33,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        
        // Loading state
        return Container(
          height: 35,
          margin: const EdgeInsets.only(left: 25),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  /// Category title "Danh mục"
  Widget _buildCategoryTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 28),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Danh mục ',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.25,
            color: Color(0xFF000000),
            height: 1.18,
          ),
        ),
      ),
    );
  }

  /// Product list
  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ProductError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          );
        }

        if (state is ProductLoaded) {
          // Lấy danh sách món ăn từ state
          final monAnList = state.monAnList;

          if (monAnList.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có món ăn nào',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Container(
            color: const Color(0xFFFFFFFF),
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: monAnList.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Hiển thị loading indicator ở cuối danh sách
                if (index >= monAnList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final monAnWithImage = monAnList[index];
                final monAn = monAnWithImage.monAn;
                final imageUrl = monAnWithImage.imageUrl;

                return ProductListItem(
                  productName: monAn.tenMonAn,
                  imagePath: imageUrl.isNotEmpty 
                      ? imageUrl 
                      : 'assets/img/product_default.png', // Fallback nếu không có ảnh
                  servings: monAnWithImage.servings,
                  difficulty: monAnWithImage.difficulty,
                  cookTime: monAnWithImage.cookTime,
                  onViewDetail: () {
                    // Navigate to product detail screen với maMonAn
                    AppRouter.navigateTo(
                      context,
                      RouteName.productDetail,
                      arguments: monAn.maMonAn,
                    );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
