import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';
import 'search_result_screen.dart';

/// Search screen with search history and product recommendations
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit()..loadSearchData(),
      child: const _SearchScreenView(),
    );
  }
}

class _SearchScreenView extends StatefulWidget {
  const _SearchScreenView();

  @override
  State<_SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<_SearchScreenView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SearchError) {
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

        if (state is SearchLoaded) {
          // Set initial search query
          if (_searchController.text != state.searchQuery) {
            _searchController.text = state.searchQuery;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildSearchHistory(context, state),
                          const SizedBox(height: 20),
                          _buildRecommendedProducts(context, state),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SharedBottomNavigation(
              currentIndex: state.selectedBottomNavIndex,
              onTap: (index) {
                context.read<SearchCubit>().changeBottomNavIndex(index);
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

  /// Build header with back button, search bar, and search button
  Widget _buildHeader(BuildContext context, SearchLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              context.read<SearchCubit>().navigateBack();
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/img/search_arrow_left.svg',
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
                    'assets/img/search_icon.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF008EDB),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        context.read<SearchCubit>().updateSearchQuery(value);
                      },
                      onSubmitted: (_) {
                        final query = _searchController.text;
                        if (query.isNotEmpty) {
                          context.read<SearchCubit>().performSearch();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchResultScreen(searchQuery: query),
                            ),
                          );
                        }
                      },
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.0,
                        color: Color(0xFFB3B3B3),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '',
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Search button
          GestureDetector(
            onTap: () {
              final query = _searchController.text;
              if (query.isNotEmpty) {
                context.read<SearchCubit>().performSearch();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultScreen(searchQuery: query),
                  ),
                );
              }
            },
            child: const Text(
              'Tìm kiếm',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 17,
                height: 1.176,
                letterSpacing: 0.25,
                color: Color(0xFF0272BA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search history section with quick add buttons
  Widget _buildSearchHistory(BuildContext context, SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.searchHistory.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            left: 13,
            right: 13,
            top: index == 0 ? 0 : 5,
          ),
          child: GestureDetector(
            onTap: () {
              // Navigate to search result with this history item
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchResultScreen(searchQuery: item),
                ),
              );
            },
            child: Row(
              children: [
                // History icon
                SvgPicture.asset(
                  'assets/img/search_history_icon.svg',
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 9),
                // Search term
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.0,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                // Quick add button
                GestureDetector(
                  onTap: () {
                    context.read<SearchCubit>().quickAddItem(item);
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
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build recommended products section
  Widget _buildRecommendedProducts(BuildContext context, SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 18),
          child: Text(
            'Có thể bạn cũng thích',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              height: 1.0,
              letterSpacing: 0.51,
              color: Color(0xFF000000),
            ),
          ),
        ),
        const SizedBox(height: 22),
        ...state.recommendedProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          return GestureDetector(
            onTap: () {
              context.read<SearchCubit>().navigateToProductDetail(product);
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: index < state.recommendedProducts.length - 1 ? 18 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Container(
                    width: 67,
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF707070),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        product.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 19),
                  // Product name
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: 1.25,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
