import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/product_list_item.dart';
import '../../../../../core/widgets/cart_badge_icon.dart';
import '../../../../../core/widgets/market_selector.dart';
import '../../../../../core/config/route_name.dart';
import '../../../../../core/router/app_router.dart';
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
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildCategoryTitle(),
                        const SizedBox(height: 16),
                        _buildCategoryTabs(context),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  _buildProductList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final searchQuery = state is ProductLoaded ? state.searchQuery : '';
        final selectedRegion = state is ProductLoaded ? state.selectedRegion : null;
        final selectedRegionMa = state is ProductLoaded ? state.selectedRegionMa : null;
        final selectedMarket = state is ProductLoaded ? state.selectedMarket : null;
        final selectedMarketMa = state is ProductLoaded ? state.selectedMarketMa : null;
        
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
                // MarketSelector(
                //   selectedRegion: selectedRegion,
                //   selectedRegionMa: selectedRegionMa,
                //   selectedMarket: selectedMarket,
                //   selectedMarketMa: selectedMarketMa,
                //   onRegionSelected: (maKhuVuc, tenKhuVuc) {
                //     context.read<ProductCubit>().selectRegion(maKhuVuc, tenKhuVuc);
                //   },
                //   onMarketSelected: (maCho, tenCho) {
                //     context.read<ProductCubit>().selectMarket(maCho, tenCho);
                //   },
                // ),
                // const SizedBox(height: 12),
                
                // Search Bar Row
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: _buildSearchBar(context, searchQuery),
                    ),
                    const SizedBox(width: 12),
                    
                    // Cart Icon with Badge
                    const CartBadgeIcon(
                iconSize: 26,
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
                'Tìm kiếm món ăn..',
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
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is ProductError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        if (state is ProductLoaded) {
          // Lấy danh sách món ăn từ state
          final monAnList = state.monAnList;

          if (monAnList.isEmpty) {
            return const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Chưa có món ăn nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                        : 'assets/img/product_default.png',
                    servings: monAnWithImage.servings,
                    difficulty: monAnWithImage.difficulty,
                    cookTime: monAnWithImage.cookTime,
                    onViewDetail: () {
                      AppRouter.navigateTo(
                        context,
                        RouteName.productDetail,
                        arguments: monAn.maMonAn,
                      );
                    },
                  );
                },
                childCount: monAnList.length + (state.isLoadingMore ? 1 : 0),
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
