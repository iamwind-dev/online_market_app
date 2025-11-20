import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// Build header with back button and search bar (giống product_screen)
  Widget _buildHeader(BuildContext context, SearchLoaded state) {
    return Container(
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
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              context.read<SearchCubit>().navigateBack();
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          
          // Search bar (giống product_screen)
          Expanded(
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
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
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
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        color: Color(0xFF1C1C1E),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm món ăn...',
                        hintStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          color: Color(0xFF8E8E93),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (state.searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        context.read<SearchCubit>().updateSearchQuery('');
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search history section - list đơn giản nhưng đẹp mắt
  Widget _buildSearchHistory(BuildContext context, SearchLoaded state) {
    if (state.searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            'Tìm kiếm gần đây',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
              letterSpacing: 0.2,
            ),
          ),
        ),
        
        // Divider
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE0E0E0),
          ),
        ),
        const SizedBox(height: 4),
        
        // History items
        ...state.searchHistory.asMap().entries.map((entry) {
          final item = entry.value;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultScreen(searchQuery: item),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    // History icon
                    const Icon(
                      Icons.history,
                      size: 20,
                      color: Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 14),
                    
                    // Search term
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color(0xFF1C1C1E),
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Arrow icon
                    const Icon(
                      Icons.north_west,
                      size: 18,
                      color: Color(0xFF8E8E93),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
