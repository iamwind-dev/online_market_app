import 'package:flutter/material.dart';

/// Widget hiển thị nguyên liệu
/// Hiển thị tên nguyên liệu, định lượng và đơn vị gốc
class IngredientCard extends StatelessWidget {
  final String tenNguyenLieu; // VD: "đỏ"
  final String dinhLuong; // VD: "50"
  final String? donViGoc; // VD: null hoặc "gram"

  const IngredientCard({
    super.key,
    required this.tenNguyenLieu,
    required this.dinhLuong,
    this.donViGoc,
  });

  @override
  Widget build(BuildContext context) {
    // Format thông tin hiển thị
    String displayInfo = tenNguyenLieu;
    
    if (dinhLuong.isNotEmpty) {
      displayInfo += ': ${dinhLuong.trim()}';
      if (donViGoc != null && donViGoc!.isNotEmpty) {
        displayInfo += ' ${donViGoc}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2F8000),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '•',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayInfo,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.38,
                color: Color(0xFF0C0D0D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
