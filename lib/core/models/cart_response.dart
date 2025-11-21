/// Model cho response của API giỏ hàng
class CartResponse {
  final bool success;
  final CartSummary cart;
  final List<CartItem> items;

  CartResponse({
    required this.success,
    required this.cart,
    required this.items,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    // API trả về flat structure, không có nested cart object
    return CartResponse(
      success: json['success'] ?? false,
      cart: CartSummary(
        maDonHang: json['ma_don_hang'] ?? '',
        tongTien: (json['tong_tien'] as num?)?.toDouble() ?? 0.0,
        soMatHang: (json['so_mat_hang'] as num?)?.toInt() ?? 0,
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

/// Model cho thông tin tóm tắt giỏ hàng
class CartSummary {
  final String maDonHang;
  final double tongTien;
  final int soMatHang;

  CartSummary({
    required this.maDonHang,
    required this.tongTien,
    required this.soMatHang,
  });
}

/// Model cho item trong giỏ hàng
class CartItem {
  final String maNguyenLieu;
  final String tenNguyenLieu;
  final String maGianHang;
  final String tenGianHang;
  final String maCho;
  final int soLuong;
  final double giaCuoi;
  final double thanhTien;
  final String? hinhAnh;

  CartItem({
    required this.maNguyenLieu,
    required this.tenNguyenLieu,
    required this.maGianHang,
    required this.tenGianHang,
    required this.maCho,
    required this.soLuong,
    required this.giaCuoi,
    required this.thanhTien,
    this.hinhAnh,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      maNguyenLieu: json['ma_nguyen_lieu'] ?? '',
      tenNguyenLieu: json['ten_nguyen_lieu'] ?? '',
      maGianHang: json['ma_gian_hang'] ?? '',
      tenGianHang: json['ten_gian_hang'] ?? '',
      maCho: json['ma_cho'] ?? '',
      soLuong: (json['so_luong'] as num?)?.toInt() ?? 0,
      giaCuoi: (json['gia_cuoi'] as num?)?.toDouble() ?? 0.0,
      thanhTien: (json['thanh_tien'] as num?)?.toDouble() ?? 0.0,
      hinhAnh: json['hinh_anh'],
    );
  }
}

/// Model cho response khi thêm vào giỏ hàng
class AddToCartResponse {
  final bool success;
  final String? maDonHang;
  final double? tongTien;
  final double? tongTienGoc;
  final double? tietKiem;
  final String? message;

  AddToCartResponse({
    required this.success,
    this.maDonHang,
    this.tongTien,
    this.tongTienGoc,
    this.tietKiem,
    this.message,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      success: json['success'] ?? false,
      maDonHang: json['ma_don_hang'],
      tongTien: (json['tong_tien'] as num?)?.toDouble(),
      tongTienGoc: (json['tong_tien_goc'] as num?)?.toDouble(),
      tietKiem: (json['tiet_kiem'] as num?)?.toDouble(),
      message: json['message'],
    );
  }
}
