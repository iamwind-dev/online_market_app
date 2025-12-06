import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gian_hang_model.dart';
import '../models/shop_detail_model.dart';
import '../error/exceptions.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';
import 'auth/auth_service.dart';
import '../dependency/injection.dart';

/// Service để fetch danh sách gian hàng
class GianHangService {
  static const String baseUrl =
      'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer';
  final AuthService _authService = getIt<AuthService>();

  /// Lấy danh sách gian hàng
  ///
  /// Parameters:
  /// - page: Trang hiện tại (default: 1)
  /// - limit: Số lượng items per page (default: 12)
  /// - sort: Field để sort (default: 'ten_gian_hang')
  /// - order: Thứ tự sort 'asc' hoặc 'desc' (default: 'asc')
  Future<GianHangResponse> getGianHangList({
    int page = 1,
    int limit = 30,
    String sort = 'ten_gian_hang',
    String order = 'asc',
  }) async {
    try {
      final token = await _authService.getToken();

      final uri = Uri.parse('$baseUrl/gian-hang').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'sort': sort,
          'order': order,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return GianHangResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token hết hạn hoặc không hợp lệ');
      } else {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw NetworkException('Lỗi kết nối: ${e.toString()}');
    }
  }

  /// Lấy chi tiết gian hàng theo mã
  /// API: GET /api/buyer/gian-hang/{ma_gian_hang}
  Future<ShopDetailResponse> getShopDetail(String maGianHang) async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🏪 [GIAN HANG] Fetching shop detail: $maGianHang');
    }

    try {
      final token = await _authService.getToken();

      final uri = Uri.parse('$baseUrl/gian-hang/$maGianHang');

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🏪 [GIAN HANG] URL: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🏪 [GIAN HANG] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (AppConfig.enableApiLogging) {
          AppLogger.info('✅ [GIAN HANG] Shop detail loaded successfully');
        }

        return ShopDetailResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token hết hạn hoặc không hợp lệ');
      } else if (response.statusCode == 404) {
        throw ServerException('Không tìm thấy gian hàng');
      } else {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [GIAN HANG] Error: $e');
      }
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw NetworkException('Lỗi kết nối: ${e.toString()}');
    }
  }
}
