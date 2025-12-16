import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/market_info_model.dart';
import '../models/market_map_model.dart';
import '../models/seller_list_model.dart';
import 'auth/simple_auth_helper.dart';

/// Service để quản lý thông tin chợ cho market manager
class MarketManagerService {
  static const String _baseUrl =
      'https://subtle-seat-475108-v5.et.r.appspot.com/api/market-manager';

  /// Lấy thông tin chợ của market manager
  Future<MarketInfoResponse> getMarketInfo() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/market');

      debugPrint('🏪 [MARKET MANAGER] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🏪 [MARKET MANAGER] Response: ${response.statusCode}');
      debugPrint('🏪 [MARKET MANAGER] Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return MarketInfoResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load market info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [MARKET MANAGER] Error: $e');
      rethrow;
    }
  }

  /// Lấy dữ liệu sơ đồ chợ
  Future<MarketMapResponse> getMapData() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/map');

      debugPrint('🗺️ [MARKET MAP] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🗺️ [MARKET MAP] Response: ${response.statusCode}');
      debugPrint('🗺️ [MARKET MAP] Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return MarketMapResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load map data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [MARKET MAP] Error: $e');
      rethrow;
    }
  }

  /// Cập nhật cấu hình grid sơ đồ chợ
  Future<bool> updateGridConfig({
    required int gridCellWidth,
    required int gridCellHeight,
    required int gridColumns,
    required int gridRows,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/grid-config');
      final body = json.encode({
        'grid_cell_width': gridCellWidth,
        'grid_cell_height': gridCellHeight,
        'grid_columns': gridColumns,
        'grid_rows': gridRows,
      });

      debugPrint('⚙️ [GRID CONFIG] PUT $uri');
      debugPrint('⚙️ [GRID CONFIG] Body: $body');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint('⚙️ [GRID CONFIG] Response: ${response.statusCode}');
      debugPrint('⚙️ [GRID CONFIG] Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to update grid config: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [GRID CONFIG] Error: $e');
      rethrow;
    }
  }

  /// Cập nhật vị trí gian hàng trên sơ đồ
  Future<bool> updateStorePosition({
    required String maGianHang,
    required int gridRow,
    required int gridCol,
    int gridFloor = 1,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/map/$maGianHang');
      final body = json.encode({
        'grid_row': gridRow,
        'grid_col': gridCol,
        'grid_floor': gridFloor,
      });

      debugPrint('📍 [STORE POSITION] PUT $uri');
      debugPrint('📍 [STORE POSITION] Body: $body');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint('📍 [STORE POSITION] Response: ${response.statusCode}');
      debugPrint('📍 [STORE POSITION] Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to update store position: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [STORE POSITION] Error: $e');
      rethrow;
    }
  }

  /// Lấy danh sách tiểu thương với phân trang
  Future<SellerListResponse> getSellers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/sellers?page=$page&limit=$limit');

      debugPrint('👥 [SELLERS] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('👥 [SELLERS] Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return SellerListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load sellers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [SELLERS] Error: $e');
      rethrow;
    }
  }

  /// Thêm tiểu thương mới
  Future<bool> addSeller({
    required String tenDangNhap,
    required String matKhau,
    required String tenNguoiDung,
    required String sdt,
    required String diaChi,
    required String gioiTinh,
    required String tenGianHang,
    required String viTri,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/sellers');
      final body = json.encode({
        'ten_dang_nhap': tenDangNhap,
        'mat_khau': matKhau,
        'ten_nguoi_dung': tenNguoiDung,
        'sdt': sdt,
        'dia_chi': diaChi,
        'gioi_tinh': gioiTinh,
        'ten_gian_hang': tenGianHang,
        'vi_tri': viTri,
      });

      debugPrint('➕ [ADD SELLER] POST $uri');
      debugPrint('➕ [ADD SELLER] Body: $body');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint('➕ [ADD SELLER] Response: ${response.statusCode}');
      debugPrint('➕ [ADD SELLER] Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to add seller: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [ADD SELLER] Error: $e');
      rethrow;
    }
  }
}
