import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/search_result_cubit.dart';
import '../cubit/search_result_state.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';
import '../../../../core/widgets/product_card.dart';

/// Search result screen displaying search results in a grid
class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  
  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchResultCubit()..loadSearchResults(query: searchQuery),
      child: _SearchResultScreenView(searchQuery: searchQuery),
    );
  }
}

class _SearchResultScreenView extends StatefulWidget {
  final String searchQuery;
  
  const _SearchResultScreenView({required this.searchQuery});

  @override
  State<_SearchResultScreenView> createState() => _SearchResultScreenViewState();
}

class _SearchResultScreenViewState extends State<_SearchResultScreenView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultCubit, SearchResultState>(
      builder: (context, state) {
        if (state is SearchResultLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SearchResultError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (state is SearchResultLoaded) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, state),
                  _buildMarketSelector(context, state),
                  Expanded(
                    child: _buildProductGrid(context, state),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SharedBottomNavigation(
              currentIndex: state.selectedBottomNavIndex,
              onTap: (index) {
                context.read<SearchResultCubit>().changeBottomNavIndex(index);
              },
            ),
          );
        }

        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text('Unknown state'),
          ),
        );
      },
    );
  }

  /// Build header with back button, search bar, search text, filter button, and quick add
  Widget _buildHeader(BuildContext context, SearchResultLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              context.read<SearchResultCubit>().navigateBack();
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/img/search_result_arrow_left.svg',
              width: 16,
              height: 16,
            ),
          ),
          const SizedBox(width: 27),
          // Search bar
          Expanded(
            child: Container(
              height: 31,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF5E5C5C), width: 1),
                borderRadius: BorderRadius.circular(9998),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    'assets/img/search_result_search_icon.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF008EDB),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      state.searchQuery,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.0,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Quick add button
          GestureDetector(
            onTap: () {
              context.read<SearchResultCubit>().quickAddItem(state.searchQuery);
            },
            child: const Text(
              '+',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 25,
                height: 1.0,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter button
          GestureDetector(
            onTap: () {
              context.read<SearchResultCubit>().navigateToFilter();
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/img/search_result_tune_icon.svg',
                  width: 29,
                  height: 27,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Lọc',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    height: 1.176,
                    letterSpacing: 0.25,
                    color: Color(0xFF008EDB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build market selector with location
  Widget _buildMarketSelector(BuildContext context, SearchResultLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/img/search_result_location_icon.svg',
            width: 25,
            height: 21,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedMarket,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.222,
                    color: Color(0xFF008EDB),
                  ),
                ),
                Text(
                  state.selectedLocation,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.692,
                    color: Color(0xFF008EDB),
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/img/search_result_dropdown_icon.svg',
            width: 15,
            height: 16,
          ),
        ],
      ),
    );
  }

  /// Build product grid
  Widget _buildProductGrid(BuildContext context, SearchResultLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 15),
              child: Text(
                'Hiển thị kết quả tìm kiếm ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  height: 1.0,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 17,
                childAspectRatio: 173 / 233,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return _buildProductCard(context, product);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual product card
  Widget _buildProductCard(BuildContext context, SearchResultProduct product) {
    final cubit = context.read<SearchResultCubit>();
    
    return ProductCard(
      title: product.name,
      price: product.price,
      soldCount: product.salesCount,
      imagePath: product.imagePath,
      onFavoriteTap: () {
        // Handle favorite tap
      },
      onAddToCart: () {
        cubit.quickAddItem(product.name);
      },
      onBuyNow: () {
        cubit.navigateToProductDetail(product);
      },
    );
  }
}
