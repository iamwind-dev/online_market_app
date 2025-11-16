/// Model chi tiết món ăn từ API
/// API: GET /api/buyer/mon-an/{ma_mon_an}
/// Response JSON: { "success": true, "detail": {...} }
class MonAnDetailModel {
  final String maMonAn;
  final String tenMonAn;
  final String hinhAnh; // URL ảnh món ăn
  final int? khoangThoiGian; // Thời gian nấu (phút)
  final String? doKho; // Độ khó: "Dễ", "Trung bình", "Khó"
  final int? khauPhanTieuChuan; // Số khẩu phần tiêu chuẩn
  final String? cachThucHien; // Cách thực hiện (hướng dẫn nấu)
  final String? soChe; // Số chế (cách chế biến)
  final String? cachDung; // Cách dùng
  final int? calories; // Calories
  final int? soDanhMuc; // Số lượng danh mục
  final int? soNguyenLieu; // Số lượng nguyên liệu
  final List<DanhMucDetail>? danhMuc; // Danh sách danh mục
  final List<NguyenLieuDetail>? nguyenLieu; // Danh sách nguyên liệu

  MonAnDetailModel({
    required this.maMonAn,
    required this.tenMonAn,
    required this.hinhAnh,
    this.khoangThoiGian,
    this.doKho,
    this.khauPhanTieuChuan,
    this.cachThucHien,
    this.soChe,
    this.cachDung,
    this.calories,
    this.soDanhMuc,
    this.soNguyenLieu,
    this.danhMuc,
    this.nguyenLieu,
  });

  /// Parse từ JSON response
  /// Cấu trúc: { "success": true, "detail": {...} }
  factory MonAnDetailModel.fromJson(Map<String, dynamic> json) {
    // Lấy object detail từ response
    final detail = json['detail'] as Map<String, dynamic>? ?? json;
    
    return MonAnDetailModel(
      maMonAn: detail['ma_mon_an'] as String? ?? '',
      tenMonAn: detail['ten_mon_an'] as String? ?? '',
      hinhAnh: detail['hinh_anh'] as String? ?? '',
      khoangThoiGian: detail['khoang_thoi_gian'] as int?,
      doKho: detail['do_kho'] as String?,
      khauPhanTieuChuan: detail['khau_phan_tieu_chuan'] as int?,
      cachThucHien: detail['cach_thuc_hien'] as String?,
      soChe: detail['so_che'] as String?,
      cachDung: detail['cach_dung'] as String?,
      calories: detail['calories'] as int?,
      soDanhMuc: detail['so_danh_muc'] as int?,
      soNguyenLieu: detail['so_nguyen_lieu'] as int?,
      danhMuc: (detail['danh_muc'] as List<dynamic>?)
          ?.map((item) => DanhMucDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
      nguyenLieu: (detail['nguyen_lieu'] as List<dynamic>?)
          ?.map((item) => NguyenLieuDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'ma_mon_an': maMonAn,
      'ten_mon_an': tenMonAn,
      'hinh_anh': hinhAnh,
      'khoang_thoi_gian': khoangThoiGian,
      'do_kho': doKho,
      'khau_phan_tieu_chuan': khauPhanTieuChuan,
      'cach_thuc_hien': cachThucHien,
      'so_che': soChe,
      'cach_dung': cachDung,
      'calories': calories,
      'so_danh_muc': soDanhMuc,
      'so_nguyen_lieu': soNguyenLieu,
      'danh_muc': danhMuc?.map((item) => item.toJson()).toList(),
      'nguyen_lieu': nguyenLieu?.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model danh mục trong chi tiết món ăn
class DanhMucDetail {
  final String? maDanhMuc;
  final String? tenDanhMuc;

  DanhMucDetail({
    this.maDanhMuc,
    this.tenDanhMuc,
  });

  factory DanhMucDetail.fromJson(Map<String, dynamic> json) {
    return DanhMucDetail(
      maDanhMuc: json['ma_danh_muc'] as String?,
      tenDanhMuc: json['ten_danh_muc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_danh_muc': maDanhMuc,
      'ten_danh_muc': tenDanhMuc,
    };
  }
}

/// Model nguyên liệu trong chi tiết món ăn
/// Bỏ qua ma_nguyen_lieu, sử dụng: ten_nguyen_lieu, don_vi_goc, dinh_luong
class NguyenLieuDetail {
  final String? tenNguyenLieu; // VD: "đỏ"
  final String? donViGoc; // VD: null hoặc "gram"
  final String? dinhLuong; // VD: "50\r"

  NguyenLieuDetail({
    this.tenNguyenLieu,
    this.donViGoc,
    this.dinhLuong,
  });

  factory NguyenLieuDetail.fromJson(Map<String, dynamic> json) {
    return NguyenLieuDetail(
      tenNguyenLieu: json['ten_nguyen_lieu'] as String?,
      donViGoc: json['don_vi_goc'] as String?,
      dinhLuong: json['dinh_luong'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ten_nguyen_lieu': tenNguyenLieu,
      'don_vi_goc': donViGoc,
      'dinh_luong': dinhLuong,
    };
  }
}
