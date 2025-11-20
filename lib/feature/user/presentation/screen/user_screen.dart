import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';
import '../../../../core/widgets/shared_bottom_navigation.dart';
import '../../../../core/dependency/injection.dart';
import '../../../../core/services/auth/auth_service.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(authService: getIt<AuthService>())..loadUserData(),
      child: const _UserView(), // Bỏ AuthGuard để tránh check 2 lần
    );
  }
}

class _UserView extends StatelessWidget {
  const _UserView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          // Chuyển hướng đến trang login nếu phiên đăng nhập hết hạn
          if (state.requiresLogin) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
            return;
          }
          
          // Hiển thị lỗi nếu có
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Đóng',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              _buildScrollableContent(context, state),
              _buildHeader(),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return SharedBottomNavigation(
            currentIndex: state.selectedBottomNavIndex,
            onTap: (index) => context.read<UserCubit>().changeBottomNavIndex(index),
          );
        },
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, UserState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 77),
          _buildProfileSection(context, state),
          const SizedBox(height: 23),
          _buildMyOrdersSection(context, state),
          const SizedBox(height: 16),
          _buildOrderStatusSection(state),
          const SizedBox(height: 16),
          _buildUtilitiesSection(context),
          const SizedBox(height: 40),
          _buildLogoutButton(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 77,
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: Text(
              'Tài khoản',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.29,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Stack(
            children: [
              // Profile image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(49),
                  image: DecorationImage(
                    image: AssetImage(state.userImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // White circle border
              Positioned(
                top: -2,
                left: -2,
                child: Container(
                  width: 42.29,
                  height: 40.81,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              state.userName,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.76,
                letterSpacing: -0.21,
                color: Color(0xFF000000),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<UserCubit>().navigateToEditProfile(),
            child: Icon(Icons.edit, size: 15, color: Color(0xFF000000)),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => context.read<UserCubit>().navigateToSettings(),
            child: Icon(Icons.settings, size: 24, color: Color(0xFF000000)),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => context.read<UserCubit>().navigateToCart(),
            child: Icon(Icons.add_shopping_cart, size: 21.74, color: Color(0xFFD9D9D9)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrdersSection(BuildContext context, UserState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Text(
        'Đơn hàng của tôi',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          height: 1.29,
          color: Color(0xFF202020),
        ),
      ),
    );
  }

  Widget _buildOrderStatusSection(UserState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
      height: 99,
      decoration: BoxDecoration(
        color: Color(0xFFD7FFBD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOrderStatusItem('Chờ Xác Nhận', state.pendingOrders),
          _buildOrderStatusItem('Đang Xử Lý', state.processingOrders),
          _buildOrderStatusItem('Đang Giao', state.shippingOrders),
          _buildOrderStatusItem('Giao Thành Công', state.completedOrders),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 30,
            height: 0.73,
            color: Color(0xFF292D32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: label == 'Giao Thành Công' ? FontWeight.w500 : FontWeight.w500,
            fontSize: 12,
            height: 1.25,
            letterSpacing: -0.16,
            color: Color(0xFF2CCE75),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Tiện ích',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              height: 1.76,
              letterSpacing: -0.21,
              color: Color(0xFF000000),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildUtilityItem(
          context,
          icon: Icons.favorite_border,
          label: 'Yêu thích',
          onTap: () => context.read<UserCubit>().navigateToFavorites(),
        ),
        const SizedBox(height: 25),
        _buildUtilityItem(
          context,
          icon: Icons.credit_card,
          label: 'MCard',
          onTap: () => context.read<UserCubit>().navigateToMCard(),
        ),
        const SizedBox(height: 25),
        _buildUtilityItem(
          context,
          icon: Icons.policy,
          label: 'Điều khoản sử dụng',
          onTap: () => context.read<UserCubit>().navigateToTermsOfService(),
        ),
        const SizedBox(height: 25),
        _buildUtilityItem(
          context,
          icon: Icons.language,
          label: 'Ngôn ngữ',
          onTap: () => context.read<UserCubit>().navigateToLanguage(),
        ),
        const SizedBox(height: 25),
        _buildUtilityItem(
          context,
          icon: Icons.contact_support,
          label: 'Chăm sóc khách hàng',
          onTap: () => context.read<UserCubit>().navigateToCustomerCare(),
        ),
        const SizedBox(height: 25),
        _buildUtilityItem(
          context,
          icon: Icons.report,
          label: 'Hỗ trợ',
          onTap: () => context.read<UserCubit>().navigateToSupport(),
        ),
        const SizedBox(height: 25),
        _buildUtilityItem(
          context,
          icon: Icons.delete,
          label: 'Xóa tài khoản',
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildUtilityItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 33),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Color(0xFF000000)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                  height: 0.88,
                  letterSpacing: -0.16,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 17, color: Color(0xFF000000)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Text(
          'Đăng Xuất',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            height: 1.29,
            letterSpacing: -0.18,
            color: Color(0xFF02CCE75),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Đóng dialog trước
              Navigator.pop(dialogContext);
              
              // Gọi logout từ cubit
              await context.read<UserCubit>().logout();
              
              // Navigate về màn hình login
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserCubit>().deleteAccount();
              Navigator.pop(context);
              // Navigate to login screen
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
