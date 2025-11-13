/// Response model cho API login
class AuthResponse {
  final UserData data;
  final String token;

  AuthResponse({
    required this.data,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: UserData.fromJson(json['data']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'token': token,
    };
  }
}

/// User data model
class UserData {
  final String sub;
  final String maNguoiDung;
  final String vaiTro;
  final String tenDangNhap;

  UserData({
    required this.sub,
    required this.maNguoiDung,
    required this.vaiTro,
    required this.tenDangNhap,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      sub: json['sub'],
      maNguoiDung: json['ma_nguoi_dung'],
      vaiTro: json['vai_tro'],
      tenDangNhap: json['ten_dang_nhap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'ma_nguoi_dung': maNguoiDung,
      'vai_tro': vaiTro,
      'ten_dang_nhap': tenDangNhap,
    };
  }

  /// Getters for convenience
  bool get isNguoiMua => vaiTro == 'nguoi_mua';
  bool get isNguoiBan => vaiTro == 'nguoi_ban';
  bool get isAdmin => vaiTro == 'admin';
}
