import 'package:flutter/material.dart';

/// Ingredient List Item Widget
/// Hiển thị từng nguyên liệu trong danh sách (tên, định lượng, đơn vị)
class IngredientListItem extends StatelessWidget {
  final String tenNguyenLieu;
  final String? dinhLuong;
  final String? donViGoc;

  const IngredientListItem({
    super.key,
    required this.tenNguyenLieu,
    this.dinhLuong,
    this.donViGoc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tenNguyenLieu,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
          ),
          if (dinhLuong != null)
            Text(
              dinhLuong!,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
          if (dinhLuong != null) const SizedBox(width: 8),
          if (donViGoc != null)
            Text(
              donViGoc!,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF757575),
              ),
            ),
        ],
      ),
    );
  }
}
