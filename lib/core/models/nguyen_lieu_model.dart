/// Model nguyên liệu từ API danh sách
/// API: GET /api/buyer/nguyen-lieu?page=1&limit=12
class NguyenLieuModel {
  final String maNguyenLieu;
  final String tenNguyenLieu;
  final String? donVi;
  final String maNhomNguyenLieu;
  final String tenNhomNguyenLieu;
  final int soGianHang;
  final String? giaGoc;
  final String? giaCuoi;
  final String? ngayCapNhat;
  final String? hinhAnh;

  NguyenLieuModel({
    required this.maNguyenLieu,
    required this.tenNguyenLieu,
    this.donVi,
    required this.maNhomNguyenLieu,
    required this.tenNhomNguyenLieu,
    required this.soGianHang,
    this.giaGoc,
    this.giaCuoi,
    this.ngayCapNhat,
    this.hinhAnh,
  });

  /// Parse từ JSON response
  factory NguyenLieuModel.fromJson(Map<String, dynamic> json) {
    return NguyenLieuModel(
      maNguyenLieu: json['ma_nguyen_lieu'] as String? ?? '',
      tenNguyenLieu: json['ten_nguyen_lieu'] as String? ?? '',
      donVi: json['don_vi'] as String?,
      maNhomNguyenLieu: json['ma_nhom_nguyen_lieu'] as String? ?? '',
      tenNhomNguyenLieu: json['ten_nhom_nguyen_lieu'] as String? ?? '',
      soGianHang: json['so_gian_hang'] as int? ?? 0,
      giaGoc: json['gia_goc'] as String?,
      giaCuoi: json['gia_cuoi'] as String?,
      ngayCapNhat: json['ngay_cap_nhat'] as String?,
      hinhAnh: json['hinh_anh'] as String?,
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
      'ngay_cap_nhat': ngayCapNhat,
      'hinh_anh': hinhAnh,
    };
  }
}

/// Model cho metadata phân trang
class NguyenLieuMeta {
  final int page;
  final int limit;
  final int total;
  final bool hasNext;

  NguyenLieuMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
  });

  factory NguyenLieuMeta.fromJson(Map<String, dynamic> json) {
    return NguyenLieuMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 12,
      total: json['total'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'hasNext': hasNext,
    };
  }
}
