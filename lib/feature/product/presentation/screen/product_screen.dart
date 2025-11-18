import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';
import '../../../../core/widgets/product_list_item.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchSection(context),
            const SizedBox(height: 16),
            _buildCategoryTitle(),
            const SizedBox(height: 16),
            _buildCategoryTabs(context),
            const SizedBox(height: 10),
            Expanded(
              child: _buildProductList(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SharedBottomNavigation(currentIndex: 1),
      ),
    );
  }

  /// Header với location selector
  Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        const Icon(
          Icons.location_on,
          size: 20,
          color: Color(0xFF008EDB),
        ),
        const SizedBox(width: 6),

        // Text "Chọn chợ" + dropdown icon LIỀN NHAU
        GestureDetector(
          onTap: () {
            // mở bottom sheet chọn chợ
          },
          child: Row(
            children: const [
              Text(
                "Chọn chợ",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF008EDB),
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Color(0xFF008EDB),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  /// Search section với back button, search bar và filter
  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 14),
          
          // Search bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to search screen
                AppRouter.navigateTo(context, RouteName.search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF5E5C5C)),
                  borderRadius: BorderRadius.circular(9998),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/img/Search.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF008EDB),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Tìm kiếm món ăn...',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Color(0xFFB3B3B3),
                        ),
                      ),
                    ),
                    GestureDetector(
                    onTap: () {
                      print("Clear search tapped"); 
                      // Tùy bạn: clear text, reset state, ...
                    },
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          // Add button
          const SizedBox(width: 14),
          
          // Filter button
          const Icon(
            Icons.tune,
            size: 27,
            color: Color(0xFF008EDB),
          ),
          const SizedBox(width: 8),
          const Text(
            'Lọc',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF008EDB),
              height: 1.18,
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
