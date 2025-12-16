import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/buyer_loading.dart';
import '../../../../../core/dependency/injection.dart';
import '../../../../../core/services/auth/auth_service.dart';
import '../../../../user/presentation/cubit/user_cubit.dart';
import '../../../../user/presentation/cubit/user_state.dart';

class SellerUserScreen extends StatelessWidget {
  const SellerUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(authService: getIt<AuthService>())..loadUserData(),
      child: const _SellerUserView(),
    );
  }
}

class _SellerUserView extends StatelessWidget {
  const _SellerUserView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state.requiresLogin) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
            return;
          }
          
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const BuyerLoading(
              message: 'Đang tải thông tin...',
            );
          }

          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileSection(context, state),
                      const SizedBox(height: 16),
                      _buildInformationSection(context, state),
                      const SizedBox(height: 24),
                      _buildLogoutButton(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Header với back button và title
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 16, color: Colors.black),
                  padding: const EdgeInsets.only(left: 16, right: 8),
                ),
                const Expanded(
                  child: Text(
                    'GIAN HÀNG CỦA TÔI',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      height: 1.0,
                      letterSpacing: 0.51,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40), // Spacer để căn giữa
              ],
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: Color(0xFFD9D9D9),
            ),
          ],
        ),
      ),
    );
  }

  /// Profile Section với avatar, tên, rating, stats
  Widget _buildProfileSection(BuildContext context, UserState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        children: [
          // Main profile card với image và info
          Container(
            height: 179,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[300], // Fallback color
            ),
            child: Stack(
              children: [
                // Background image placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    'assets/img/seller_shop_bg.png',
                    width: double.infinity,
                    height: 179,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 179,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green[300]!,
                              Colors.green[500]!,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Category badges
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black, width: 0.3),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gia vị',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.83,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Thịt heo',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.83,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar circle
                Positioned(
                  bottom: 8,
                  left: 7,
                  child: Container(
                    width: 48,
                    height: 49,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8F959E),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'N',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          height: 0.73,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Name and rating
                Positioned(
                  bottom: 8,
                  left: 69,
                  child: Row(
                    children: [
                      const Text(
                        'Cô Nhi',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          height: 1.1,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '5',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 0.89,
                          color: Color(0xFF0C0D0D),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Image.asset(
                        'assets/img/star.png',
                        width: 21,
                        height: 19,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.star,
                            size: 19,
                            color: Colors.amber,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '30 sản phẩm',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.375,
                    color: Color(0xFF202020),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Danh mục',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.375,
                        color: Color(0xFF202020),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Orders stat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Row(
              children: [
                Text(
                  'Đã bán hơn 120 đơn hàng',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.375,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Information Section với các thông tin và edit icons
  Widget _buildInformationSection(BuildContext context, UserState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên người dùng
          _buildInfoRow(
            context,
            label: state.userName,
            showEdit: false,
            showArrow: false,
          ),
          const Divider(height: 32),
          // Chợ
          _buildInfoRow(
            context,
            label: 'Chợ: Bắc Mỹ An',
            showEdit: true,
            showArrow: false,
            onEdit: () {
              // TODO: Edit market
            },
          ),
          const Divider(height: 32),
          // Số lô
          _buildInfoRow(
            context,
            label: 'Số lô: STK12',
            showEdit: false,
            showArrow: true,
            onTap: () {
              // TODO: Navigate to lot details
            },
          ),
          const Divider(height: 32),
          // Số tài khoản
          _buildInfoRow(
            context,
            label: 'Số tài khoản: 0397521031',
            showEdit: true,
            showArrow: false,
            onEdit: () {
              // TODO: Edit account number
            },
          ),
          const Divider(height: 32),
          // Ngân hàng
          _buildInfoRow(
            context,
            label: 'Ngân hàng: AB BANK',
            showEdit: true,
            showArrow: false,
            onEdit: () {
              // TODO: Edit bank
            },
          ),
          const Divider(height: 32),
          // Số điện thoại
          _buildInfoRow(
            context,
            label: 'Số điện thoại: 039821031',
            showEdit: true,
            showArrow: false,
            onEdit: () {
              // TODO: Edit phone
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required bool showEdit,
    required bool showArrow,
    VoidCallback? onEdit,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.76,
                letterSpacing: -0.21,
                color: Color(0xFF202020),
              ),
            ),
          ),
          if (showEdit)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF1C1B1F),
                ),
              ),
            ),
          if (showArrow)
            const Icon(
              Icons.arrow_forward_ios,
              size: 9,
              color: Color(0xFF1C1B1F),
            ),
        ],
      ),
    );
  }

  /// Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          child: const Text(
            'Đăng Xuất',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              height: 1.29,
              letterSpacing: -0.18,
              color: Color(0xFF0F2F63),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<UserCubit>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
