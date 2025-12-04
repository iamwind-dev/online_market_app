import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/add_ingredient_cubit.dart';
import '../cubit/add_ingredient_state.dart';

class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddIngredientCubit()..initialize(),
      child: const _AddIngredientView(),
    );
  }
}

class _AddIngredientView extends StatelessWidget {
  const _AddIngredientView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: BlocConsumer<AddIngredientCubit, AddIngredientState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<AddIngredientCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.read<AddIngredientCubit>().clearMessages();
            // Navigate back after success
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(context),
              const Divider(height: 2, thickness: 2, color: Color(0xFFD9D9D9)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildSectionTitle('THÔNG TIN SẢN PHẨM'),
                      const SizedBox(height: 8),
                      _buildImageSection(context, state),
                      const Divider(height: 5, thickness: 5, color: Color(0xFFD9D9D9)),
                      _buildProductNameSection(context, state),
                      _buildCategorySection(context, state),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context, state),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<AddIngredientCubit, AddIngredientState>(
        builder: (context, state) {
          return _buildBottomNavigation(context, state);
        },
      ),
    );
  }

  /// Header với title và nút back
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 12),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AddIngredientCubit>().goBack(),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.black,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'THÊM SẢN PHẨM',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.5,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16), // Balance for back button
        ],
      ),
    );
  }

  /// Section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          letterSpacing: 0.5,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Section chọn ảnh sản phẩm
  Widget _buildImageSection(BuildContext context, AddIngredientState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 19, bottom: 8),
            child: Text(
              'Ảnh sản phẩm',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<AddIngredientCubit>().pickImage(),
            child: Container(
              width: double.infinity,
              height: 99,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: state.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        state.imagePath!,
                        width: double.infinity,
                        height: 99,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/img/seller_add_ingredient_placeholder.png',
      width: double.infinity,
      height: 99,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 99,
          color: Colors.grey[200],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Thêm ảnh sản phẩm',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section tên sản phẩm
  Widget _buildProductNameSection(BuildContext context, AddIngredientState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 19, bottom: 8),
            child: Text(
              'Tên sản phẩm',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) {
                    context.read<AddIngredientCubit>().updateProductName(value);
                  },
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Đề xuất tên sản phẩm nên dài hơn 15 kí tự',
                    hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.productName.length}/15 ký tự tối thiểu',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: state.productName.length >= 15
                        ? const Color(0xFF00B40F)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section chọn danh mục
  Widget _buildCategorySection(BuildContext context, AddIngredientState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 19, bottom: 8),
            child: Text(
              'Danh mục',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showCategoryPicker(context, state),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.selectedCategory?.name ?? 'Chọn danh mục',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: state.selectedCategory != null
                          ? Colors.black
                          : Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF1C1B1F),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị bottom sheet chọn danh mục
  void _showCategoryPicker(BuildContext context, AddIngredientState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn danh mục',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...state.categories.map((category) {
                final isSelected = state.selectedCategory?.id == category.id;
                return ListTile(
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: isSelected ? const Color(0xFF00B40F) : Colors.black,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF00B40F))
                      : null,
                  onTap: () {
                    context.read<AddIngredientCubit>().selectCategory(category);
                    Navigator.pop(bottomSheetContext);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Bottom actions (Hủy và Đăng sản phẩm)
  Widget _buildBottomActions(BuildContext context, AddIngredientState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      color: Colors.white,
      child: Row(
        children: [
          // Nút Hủy
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<AddIngredientCubit>().cancel(),
              child: Container(
                height: 51,
                decoration: BoxDecoration(
                  color: const Color(0xFFB1B1B1),
                  borderRadius: BorderRadius.circular(534),
                ),
                child: const Center(
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontFamily: 'Varta',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 29),
          // Nút Đăng sản phẩm
          Expanded(
            child: GestureDetector(
              onTap: state.isSubmitting
                  ? null
                  : () => context.read<AddIngredientCubit>().submitProduct(),
              child: Container(
                height: 51,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B40F),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Center(
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Đăng sản phẩm',
                          style: TextStyle(
                            fontFamily: 'Varta',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigation(BuildContext context, AddIngredientState state) {
    final cubit = context.read<AddIngredientCubit>();

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
                  color: state.currentTabIndex == 2
                      ? const Color(0xFF00B40F)
                      : Colors.transparent,
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
