import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomeData(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text(state.message));
          }

          if (state is HomeLoaded) {
            return _buildHomeContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            return SharedBottomNavigation(
              currentIndex: state.selectedBottomNavIndex,
              onTap: (index) => context.read<HomeCubit>().changeBottomNavIndex(index),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildMarketSelector(context, state),
            const SizedBox(height: 16),
            _buildMainContent(context, state),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Market Selector Header
  Widget _buildMarketSelector(BuildContext context, HomeLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF008EDB), size: 25),
          const SizedBox(width: 5),
          Text(
            state.selectedMarket,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF008EDB),
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF008EDB), size: 16),
        ],
      ),
    );
  }

  /// Main Content Container
  Widget _buildMainContent(BuildContext context, HomeLoaded state) {
    return Container(
      margin: const EdgeInsets.all(22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF9E4).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0272BA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(),
          const SizedBox(height: 20),
          _buildSearchSection(context, state),
          const SizedBox(height: 20),
          _buildTrendingSection(),
          const SizedBox(height: 20),
          _buildFoodBanner(),
          const SizedBox(height: 20),
          _buildSellerBanner(context),
        ],
      ),
    );
  }

  /// Greeting Section with Chef Image
  Widget _buildGreetingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontWeight: FontWeight.w700,
                fontSize: 25,
                color: Color(0xFF517907),
                height: 1.2,
              ),
              children: [
                TextSpan(text: 'Chào buổi sáng,\n'),
                TextSpan(text: 'Bạn muốn nấu món\n'),
                TextSpan(text: 'gì hôm nay?'),
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/img/home_chef_image.png',
          width: 90,
          height: 76,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 90,
              height: 76,
              color: Colors.grey[300],
              child: const Icon(Icons.restaurant, size: 40),
            );
          },
        ),
      ],
    );
  }

  /// Search Section with Input and Buttons
  Widget _buildSearchSection(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDCF9E4).withOpacity(0.5),
            borderRadius: BorderRadius.circular(9998),
            border: Border.all(color: const Color(0xFF5E5C5C)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    context.read<HomeCubit>().updateSearchQuery(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Nhập món ăn hoặc nguyên liệu cần tìm tại đây ...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF5E5C5C),
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action Buttons
        Row(
          children: [
            _buildActionButton(
              context,
              'Tìm kiếm',
              () => context.read<HomeCubit>().performSearch(),
            ),
            const SizedBox(width: 38),
            _buildActionButton(
              context,
              'Gợi ý bằng AI',
              () => context.read<HomeCubit>().performAISuggestion(),
            ),
          ],
        ),
      ],
    );
  }

  /// Action Button (Search, AI Suggestion)
  Widget _buildActionButton(BuildContext context, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00B40F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Trending Section
  Widget _buildTrendingSection() {
    return const Text(
      'Hôm nay mọi người đang tìm',
      style: TextStyle(
        fontFamily: 'Fraunces',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.black,
        height: 1.67,
      ),
    );
  }

  /// Food Banner Image
  Widget _buildFoodBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/img/home_banner_food-399bb4.png',
        width: double.infinity,
        height: 125,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 125,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50),
          );
        },
      ),
    );
  }

  /// Seller Banner Section
  Widget _buildSellerBanner(BuildContext context) {
    return Container(
      height: 161,
      decoration: BoxDecoration(
        color: const Color(0xFF00B40F).withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Mở gian hàng của bạn ngay hôm nay - Bán cùng DNGo!',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF517907),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => context.read<HomeCubit>().navigateToSellerRegistration(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B40F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đăng kí người bán',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
