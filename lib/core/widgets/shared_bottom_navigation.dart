import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/route_name.dart';

/// Shared Bottom Navigation Widget
/// Dùng chung cho tất cả các màn hình trong app
class SharedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const SharedBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: 'assets/img/add_home.svg',
            label: 'Trang chủ',
            index: 0,
            currentIndex: currentIndex,
            route: RouteName.home,
          ),
          _buildNavItem(
            context,
            iconData: Icons.card_giftcard,
            label: 'Sản phẩm',
            index: 1,
            currentIndex: currentIndex,
            route: RouteName.productList,
          ),
          // Logo App ở giữa (không điều hướng)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/logo.png',
                  width: 75,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B40F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 28,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildNavItem(
            context,
            icon: 'assets/img/wifi_notification.svg',
            label: 'Thông báo',
            index: 3,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            context,
            icon: 'assets/img/account_circle.svg',
            label: 'Tài khoản',
            index: 4,
            currentIndex: currentIndex,
            route: RouteName.user,
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Item
  Widget _buildNavItem(
    BuildContext context, {
    String? icon,
    IconData? iconData,
    required String label,
    required int index,
    required int currentIndex,
    String? route,
    bool showBadge = false,
  }) {
    final isSelected = index == currentIndex;
    return InkWell(
      onTap: () {
        // Nếu đã được chọn, không làm gì
        if (isSelected) return;
        
        // Navigate đến route tương ứng nếu có
        if (route != null) {
          // Xóa tất cả routes và push route mới để tránh stack sâu
          Navigator.of(context).pushNamedAndRemoveUntil(
            route,
            (route) => false,
          );
        } else {
          // Chỉ gọi onTap khi không có route (tức là không navigate)
          onTap?.call(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (icon != null)
                  SvgPicture.asset(
                    icon,
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      isSelected ? const Color(0xFF00B40F) : Colors.black,
                      BlendMode.srcIn,
                    ),
                  )
                else if (iconData != null)
                  Icon(
                    iconData,
                    size: 28,
                    color: isSelected ? const Color(0xFF00B40F) : Colors.black,
                  ),
                if (showBadge && index == 2)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF00B40F) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
