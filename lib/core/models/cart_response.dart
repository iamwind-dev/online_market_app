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
    // API trả về nested cart object
    final cartData = json['cart'] as Map<String, dynamic>?;
    
    return CartResponse(
      success: json['success'] ?? false,
      cart: CartSummary(
        maDonHang: cartData?['ma_don_hang'] ?? cartData?['ma_gio_hang'] ?? '',
        tongTien: _parseToDouble(cartData?['tong_tien']),
        tongTienGoc: _parseToDouble(cartData?['tong_tien_goc']),
        tietKiem: _parseToDouble(cartData?['tiet_kiem']),
        soMatHang: _parseToInt(cartData?['so_mat_hang']),
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  /// Parse value to int, handle both String and num
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse value to double, handle both String and num
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model cho thông tin tóm tắt giỏ hàng
class CartSummary {
  final String maDonHang;
  final double tongTien;
  final double tongTienGoc;
  final double tietKiem;
  final int soMatHang;

  CartSummary({
    required this.maDonHang,
    required this.tongTien,
    this.tongTienGoc = 0,
    this.tietKiem = 0,
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
      soLuong: _parseToInt(json['so_luong']),
      giaCuoi: _parseToDouble(json['don_gia'] ?? json['gia_cuoi']),
      thanhTien: _parseToDouble(json['thanh_tien']),
      hinhAnh: json['hinh_anh'],
    );
  }

  /// Parse value to int, handle both String and num
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse value to double, handle both String and num
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      tongTien: json['tong_tien'] != null ? _parseToDouble(json['tong_tien']) : null,
      tongTienGoc: json['tong_tien_goc'] != null ? _parseToDouble(json['tong_tien_goc']) : null,
      tietKiem: json['tiet_kiem'] != null ? _parseToDouble(json['tiet_kiem']) : null,
      message: json['message'],
    );
  }

  /// Parse value to double, handle both String and num
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model cho response khi checkout
class CheckoutResponse {
  final bool success;
  final String maDonHang;
  final double tongTien;
  final double tongTienGoc;
  final double tietKiem;
  final String trangThai;
  final String paymentMethod;
  final int soMatHang;
  final int itemsCheckout;
  final int itemsRemaining;

  CheckoutResponse({
    required this.success,
    required this.maDonHang,
    required this.tongTien,
    required this.tongTienGoc,
    required this.tietKiem,
    required this.trangThai,
    required this.paymentMethod,
    required this.soMatHang,
    required this.itemsCheckout,
    required this.itemsRemaining,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    // Lấy order object từ response
    final order = json['order'] as Map<String, dynamic>? ?? {};
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    
    return CheckoutResponse(
      success: json['success'] ?? false,
      maDonHang: order['ma_don_hang'] ?? totals['ma_don_hang'] ?? '',
      tongTien: _parseToDouble(totals['tong_tien'] ?? order['tong_tien']),
      tongTienGoc: _parseToDouble(totals['tong_tien_goc'] ?? order['tong_tien_goc']),
      tietKiem: _parseToDouble(totals['tiet_kiem']),
      trangThai: order['trang_thai'] ?? '',
      paymentMethod: order['payment_method'] ?? '',
      soMatHang: _parseToInt(json['so_mat_hang']),
      itemsCheckout: _parseToInt(json['items_checkout']),
      itemsRemaining: _parseToInt(json['items_remaining']),
    );
  }

  /// Parse value to int, handle both String and num
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse value to double, handle both String and num
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model cho response khi xóa item khỏi giỏ hàng
class DeleteCartItemResponse {
  final bool success;
  final String? maDonHang;
  final double? tongTien;
  final double? tongTienGoc;
  final double? tietKiem;
  final String? message;

  DeleteCartItemResponse({
    required this.success,
    this.maDonHang,
    this.tongTien,
    this.tongTienGoc,
    this.tietKiem,
    this.message,
  });

  factory DeleteCartItemResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCartItemResponse(
      success: json['success'] ?? false,
      maDonHang: json['ma_don_hang'],
      tongTien: json['tong_tien'] != null ? _parseToDouble(json['tong_tien']) : null,
      tongTienGoc: json['tong_tien_goc'] != null ? _parseToDouble(json['tong_tien_goc']) : null,
      tietKiem: json['tiet_kiem'] != null ? _parseToDouble(json['tiet_kiem']) : null,
      message: json['message'],
    );
  }

  /// Parse value to double, handle both String and num
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
