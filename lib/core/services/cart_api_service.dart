import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_response.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';
import 'auth/simple_auth_helper.dart';

/// Service để fetch thông tin giỏ hàng từ API
class CartApiService {
  static const String _baseUrl =
      'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer';

  /// Thêm sản phẩm vào giỏ hàng
  Future<AddToCartResponse> addToCart({
    required String maNguyenLieu,
    required String maGianHang,
    required int soLuong,
    String maCho = 'C01',
  }) async {
    print('🛒 [CART API] ========== ADD TO CART REQUEST ==========');
    print('🛒 [CART API] ma_nguyen_lieu: $maNguyenLieu');
    print('🛒 [CART API] ma_gian_hang: $maGianHang');
    print('🛒 [CART API] so_luong: $soLuong');
    print('🛒 [CART API] ma_cho: $maCho');

    if (AppConfig.enableApiLogging) {
      AppLogger.info('🛒 [CART API] Adding item to cart: $maNguyenLieu');
    }

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/cart/items');
      
      final requestBody = {
        'ma_nguyen_lieu': maNguyenLieu,
        'ma_gian_hang': maGianHang,
        'so_luong': soLuong,
        'ma_cho': maCho,
      };

      print('🛒 [CART API] URL: $url');
      print('🛒 [CART API] Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('🛒 [CART API] Response Status: ${response.statusCode}');
      print('🛒 [CART API] Response Body: ${response.body}');
      print('🛒 [CART API] ========================================');

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🛒 [CART API] Add to cart response: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return AddToCartResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to add to cart: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [CART API] Error: $e');
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [CART API] Add to cart error: $e');
      }
      rethrow;
    }
  }

  /// Fetch thông tin giỏ hàng
  Future<CartResponse> getCart() async {
    if (AppConfig.enableApiLogging) {
      AppLogger.info('🛒 [CART API] Fetching cart data');
    }

    try {
      // Get authentication token
      final token = await getToken();
      
      if (token == null) {
        if (AppConfig.enableApiLogging) {
          AppLogger.warning('🛒 [CART API] No token found - user not logged in');
        }
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/cart');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (AppConfig.enableApiLogging) {
        AppLogger.info('🛒 [CART API] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (AppConfig.enableApiLogging) {
          AppLogger.info('🛒 [CART API] Response data: $jsonData');
        }

        final cartResponse = CartResponse.fromJson(jsonData);

        if (AppConfig.enableApiLogging) {
          AppLogger.info(
              '✅ [CART API] Success - ${cartResponse.cart.soMatHang} items');
        }

        return cartResponse;
      } else {
        throw Exception(
            'Failed to load cart: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (AppConfig.enableApiLogging) {
        AppLogger.error('❌ [CART API] Error: $e');
      }
      rethrow;
    }
  }
}
