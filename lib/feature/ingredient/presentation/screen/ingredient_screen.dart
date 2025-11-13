import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ingredient_cubit.dart';
import '../cubit/ingredient_state.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';

class IngredientScreen extends StatelessWidget {
  const IngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IngredientCubit()..loadIngredientData(),
      child: const _IngredientView(),
    );
  }
}

class _IngredientView extends StatelessWidget {
  const _IngredientView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, state) {
          if (state is IngredientLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IngredientError) {
            return Center(child: Text(state.message));
          }

          if (state is IngredientLoaded) {
            return _buildIngredientContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, state) {
          if (state is IngredientLoaded) {
            return SharedBottomNavigation(
              currentIndex: state.selectedBottomNavIndex,
              onTap: (index) => context.read<IngredientCubit>().changeBottomNavIndex(index),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildIngredientContent(BuildContext context, IngredientLoaded state) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, state),
          Expanded(
            child: _buildScrollableContent(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, IngredientLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 16),
              ),
              const SizedBox(width: 27),
              _buildSearchBar(context, state),
              const SizedBox(width: 13),
              GestureDetector(
                onTap: () => context.read<IngredientCubit>().navigateToFilter(),
                child: const Row(
                  children: [
                    Icon(Icons.tune, size: 29, color: Color(0xFF000000)),
                    SizedBox(width: 4),
                    Text(
                      'Lọc',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF008EDB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMarketSelector(state),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, IngredientLoaded state) {
    return Expanded(
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF5E5C5C)),
          borderRadius: BorderRadius.circular(9998),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 16, color: Color(0xFF008EDB)),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  context.read<IngredientCubit>().updateSearchQuery(value);
                },
                onSubmitted: (_) => context.read<IngredientCubit>().performSearch(),
                decoration: const InputDecoration(
                  hintText: '      ',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFFB3B3B3),
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
    );
  }

  Widget _buildMarketSelector(IngredientLoaded state) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Color(0xFF008EDB), size: 25),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MM, ĐÀ NẴNG',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF008EDB),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  state.selectedMarket,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF008EDB),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 15, color: Color(0xFF008EDB)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context, IngredientLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildCategorySection(context, state),
          const SizedBox(height: 30),
          _buildAdditionalCategories(context, state),
          const SizedBox(height: 20),
          _buildProductsSection(context, state),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, IngredientLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: state.categories.map((category) {
              return _buildCategoryItem(context, category);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => context.read<IngredientCubit>().selectCategory(category.name),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              category.imagePath,
              width: category.name == 'Rau củ' ? 59 : category.name == 'Trái cây' ? 64 : category.name == 'Thịt' ? 56 : category.name == 'Thuỷ sản' ? 57 : 55,
              height: category.name == 'Rau củ' ? 41 : category.name == 'Trái cây' ? 40 : category.name == 'Thịt' ? 40 : category.name == 'Thuỷ sản' ? 40 : 37,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.category, size: 20),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category.name,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalCategories(BuildContext context, IngredientLoaded state) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 367),
        itemCount: state.additionalCategories.length,
        itemBuilder: (context, index) {
          final category = state.additionalCategories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 19),
            child: _buildAdditionalCategoryItem(context, category),
          );
        },
      ),
    );
  }

  Widget _buildAdditionalCategoryItem(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => context.read<IngredientCubit>().selectCategory(category.name),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              category.imagePath,
              width: category.name == 'Dưỡng thể' ? 54 : category.name == 'Gia vị' ? 64 : category.name == 'Sữa các loại' ? 72 : 50,
              height: category.name == 'Dưỡng thể' ? 54 : category.name == 'Gia vị' ? 55 : category.name == 'Sữa các loại' ? 52 : 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.category, size: 20),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context, IngredientLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.products.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 0.7,
          color: Color(0x2E5E5C5C),
        ),
        itemBuilder: (context, index) {
          final product = state.products[index];
          final shopName = index < state.shopNames.length ? state.shopNames[index] : '';
          return _buildProductItem(context, product, shopName);
        },
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product, String shopName) {
    return Container(
      color: const Color(0x127A7676),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              children: [
                Image.asset(
                  product.imagePath,
                  width: 137,
                  height: product.hasDiscount ? 100 : 97,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 137,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    );
                  },
                ),
                // MM Logo
                Positioned(
                  top: 1,
                  left: 2,
                  child: Image.asset(
                    'assets/img/ingredient_mm_logo.png',
                    width: 18.35,
                    height: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 17),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.58,
                  ),
                ),
                const SizedBox(height: 8),
                if (product.hasDiscount && product.originalPrice != null) ...[
                  Row(
                    children: [
                      Image.asset(
                        'assets/img/ingredient_product_1.png',
                        width: 38,
                        height: 11,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(width: 38, height: 11);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.originalPrice!,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF0000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  product.price,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF0000),
                  ),
                ),
                const SizedBox(height: 6),
                if (product.badge != null)
                  Container(
                    height: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: product.badge == 'Flash sale' ? const Color(0xFFF73A3A) : const Color(0xFFF58787),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      product.badge!,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        height: 3.14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.read<IngredientCubit>().buyNow(product),
                  child: Container(
                    width: 92,
                    height: 34.2,
                    decoration: BoxDecoration(
                      color: const Color(0xDD2F8000),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Mua ngay',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
}
