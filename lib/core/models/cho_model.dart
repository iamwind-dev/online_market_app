class ChoModel {
  final String maCho;
  final String tenCho;
  final String maKhuVuc;
  final String tenKhuVuc;
  final String diaChi;
  final String hinhAnh;
  final int soGianHang;

  ChoModel({
    required this.maCho,
    required this.tenCho,
    required this.maKhuVuc,
    required this.tenKhuVuc,
    required this.diaChi,
    required this.hinhAnh,
    required this.soGianHang,
  });

  factory ChoModel.fromJson(Map<String, dynamic> json) {
    return ChoModel(
      maCho: json['ma_cho'] as String,
      tenCho: json['ten_cho'] as String,
      maKhuVuc: json['ma_khu_vuc'] as String,
      tenKhuVuc: json['ten_khu_vuc'] as String,
      diaChi: json['dia_chi'] as String,
      hinhAnh: json['hinh_anh'] as String,
      soGianHang: json['so_gian_hang'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_cho': maCho,
      'ten_cho': tenCho,
      'ma_khu_vuc': maKhuVuc,
      'ten_khu_vuc': tenKhuVuc,
      'dia_chi': diaChi,
      'hinh_anh': hinhAnh,
      'so_gian_hang': soGianHang,
    };
  }
}

class ChoResponse {
  final List<ChoModel> data;
  final ChoMetaData meta;

  ChoResponse({
    required this.data,
    required this.meta,
  });

  factory ChoResponse.fromJson(Map<String, dynamic> json) {
    return ChoResponse(
      data: (json['data'] as List)
          .map((item) => ChoModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: ChoMetaData.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class ChoMetaData {
  final int page;
  final int limit;
  final int total;
  final bool hasNext;

  ChoMetaData({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
  });

  factory ChoMetaData.fromJson(Map<String, dynamic> json) {
    return ChoMetaData(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }
}
