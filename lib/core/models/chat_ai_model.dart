class ChatAIResponse {
  final bool success;
  final String message;
  final ChatSuggestions? suggestions;
  final String conversationId;

  ChatAIResponse({
    required this.success,
    required this.message,
    this.suggestions,
    required this.conversationId,
  });

  factory ChatAIResponse.fromJson(Map<String, dynamic> json) {
    return ChatAIResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      suggestions: json['suggestions'] != null
          ? ChatSuggestions.fromJson(json['suggestions'] as Map<String, dynamic>)
          : null,
      conversationId: json['conversation_id'] as String,
    );
  }
}

class ChatSuggestions {
  final List<MonAnSuggestion> monAn;
  final List<NguyenLieuSuggestion> nguyenLieu;

  ChatSuggestions({
    required this.monAn,
    required this.nguyenLieu,
  });

  factory ChatSuggestions.fromJson(Map<String, dynamic> json) {
    return ChatSuggestions(
      monAn: (json['mon_an'] as List?)
              ?.map((item) => MonAnSuggestion.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      nguyenLieu: (json['nguyen_lieu'] as List?)
              ?.map((item) => NguyenLieuSuggestion.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MonAnSuggestion {
  final String maMonAn;
  final String tenMonAn;
  final String hinhAnh;

  MonAnSuggestion({
    required this.maMonAn,
    required this.tenMonAn,
    required this.hinhAnh,
  });

  factory MonAnSuggestion.fromJson(Map<String, dynamic> json) {
    return MonAnSuggestion(
      maMonAn: json['ma_mon_an'] as String,
      tenMonAn: json['ten_mon_an'] as String,
      hinhAnh: json['hinh_anh'] as String,
    );
  }
}

class NguyenLieuSuggestion {
  final String maNguyenLieu;
  final String tenNguyenLieu;
  final String? donVi;
  final String? dinhLuong;
  final String? hinhAnh;
  final GianHangSuggest? gianHangSuggest;
  final NguyenLieuActions actions;

  NguyenLieuSuggestion({
    required this.maNguyenLieu,
    required this.tenNguyenLieu,
    this.donVi,
    this.dinhLuong,
    this.hinhAnh,
    this.gianHangSuggest,
    required this.actions,
  });

  factory NguyenLieuSuggestion.fromJson(Map<String, dynamic> json) {
    return NguyenLieuSuggestion(
      maNguyenLieu: json['ma_nguyen_lieu'] as String,
      tenNguyenLieu: json['ten_nguyen_lieu'] as String,
      donVi: json['don_vi'] as String?,
      dinhLuong: json['dinh_luong'] as String?,
      hinhAnh: json['hinh_anh'] as String?,
      gianHangSuggest: json['gian_hang_suggest'] != null
          ? GianHangSuggest.fromJson(json['gian_hang_suggest'] as Map<String, dynamic>)
          : null,
      actions: NguyenLieuActions.fromJson(json['actions'] as Map<String, dynamic>),
    );
  }
}

class GianHangSuggest {
  final String maGianHang;
  final String tenGianHang;
  final String viTri;
  final String gia;
  final String donViBan;
  final double soLuong;

  GianHangSuggest({
    required this.maGianHang,
    required this.tenGianHang,
    required this.viTri,
    required this.gia,
    required this.donViBan,
    required this.soLuong,
  });

  factory GianHangSuggest.fromJson(Map<String, dynamic> json) {
    return GianHangSuggest(
      maGianHang: json['ma_gian_hang'] as String,
      tenGianHang: json['ten_gian_hang'] as String,
      viTri: json['vi_tri'] as String,
      gia: json['gia'] as String,
      donViBan: json['don_vi_ban'] as String,
      soLuong: (json['so_luong'] as num).toDouble(),
    );
  }
}

class NguyenLieuActions {
  final bool canViewDetail;
  final bool canAddToCart;
  final String detailEndpoint;
  final String? addToCartEndpoint;

  NguyenLieuActions({
    required this.canViewDetail,
    required this.canAddToCart,
    required this.detailEndpoint,
    this.addToCartEndpoint,
  });

  factory NguyenLieuActions.fromJson(Map<String, dynamic> json) {
    return NguyenLieuActions(
      canViewDetail: json['can_view_detail'] as bool,
      canAddToCart: json['can_add_to_cart'] as bool,
      detailEndpoint: json['detail_endpoint'] as String,
      addToCartEndpoint: json['add_to_cart_endpoint'] as String?,
    );
  }
}
