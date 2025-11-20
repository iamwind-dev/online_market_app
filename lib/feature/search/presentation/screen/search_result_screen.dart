import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/search_result_cubit.dart';
import '../cubit/search_result_state.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';
import '../../../../core/widgets/product_list_item.dart';
import '../../../../core/config/route_name.dart';
import '../../../../core/router/app_router.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    // Lắng nghe scroll để load more
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Xử lý khi scroll đến cuối danh sách
  void _onScroll() {
    if (_isBottom) {
      context.read<SearchResultCubit>().loadMoreResults();
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

  /// Build header with back button and search bar (giống product_screen)
  Widget _buildHeader(BuildContext context, SearchResultLoaded state) {
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
              context.read<SearchResultCubit>().navigateBack();
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
            child: GestureDetector(
              onTap: () {
                // Quay lại search screen để edit query
                Navigator.pop(context);
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
                    Expanded(
                      child: Text(
                        state.searchQuery,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Filter button
          GestureDetector(
            onTap: () {
              context.read<SearchResultCubit>().navigateToFilter();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF008EDB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tune,
                size: 24,
                color: Color(0xFF008EDB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build market selector (giống ingredient_screen)
  Widget _buildMarketSelector(BuildContext context, SearchResultLoaded state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // Open market selector
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
                          state.selectedMarket,
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
      ),
    );
  }

  /// Build product list
  Widget _buildProductGrid(BuildContext context, SearchResultLoaded state) {
    final monAnList = state.monAnList;

    if (monAnList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Không tìm thấy món ăn nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
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
              : 'assets/img/product_default.png',
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
    );
  }
}
