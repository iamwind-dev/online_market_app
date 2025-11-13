import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(child: Text(state.message));
          }

          if (state is ProductLoaded) {
            return _buildProductContent(context, state);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, ProductLoaded state) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, state),
          Expanded(
            child: _buildScrollableContent(context, state),
          ),
          _buildBottomNavigation(context, state),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProductLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMarketSelector(context),
          const SizedBox(height: 16),
          _buildSearchBar(context, state),
        ],
      ),
    );
  }

  Widget _buildMarketSelector(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/img/location_on.svg',
          width: 25,
          height: 21,
          colorFilter: const ColorFilter.mode(
            Color(0xFF008EDB),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          'CHỢ BẮC MỸ AN',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF008EDB),
          ),
        ),
        const SizedBox(width: 5),
        SvgPicture.asset(
          'assets/img/home_dropdown_icon.svg',
          width: 15,
          height: 16,
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ProductLoaded state) {
    final cubit = context.read<ProductCubit>();

    return Row(
      children: [
        Expanded(
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
                  'assets/img/home_search_icon.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: cubit.updateSearchQuery,
                    onSubmitted: (_) => cubit.performSearch(),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF5E5C5C),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(
          'assets/img/add_shopping_cart.svg',
          width: 27,
          height: 26,
        ),
        const SizedBox(width: 10),
        SvgPicture.asset(
          'assets/img/language.svg',
          width: 28,
          height: 28,
        ),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context, ProductLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(context, state),
          const SizedBox(height: 20),
          _buildFilterSection(context, state),
          const SizedBox(height: 20),
          _buildMenuSection(context),
          const SizedBox(height: 20),
          _buildShopsSection(context),
          const SizedBox(height: 20),
          _buildBannerSection(context),
          const SizedBox(height: 20),
          _buildProductsSection(context, state),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ProductLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 390,
            height: 5,
            color: const Color(0xFFD9D9D9),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, ProductLoaded state) {
    final cubit = context.read<ProductCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh mục ',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.25,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'Món chay',
                  state.selectedFilters.contains('Món chay'),
                  () => cubit.toggleFilter('Món chay'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Công thức',
                  state.selectedFilters.contains('Công thức'),
                  () => cubit.toggleFilter('Công thức'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Món ngon',
                  state.selectedFilters.contains('Món ngon'),
                  () => cubit.toggleFilter('Món ngon'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Yêu thích',
                  state.selectedFilters.contains('Yêu thích'),
                  () => cubit.toggleFilter('Yêu thích'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Món ăn kiêng',
                  state.selectedFilters.contains('Món ăn kiêng'),
                  () => cubit.toggleFilter('Món ăn kiêng'),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: cubit.openFilterDialog,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF9E4),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Bộ lọc',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/img/product_chevron_right.svg',
                          width: 15,
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B40F) : const Color(0xFFDCF9E4),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thực đơn hôm nay',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMenuItem(context, 'assets/img/product_menu_image_2.png',
                  'Bún măng vịt'),
              _buildMenuItem(context, 'assets/img/product_menu_image_1.png',
                  'Gà kho sả ớt'),
              _buildMenuItem(
                  context, 'assets/img/product_menu_image_3.png', 'Bún bò Huế'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String imagePath, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.asset(
            imagePath,
            width: 103,
            height: 103,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildShopsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gian hàng nổi bật',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25,
                ),
              ),
              SvgPicture.asset(
                'assets/img/product_chevron_right.svg',
                width: 15,
                height: 15,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShopItem(context, 'Tên gian hàng'),
              _buildShopItem(context, 'Tên gian hàng'),
              _buildShopItem(context, 'Tên gian hàng'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, String name) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/img/product_shop_image.png',
            width: 106,
            height: 79,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mua thực phẩm tươi mỗi ngày ',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF517907),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/img/product_banner.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                flex: 2,
                child: Text(
                  'Từ rau xanh đến cá tươi – tất cả đều có trên DNGo.\nChọn món bạn cần, phần còn lại để DNGo lo!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B40F),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Khám phá ngay',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context, ProductLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 5, bottom: 10),
            child: Text(
              'Nguyên liệu chế biến',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.74,
              crossAxisSpacing: 19,
              mainAxisSpacing: 17,
            ),
            itemCount: 8, // Demo 8 sản phẩm
            itemBuilder: (context, index) {
              return _buildProductCard(context, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final cubit = context.read<ProductCubit>();

    // Mock data
    final products = [
      {
        'name': 'Lốc 6 lon nước ngọt Coca...',
        'price': '53.000đ',
        'sold': '106 lượt bán',
        'status': 'Đang bán chạy',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Tã sơ sinh Mony Newborn...',
        'price': '295.000đ',
        'sold': '270 lượt bán',
        'status': 'Đang bán chạy',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Táo Đỏ Tân Cương loại 1...',
        'price': '193.000đ',
        'sold': '5 lượt bán',
        'status': 'Đã bán',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Xúc xích Đức LC Foods, bịc...',
        'price': '77.000đ',
        'sold': '375 lượt bán',
        'status': 'Đang bán chạy',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Dưa cải chua ngọt King\'s c...',
        'price': '31.000đ',
        'sold': '75 lượt bán',
        'status': 'Đã bán',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Canh bí đỏ thịt xay, 500 gra...',
        'price': '34.000đ',
        'sold': '430 lượt bán',
        'status': 'Đang bán chạy',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Dầu ăn đậu nành Simply 1...',
        'price': '77.000đ',
        'sold': '70 lượt bán',
        'status': 'Đã bán',
        'image': 'assets/img/product_mm_logo.png'
      },
      {
        'name': 'Bánh bao Thọ Phát nhân...',
        'price': '37.000đ',
        'sold': '170 lượt bán',
        'status': 'Đang bán chạy',
        'image': 'assets/img/product_mm_logo.png'
      },
    ];

    final product = products[index % products.length];

    return GestureDetector(
      onTap: () => cubit.viewProductDetail('product_$index'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDCF9E4).withOpacity(0.43),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.asset(
                    product['image']!,
                    height: 167,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => cubit.toggleFavorite('product_$index'),
                    child: SvgPicture.asset(
                      'assets/img/product_favorite_icon.svg',
                      width: 10,
                      height: 9,
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']!,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['sold']!,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product['status'] == 'Đang bán chạy'
                              ? const Color(0xFFF58787)
                              : const Color(0xFFF73A3A),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          product['status']!,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, ProductLoaded state) {
    final cubit = context.read<ProductCubit>();

    return Container(
      height: 69,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            'assets/img/add_home.svg',
            'Trang chủ',
            0,
            state.selectedBottomNavIndex == 0,
            () => cubit.changeBottomNavIndex(0),
          ),
          _buildNavItem(
            context,
            null,
            'Sản phẩm',
            1,
            state.selectedBottomNavIndex == 1,
            () => cubit.changeBottomNavIndex(1),
            isGift: true,
          ),
          // Center logo
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Image.asset(
              'assets/img/home_bottom_nav_icon.png',
              width: 58,
              height: 67,
            ),
          ),
          _buildNavItem(
            context,
            'assets/img/wifi_notification.svg',
            'Thông báo',
            3,
            state.selectedBottomNavIndex == 3,
            () => cubit.changeBottomNavIndex(3),
          ),
          _buildNavItem(
            context,
            'assets/img/account_circle.svg',
            'Tài khoản',
            4,
            state.selectedBottomNavIndex == 4,
            () => cubit.changeBottomNavIndex(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String? iconPath,
    String label,
    int index,
    bool isSelected,
    VoidCallback onTap, {
    bool isGift = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath,
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFF00B40F) : Colors.black,
                  BlendMode.srcIn,
                ),
              )
            else if (isGift)
              Icon(
                Icons.card_giftcard,
                size: 30,
                color: isSelected ? const Color(0xFF00B40F) : Colors.black,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected ? const Color(0xFF00B40F) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
