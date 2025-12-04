import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

/// Service để gọi API đánh giá
class ReviewApiService {
  String get _baseUrl => '${AppConfig.baseUrl}/api/review';

  /// Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Lấy danh sách đánh giá theo gian hàng
  Future<StoreReviewsResponse> getStoreReviews(String maGianHang) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('⭐ [REVIEW API] Getting reviews for store: $maGianHang');
    }

    try {
      final url = Uri.parse('$_baseUrl/stores/$maGianHang/reviews');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('⭐ [REVIEW API] Response status: ${response.statusCode}');
        AppLogger.info('⭐ [REVIEW API] Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return StoreReviewsResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to get store reviews: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [REVIEW API] Get store reviews error: $e');
      }
      rethrow;
    }
  }

  /// Gửi đánh giá cho sản phẩm
  Future<ReviewResponse> submitReview({
    required String maDonHang,
    required String maNguyenLieu,
    required String maGianHang,
    required int rating,
    required String binhLuan,
  }) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('⭐ [REVIEW API] Submitting review for order: $maDonHang');
    }

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/reviews');

      final requestBody = {
        'ma_don_hang': maDonHang,
        'ma_nguyen_lieu': maNguyenLieu,
        'ma_gian_hang': maGianHang,
        'rating': rating,
        'binh_luan': binhLuan,
      };

      if (AppConfig.enableApiLogging) {
        AppLogger.info('⭐ [REVIEW API] Request body: $requestBody');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('⭐ [REVIEW API] Response status: ${response.statusCode}');
        AppLogger.info('⭐ [REVIEW API] Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return ReviewResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to submit review: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [REVIEW API] Submit review error: $e');
      }
      rethrow;
    }
  }
}

/// Model cho response khi gửi đánh giá
class ReviewResponse {
  final bool success;
  final ReviewData? review;
  final double? danhGiaTb;
  final String? message;

  ReviewResponse({
    required this.success,
    this.review,
    this.danhGiaTb,
    this.message,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      success: json['success'] ?? false,
      review: json['review'] != null ? ReviewData.fromJson(json['review']) : null,
      danhGiaTb: _parseToDouble(json['danh_gia_tb']),
      message: json['message'],
    );
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Model cho dữ liệu đánh giá
class ReviewData {
  final String maDanhGia;
  final String maDonHang;
  final String maNguyenLieu;
  final int rating;
  final String binhLuan;
  final DateTime? ngayDanhGia;

  ReviewData({
    required this.maDanhGia,
    required this.maDonHang,
    required this.maNguyenLieu,
    required this.rating,
    required this.binhLuan,
    this.ngayDanhGia,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      maDanhGia: json['ma_danh_gia'] ?? '',
      maDonHang: json['ma_don_hang'] ?? '',
      maNguyenLieu: json['ma_nguyen_lieu'] ?? '',
      rating: json['rating'] ?? 0,
      binhLuan: json['binh_luan'] ?? '',
      ngayDanhGia: json['ngay_danh_gia'] != null
          ? DateTime.tryParse(json['ngay_danh_gia'])
          : null,
    );
  }
}

/// Model cho response khi lấy danh sách đánh giá của gian hàng
class StoreReviewsResponse {
  final bool success;
  final int total;
  final double avg;
  final List<StoreReviewItem> items;

  StoreReviewsResponse({
    required this.success,
    required this.total,
    required this.avg,
    required this.items,
  });

  factory StoreReviewsResponse.fromJson(Map<String, dynamic> json) {
    return StoreReviewsResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      avg: _parseToDouble(json['avg']) ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => StoreReviewItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Model cho từng đánh giá của gian hàng
class StoreReviewItem {
  final String maDanhGia;
  final String? maDonHang;
  final String? maNguyenLieu;
  final int rating;
  final String binhLuan;
  final DateTime? ngayDanhGia;
  final ReviewerInfo? nguoiDanhGia;

  StoreReviewItem({
    required this.maDanhGia,
    this.maDonHang,
    this.maNguyenLieu,
    required this.rating,
    required this.binhLuan,
    this.ngayDanhGia,
    this.nguoiDanhGia,
  });

  factory StoreReviewItem.fromJson(Map<String, dynamic> json) {
    return StoreReviewItem(
      maDanhGia: json['ma_danh_gia'] ?? '',
      maDonHang: json['ma_don_hang'],
      maNguyenLieu: json['ma_nguyen_lieu'],
      rating: json['rating'] ?? 0,
      binhLuan: json['binh_luan'] ?? '',
      ngayDanhGia: json['ngay_danh_gia'] != null
          ? DateTime.tryParse(json['ngay_danh_gia'])
          : null,
      nguoiDanhGia: json['nguoi_danh_gia'] != null
          ? ReviewerInfo.fromJson(json['nguoi_danh_gia'])
          : null,
    );
  }
}

/// Model cho thông tin người đánh giá
class ReviewerInfo {
  final String maNguoiMua;
  final String tenHienThi;

  ReviewerInfo({
    required this.maNguoiMua,
    required this.tenHienThi,
  });

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewerInfo(
      maNguoiMua: json['ma_nguoi_mua'] ?? '',
      tenHienThi: json['ten_hien_thi'] ?? 'Người dùng',
    );
  }
}
