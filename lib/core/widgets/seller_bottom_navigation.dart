import 'package:flutter/material.dart';

/// Seller Bottom Navigation Widget
/// Dùng cho các màn hình của người bán
class SellerBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const SellerBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
            icon: Icons.receipt_long,
            label: 'Đơn hàng',
            index: 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.shopping_bag,
            label: 'Sản phẩm',
            index: 1,
          ),
          // Avatar/Home ở giữa
          _buildCenterItem(context),
          _buildNavItem(
            context,
            icon: Icons.bar_chart,
            label: 'Doanh số',
            index: 3,
          ),
          _buildNavItem(
            context,
            icon: Icons.account_circle,
            label: 'Tài khoản',
            index: 4,
          ),
        ],
      ),
    );
  }

  /// Center item (Avatar/Home)
  Widget _buildCenterItem(BuildContext context) {
    final isSelected = currentIndex == 2;
    
    return InkWell(
      onTap: () => onTap?.call(2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? const Color(0xFF00B40F) : Colors.transparent,
              width: 2,
            ),
          ),
          
            child: Image.asset(
              'assets/img/user_personas_presentation-26cd3a.png',
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF00B40F).withValues(alpha: 0.2)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store,
                    size: 30,
                    color: isSelected ? const Color(0xFF00B40F) : Colors.grey[600],
                  ),
                );
              },
            ),
          
        ),
      ),
    );
  }

  /// Bottom Navigation Item
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = index == currentIndex;
    
    return InkWell(
      onTap: () {
        if (isSelected) return;
        onTap?.call(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12,
                height: 1.33,
                color: isSelected ? const Color(0xFF00B40F) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
