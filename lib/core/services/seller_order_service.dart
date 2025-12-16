import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/seller_order_model.dart';
import 'auth/simple_auth_helper.dart';

/// Service để quản lý đơn hàng của seller
class SellerOrderService {
  static const String _baseUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/seller';

  /// Lấy danh sách đơn hàng của seller
  Future<SellerOrdersResponse> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('$_baseUrl/orders').replace(queryParameters: queryParams);
      
      debugPrint('📦 [SELLER ORDER] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📦 [SELLER ORDER] Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return SellerOrdersResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [SELLER ORDER] Error: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết đơn hàng
  Future<SellerOrderDetailResponse> getOrderDetail(String maDonHang) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/orders/$maDonHang');
      
      debugPrint('📦 [SELLER ORDER] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📦 [SELLER ORDER] Detail response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return SellerOrderDetailResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load order detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [SELLER ORDER] Detail error: $e');
      rethrow;
    }
  }

  /// Xác nhận đơn hàng
  Future<ConfirmOrderResponse> confirmOrder(String maDonHang) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/orders/$maDonHang/confirm');
      
      debugPrint('📦 [SELLER ORDER] POST $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📦 [SELLER ORDER] Confirm response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return ConfirmOrderResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to confirm order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [SELLER ORDER] Confirm error: $e');
      rethrow;
    }
  }

  /// Lấy danh sách lý do từ chối
  Future<RejectionReasonsResponse> getRejectionReasons() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/rejection-reasons');
      
      debugPrint('📦 [SELLER ORDER] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📦 [SELLER ORDER] Rejection reasons response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return RejectionReasonsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load rejection reasons: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [SELLER ORDER] Rejection reasons error: $e');
      rethrow;
    }
  }

  /// Từ chối đơn hàng
  Future<RejectOrderResponse> rejectOrder(String maDonHang, {required String reasonCode}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }

      final uri = Uri.parse('$_baseUrl/orders/$maDonHang/reject');
      final requestBody = json.encode({'reason_code': reasonCode});
      
      debugPrint('📦 [SELLER ORDER] POST $uri');
      debugPrint('📦 [SELLER ORDER] Request body: $requestBody');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      debugPrint('📦 [SELLER ORDER] Reject response status: ${response.statusCode}');
      debugPrint('📦 [SELLER ORDER] Reject response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('📦 [SELLER ORDER] Reject parsed: success=${jsonData['success']}, message=${jsonData['message']}');
        debugPrint('📦 [SELLER ORDER] Reject data: ${jsonData['data']}');
        return RejectOrderResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to reject order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [SELLER ORDER] Reject error: $e');
      rethrow;
    }
  }
}
