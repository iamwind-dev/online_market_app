import 'package:flutter/material.dart';

/// Category Card Widget
/// Hiển thị danh mục với icon/ảnh và tên
class CategoryCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.imagePath,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00B40F)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B40F)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : const Color(0xFF1C1C1E),
          ),
        ),
      ),
    );
  }
}
