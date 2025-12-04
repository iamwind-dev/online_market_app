import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ingredient_cubit.dart';
import '../cubit/ingredient_state.dart';

class SellerIngredientScreen extends StatelessWidget {
  const SellerIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerIngredientCubit()..loadIngredients(),
      child: const _SellerIngredientView(),
    );
  }
}

class _SellerIngredientView extends StatelessWidget {
  const _SellerIngredientView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SellerIngredientCubit, SellerIngredientState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, state),
              const Divider(height: 4, thickness: 4, color: Color(0xFFD9D9D9)),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SellerIngredientCubit, SellerIngredientState>(
        builder: (context, state) {
          return _buildBottomNavigation(context, state);
        },
      ),
    );
  }

  /// Header với title, search và nút thêm
  Widget _buildHeader(BuildContext context, SellerIngredientState state) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      color: Colors.white,
      child: Column(
        children: [
          // Title
          const Text(
            'QUẢN LÝ SẢN PHẨM',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Search bar và nút Thêm
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.read<SellerIngredientCubit>().goBack(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              // Search icon
              const Icon(
                Icons.search,
                size: 12,
                color: Color(0xFF008EDB),
              ),
              const SizedBox(width: 8),
              // Search input
              Expanded(
                child: Container(
                  height: 31,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF5E5C5C)),
                    borderRadius: BorderRadius.circular(9998),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      context.read<SellerIngredientCubit>().updateSearchQuery(value);
                    },
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tên sản phẩm, ID,...',
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nút Thêm
              GestureDetector(
                onTap: () => context.read<SellerIngredientCubit>().navigateToAddIngredient(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B40F),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Thêm',
                    style: TextStyle(
                      fontFamily: 'Varta',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Body với danh sách sản phẩm
  Widget _buildBody(BuildContext context, SellerIngredientState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<SellerIngredientCubit>().refreshData(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final ingredients = state.filteredIngredients;

    if (ingredients.isEmpty) {
      return const Center(
        child: Text(
          'Không có sản phẩm nào',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SellerIngredientCubit>().refreshData(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: ingredients.length,
        separatorBuilder: (context, index) => const Divider(
          height: 4,
          thickness: 4,
          color: Color(0xFFD9D9D9),
        ),
        itemBuilder: (context, index) {
          return _buildIngredientItem(context, ingredients[index]);
        },
      ),
    );
  }

  /// Item sản phẩm
  Widget _buildIngredientItem(BuildContext context, SellerIngredient ingredient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                ingredient.imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 96,
                    height: 96,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID
                Text(
                  'ID: ${ingredient.id}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                // Tên sản phẩm
                Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Giá
                Text(
                  ingredient.formattedPrice,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    letterSpacing: 0.4,
                    color: Color(0xFFFF0000),
                  ),
                ),
                const SizedBox(height: 8),
                // Sẵn có và Đơn vị
                Text(
                  'Sẵn có: ${ingredient.availableQuantity}         Đơn vị: ${ingredient.unit}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Nút chỉnh sửa
          GestureDetector(
            onTap: () => context.read<SellerIngredientCubit>().navigateToEditIngredient(ingredient),
            child: const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Icon(
                Icons.edit,
                size: 16,
                color: Color(0xFF1C1B1F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigation(BuildContext context, SellerIngredientState state) {
    final cubit = context.read<SellerIngredientCubit>();

    return Container(
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Đơn hàng
          _buildNavItem(
            context,
            icon: Icons.receipt_long,
            label: 'Đơn hàng',
            isSelected: state.currentTabIndex == 0,
            onTap: () => cubit.changeTab(0),
          ),
          // Sản phẩm
          _buildNavItem(
            context,
            icon: Icons.shopping_bag,
            label: 'Sản phẩm',
            isSelected: state.currentTabIndex == 1,
            onTap: () => cubit.changeTab(1),
          ),
          // Avatar (Home)
          GestureDetector(
            onTap: () => cubit.changeTab(2),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.currentTabIndex == 2 ? const Color(0xFF00B40F) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/img/seller_home_avatar.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 58,
                      height: 58,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 30),
                    );
                  },
                ),
              ),
            ),
          ),
          // Doanh số
          _buildNavItem(
            context,
            icon: Icons.attach_money,
            label: 'Doanh số',
            isSelected: state.currentTabIndex == 3,
            onTap: () => cubit.changeTab(3),
          ),
          // Tài khoản
          _buildNavItem(
            context,
            icon: Icons.account_circle,
            label: 'Tài khoản',
            isSelected: state.currentTabIndex == 4,
            onTap: () => cubit.changeTab(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF00B40F) : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: isSelected ? const Color(0xFF00B40F) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
