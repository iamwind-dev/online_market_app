/// Model chi tiết nguyên liệu từ API
/// API: GET /api/buyer/nguyen-lieu/{ma_nguyen_lieu}
class NguyenLieuDetailModel {
  final String maNguyenLieu;
  final String tenNguyenLieu;
  final String? donVi;
  final String maNhomNguyenLieu;
  final String tenNhomNguyenLieu;
  final int soGianHang;
  final String? giaGoc;
  final String? giaCuoi;
  final String? ngayCapNhatMoiNhat;
  final String? hinhAnhMoiNhat;
  final List<SellerModel> sellers;

  NguyenLieuDetailModel({
    required this.maNguyenLieu,
    required this.tenNguyenLieu,
    this.donVi,
    required this.maNhomNguyenLieu,
    required this.tenNhomNguyenLieu,
    required this.soGianHang,
    this.giaGoc,
    this.giaCuoi,
    this.ngayCapNhatMoiNhat,
    this.hinhAnhMoiNhat,
    required this.sellers,
  });

  /// Parse từ JSON response
  /// Cấu trúc: { "success": true, "detail": {...}, "sellers": {"data": [...]} }
  factory NguyenLieuDetailModel.fromJson(Map<String, dynamic> json) {
    // Lấy object detail từ response
    final detail = json['detail'] as Map<String, dynamic>? ?? json;
    
    // Lấy danh sách sellers
    final sellersData = json['sellers'] as Map<String, dynamic>?;
    final sellersList = (sellersData?['data'] as List<dynamic>?)
        ?.map((item) => SellerModel.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return NguyenLieuDetailModel(
      maNguyenLieu: detail['ma_nguyen_lieu'] as String? ?? '',
      tenNguyenLieu: detail['ten_nguyen_lieu'] as String? ?? '',
      donVi: detail['don_vi'] as String?,
      maNhomNguyenLieu: detail['ma_nhom_nguyen_lieu'] as String? ?? '',
      tenNhomNguyenLieu: detail['ten_nhom_nguyen_lieu'] as String? ?? '',
      soGianHang: detail['so_gian_hang'] as int? ?? 0,
      giaGoc: detail['gia_goc'] as String?,
      giaCuoi: detail['gia_cuoi'] as String?,
      ngayCapNhatMoiNhat: detail['ngay_cap_nhat_moi_nhat'] as String?,
      hinhAnhMoiNhat: detail['hinh_anh_moi_nhat'] as String?,
      sellers: sellersList,
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'ma_nguyen_lieu': maNguyenLieu,
      'ten_nguyen_lieu': tenNguyenLieu,
      'don_vi': donVi,
      'ma_nhom_nguyen_lieu': maNhomNguyenLieu,
      'ten_nhom_nguyen_lieu': tenNhomNguyenLieu,
      'so_gian_hang': soGianHang,
      'gia_goc': giaGoc,
      'gia_cuoi': giaCuoi,
      'ngay_cap_nhat_moi_nhat': ngayCapNhatMoiNhat,
      'hinh_anh_moi_nhat': hinhAnhMoiNhat,
      'sellers': sellers.map((seller) => seller.toJson()).toList(),
    };
  }
}

/// Model người bán (seller)
class SellerModel {
  final String? maGianHang;
  final String? tenGianHang;
  final String? gia;
  final String? donVi;
  final String? hinhAnh;
  final String? ngayCapNhat;

  SellerModel({
    this.maGianHang,
    this.tenGianHang,
    this.gia,
    this.donVi,
    this.hinhAnh,
    this.ngayCapNhat,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      maGianHang: json['ma_gian_hang'] as String?,
      tenGianHang: json['ten_gian_hang'] as String?,
      gia: json['gia'] as String?,
      donVi: json['don_vi'] as String?,
      hinhAnh: json['hinh_anh'] as String?,
      ngayCapNhat: json['ngay_cap_nhat'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_gian_hang': maGianHang,
      'ten_gian_hang': tenGianHang,
      'gia': gia,
      'don_vi': donVi,
      'hinh_anh': hinhAnh,
      'ngay_cap_nhat': ngayCapNhat,
    };
  }
}
