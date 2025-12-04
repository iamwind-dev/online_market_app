import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth/simple_auth_helper.dart';

/// Service để fetch danh sách đơn hàng từ API
class OrderService {
  static const String _baseUrl =
      'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer';

  /// Fetch chi tiết đơn hàng
  Future<OrderDetailResponse> getOrderDetail(String maDonHang) async {
    print('📦 [ORDER SERVICE] Fetching order detail: $maDonHang');

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/orders/$maDonHang');

      print('📦 [ORDER SERVICE] Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📦 [ORDER SERVICE] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return OrderDetailResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to fetch order detail: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [ORDER SERVICE] Error: $e');
      rethrow;
    }
  }

  /// Fetch danh sách đơn hàng
  Future<OrderListResponse> getOrders({
    int page = 1,
    int limit = 12,
  }) async {
    print('📦 [ORDER SERVICE] Fetching orders...');

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/orders').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('📦 [ORDER SERVICE] Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📦 [ORDER SERVICE] Response status: ${response.statusCode}');
      print('📦 [ORDER SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return OrderListResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to fetch orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [ORDER SERVICE] Error: $e');
      rethrow;
    }
  }
}

/// Model cho response danh sách đơn hàng
class OrderListResponse {
  final bool success;
  final List<OrderModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  OrderListResponse({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      success: json['success'] ?? true,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderModel.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 12,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

/// Model cho đơn hàng
class OrderModel {
  final String maDonHang;
  final double tongTien;
  final DeliveryAddress? diaChiGiaoHang;
  final String tinhTrangDonHang;
  final DateTime? thoiGianGiaoHang;
  final String? maThanhToan;
  final PaymentInfo? thanhToan;

  OrderModel({
    required this.maDonHang,
    required this.tongTien,
    this.diaChiGiaoHang,
    required this.tinhTrangDonHang,
    this.thoiGianGiaoHang,
    this.maThanhToan,
    this.thanhToan,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse địa chỉ giao hàng từ JSON string
    DeliveryAddress? address;
    if (json['dia_chi_giao_hang'] != null) {
      try {
        final addressJson = jsonDecode(json['dia_chi_giao_hang']);
        address = DeliveryAddress.fromJson(addressJson);
      } catch (e) {
        print('Error parsing address: $e');
      }
    }

    return OrderModel(
      maDonHang: json['ma_don_hang'] ?? '',
      tongTien: _parseToDouble(json['tong_tien']),
      diaChiGiaoHang: address,
      tinhTrangDonHang: json['tinh_trang_don_hang'] ?? '',
      thoiGianGiaoHang: json['thoi_gian_giao_hang'] != null
          ? DateTime.tryParse(json['thoi_gian_giao_hang'])
          : null,
      maThanhToan: json['ma_thanh_toan'],
      thanhToan: json['thanh_toan'] != null
          ? PaymentInfo.fromJson(json['thanh_toan'])
          : null,
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Check trạng thái đơn hàng
  bool get isPending => tinhTrangDonHang == 'cho_xac_nhan';
  bool get isConfirmed => tinhTrangDonHang == 'da_xac_nhan';
  bool get isShipping => tinhTrangDonHang == 'dang_giao';
  bool get isDelivered => tinhTrangDonHang == 'da_giao';
  bool get isCancelled => tinhTrangDonHang == 'da_huy';

  /// Check trạng thái thanh toán
  bool get isPaid => thanhToan?.tinhTrangThanhToan == 'da_thanh_toan';
}

/// Model cho địa chỉ giao hàng
class DeliveryAddress {
  final String name;
  final String phone;
  final String address;

  DeliveryAddress({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

/// Model cho thông tin thanh toán
class PaymentInfo {
  final String maThanhToan;
  final String hinhThucThanhToan;
  final String tinhTrangThanhToan;
  final DateTime? thoiGianThanhToan;

  PaymentInfo({
    required this.maThanhToan,
    required this.hinhThucThanhToan,
    required this.tinhTrangThanhToan,
    this.thoiGianThanhToan,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      maThanhToan: json['ma_thanh_toan'] ?? '',
      hinhThucThanhToan: json['hinh_thuc_thanh_toan'] ?? '',
      tinhTrangThanhToan: json['tinh_trang_thanh_toan'] ?? '',
      thoiGianThanhToan: json['thoi_gian_thanh_toan'] != null
          ? DateTime.tryParse(json['thoi_gian_thanh_toan'])
          : null,
    );
  }

  String get paymentMethodDisplay {
    switch (hinhThucThanhToan) {
      case 'chuyen_khoan':
        return 'Chuyển khoản';
      case 'tien_mat':
        return 'Tiền mặt';
      default:
        return hinhThucThanhToan;
    }
  }

  String get paymentStatusDisplay {
    switch (tinhTrangThanhToan) {
      case 'da_thanh_toan':
        return 'Đã thanh toán';
      case 'cho_thanh_toan':
        return 'Chờ thanh toán';
      default:
        return tinhTrangThanhToan;
    }
  }
}


/// Model cho response chi tiết đơn hàng
class OrderDetailResponse {
  final bool success;
  final OrderDetailData data;

  OrderDetailResponse({
    required this.success,
    required this.data,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      success: json['success'] ?? true,
      data: OrderDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

/// Model cho data chi tiết đơn hàng
class OrderDetailData {
  final String maDonHang;
  final String? maThanhToan;
  final String? maNguoiMua;
  final double tongTien;
  final DeliveryAddress? diaChiGiaoHang;
  final String tinhTrangDonHang;
  final DateTime? thoiGianGiaoHang;
  final PaymentInfo? thanhToan;
  final List<OrderItemDetail> items;

  OrderDetailData({
    required this.maDonHang,
    this.maThanhToan,
    this.maNguoiMua,
    required this.tongTien,
    this.diaChiGiaoHang,
    required this.tinhTrangDonHang,
    this.thoiGianGiaoHang,
    this.thanhToan,
    required this.items,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    // Parse địa chỉ giao hàng từ JSON string
    DeliveryAddress? address;
    if (json['dia_chi_giao_hang'] != null) {
      try {
        final addressJson = jsonDecode(json['dia_chi_giao_hang']);
        address = DeliveryAddress.fromJson(addressJson);
      } catch (e) {
        print('Error parsing address: $e');
      }
    }

    return OrderDetailData(
      maDonHang: json['ma_don_hang'] ?? '',
      maThanhToan: json['ma_thanh_toan'],
      maNguoiMua: json['ma_nguoi_mua'],
      tongTien: _parseToDouble(json['tong_tien']),
      diaChiGiaoHang: address,
      tinhTrangDonHang: json['tinh_trang_don_hang'] ?? '',
      thoiGianGiaoHang: json['thoi_gian_giao_hang'] != null
          ? DateTime.tryParse(json['thoi_gian_giao_hang'])
          : null,
      thanhToan: json['thanh_toan'] != null
          ? PaymentInfo.fromJson(json['thanh_toan'])
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemDetail.fromJson(item))
              .toList() ??
          [],
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get orderStatusDisplay {
    switch (tinhTrangDonHang) {
      case 'cho_xac_nhan':
        return 'Chờ xác nhận';
      case 'da_xac_nhan':
        return 'Đã xác nhận';
      case 'dang_giao':
        return 'Đang giao';
      case 'da_giao':
        return 'Đã giao';
      case 'da_huy':
        return 'Đã hủy';
      default:
        return tinhTrangDonHang;
    }
  }
}

/// Model cho item trong chi tiết đơn hàng
class OrderItemDetail {
  final String maNguyenLieu;
  final String maGianHang;
  final int soLuong;
  final double giaCuoi;
  final double thanhTien;
  final String? maMonAn;
  final IngredientInfo? nguyenLieu;
  final ShopInfo? gianHang;
  final String? donViBan;

  OrderItemDetail({
    required this.maNguyenLieu,
    required this.maGianHang,
    required this.soLuong,
    required this.giaCuoi,
    required this.thanhTien,
    this.maMonAn,
    this.nguyenLieu,
    this.gianHang,
    this.donViBan,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      maNguyenLieu: json['ma_nguyen_lieu'] ?? '',
      maGianHang: json['ma_gian_hang'] ?? '',
      soLuong: (json['so_luong'] as num?)?.toInt() ?? 0,
      giaCuoi: _parseToDouble(json['gia_cuoi']),
      thanhTien: _parseToDouble(json['thanh_tien']),
      maMonAn: json['ma_mon_an'],
      nguyenLieu: json['nguyen_lieu'] != null
          ? IngredientInfo.fromJson(json['nguyen_lieu'])
          : null,
      gianHang: json['gian_hang'] != null
          ? ShopInfo.fromJson(json['gian_hang'])
          : null,
      donViBan: json['don_vi_ban'],
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model cho thông tin nguyên liệu
class IngredientInfo {
  final String maNguyenLieu;
  final String tenNguyenLieu;
  final String? donVi;

  IngredientInfo({
    required this.maNguyenLieu,
    required this.tenNguyenLieu,
    this.donVi,
  });

  factory IngredientInfo.fromJson(Map<String, dynamic> json) {
    return IngredientInfo(
      maNguyenLieu: json['ma_nguyen_lieu'] ?? '',
      tenNguyenLieu: json['ten_nguyen_lieu'] ?? '',
      donVi: json['don_vi'],
    );
  }
}

/// Model cho thông tin gian hàng
class ShopInfo {
  final String maGianHang;
  final String tenGianHang;
  final String? viTri;
  final String? hinhAnh;

  ShopInfo({
    required this.maGianHang,
    required this.tenGianHang,
    this.viTri,
    this.hinhAnh,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      maGianHang: json['ma_gian_hang'] ?? '',
      tenGianHang: json['ten_gian_hang'] ?? '',
      viTri: json['vi_tri'],
      hinhAnh: json['hinh_anh'],
    );
  }
}
