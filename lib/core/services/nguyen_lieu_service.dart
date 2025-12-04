import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nguyen_lieu_model.dart';
import '../models/nguyen_lieu_detail_model.dart';
import '../error/exceptions.dart';
import 'auth/auth_service.dart';
import '../dependency/injection.dart';

/// Service để fetch danh sách nguyên liệu
class NguyenLieuService {
  static const String baseUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer';
  final AuthService _authService = getIt<AuthService>();

  /// Lấy danh sách nguyên liệu
  Future<NguyenLieuResponse> getNguyenLieuList({
    int page = 1,
    int limit = 12,
    String sort = 'ten_nguyen_lieu',
    String order = 'asc',
    String? maCho, // Thêm parameter mã chợ
    bool hinhAnh = true, // Thêm parameter hình ảnh
  }) async {
    try {
      final token = await _authService.getToken();
      
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'order': order,
        'hinh_anh': hinhAnh.toString(), // Thêm parameter hình ảnh
        if (maCho != null && maCho.isNotEmpty) 'ma_cho': maCho, // Thêm mã chợ vào query
        
      };
      
      final uri = Uri.parse('$baseUrl/nguyen-lieu').replace(
        queryParameters: queryParams,
      );

      print('🔍 [NguyenLieuService] Fetching nguyen lieu...');
      print('   URL: $uri');
      print('   Ma cho: $maCho');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('🔍 [NguyenLieuService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final result = NguyenLieuResponse.fromJson(jsonData);
        print('✅ [NguyenLieuService] Fetched ${result.data.length} nguyen lieu');
        return result;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token hết hạn hoặc không hợp lệ');
      } else {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [NguyenLieuService] Error: $e');
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw NetworkException('Lỗi kết nối: ${e.toString()}');
    }
  }

  /// Lấy chi tiết nguyên liệu theo mã
  Future<NguyenLieuDetailResponse> getNguyenLieuDetail(String maNguyenLieu) async {
    try {
      final token = await _authService.getToken();
      
      final uri = Uri.parse('$baseUrl/nguyen-lieu/$maNguyenLieu');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return NguyenLieuDetailResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token hết hạn hoặc không hợp lệ');
      } else if (response.statusCode == 404) {
        throw ServerException('Không tìm thấy nguyên liệu');
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
}
