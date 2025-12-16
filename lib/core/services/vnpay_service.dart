import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth/simple_auth_helper.dart';

/// Service để xử lý thanh toán VNPay
class VNPayService {
  static const String _baseUrl =
      'https://subtle-seat-475108-v5.et.r.appspot.com/api/payment';

  /// Get order status để check kết quả thanh toán
  Future<OrderStatusResponse> getOrderStatus(String maDonHang) async {
    print('💳 [VNPAY] Getting order status for: $maDonHang');

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer/orders/$maDonHang',
      );

      print('💳 [VNPAY] Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('💳 [VNPAY] Response status: ${response.statusCode}');
      print('💳 [VNPAY] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return OrderStatusResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to get order status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [VNPAY] Error: $e');
      rethrow;
    }
  }

  /// Verify payment result từ VNPay callback
  Future<VNPayReturnResponse> verifyPaymentReturn({
    required Map<String, String> queryParams,
  }) async {
    print('💳 [VNPAY] Verifying payment return...');
    print('💳 [VNPAY] Query params: $queryParams');

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      // Build URL với query parameters
      final uri = Uri.parse('$_baseUrl/vnpay/return').replace(
        queryParameters: queryParams,
      );

      print('💳 [VNPAY] Request URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('💳 [VNPAY] Response status: ${response.statusCode}');
      print('💳 [VNPAY] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return VNPayReturnResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to verify payment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [VNPAY] Error: $e');
      rethrow;
    }
  }

  /// Tạo checkout VNPay
  Future<VNPayCheckoutResponse> createVNPayCheckout({
    required String maThanhToan,
    String bankCode = 'NCB',
  }) async {
    print('💳 [VNPAY] Creating checkout...');
    print('💳 [VNPAY] ma_thanh_toan: $maThanhToan');
    print('💳 [VNPAY] bankCode: $bankCode');

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/vnpay/checkout');
      
      final requestBody = {
        'ma_thanh_toan': maThanhToan,
        'bankCode': bankCode,
      };

      print('💳 [VNPAY] Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('💳 [VNPAY] Response status: ${response.statusCode}');
      print('💳 [VNPAY] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return VNPayCheckoutResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to create VNPay checkout: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [VNPAY] Error: $e');
      rethrow;
    }
  }
}

/// Model cho VNPay checkout response
class VNPayCheckoutResponse {
  final bool success;
  final String redirect;
  final String maThanhToan;
  final double amount;

  VNPayCheckoutResponse({
    required this.success,
    required this.redirect,
    required this.maThanhToan,
    required this.amount,
  });

  factory VNPayCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return VNPayCheckoutResponse(
      success: json['success'] ?? false,
      redirect: json['redirect'] ?? '',
      maThanhToan: json['ma_thanh_toan'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Model cho Order status response
class OrderStatusResponse {
  final bool success;
  final String maDonHang;
  final String trangThai; // VD: "da_thanh_toan", "cho_thanh_toan", "huy"
  final String? message;
  final double? tongTien;

  OrderStatusResponse({
    required this.success,
    required this.maDonHang,
    required this.trangThai,
    this.message,
    this.tongTien,
  });

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) {
    // Xử lý cả trường hợp response có nested "order" object hoặc flat
    final orderData = json['order'] as Map<String, dynamic>? ?? json;
    
    return OrderStatusResponse(
      success: json['success'] ?? true,
      maDonHang: orderData['ma_don_hang'] ?? json['ma_don_hang'] ?? '',
      trangThai: orderData['trang_thai'] ?? json['trang_thai'] ?? '',
      message: json['message'],
      tongTien: (orderData['tong_tien'] as num?)?.toDouble() ?? 
               (json['tong_tien'] as num?)?.toDouble(),
    );
  }

  bool get isPaid => trangThai == 'da_thanh_toan' || trangThai == 'paid';
  bool get isPending => trangThai == 'cho_thanh_toan' || trangThai == 'pending';
  bool get isCancelled => trangThai == 'huy' || trangThai == 'cancelled';
}

/// Model cho VNPay return response (kết quả thanh toán)
class VNPayReturnResponse {
  final bool success;
  final String message;
  final String maDonHang;
  final bool clearCart;

  VNPayReturnResponse({
    required this.success,
    required this.message,
    required this.maDonHang,
    required this.clearCart,
  });

  factory VNPayReturnResponse.fromJson(Map<String, dynamic> json) {
    return VNPayReturnResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      maDonHang: json['ma_don_hang'] ?? '',
      clearCart: json['clear_cart'] ?? false,
    );
  }
}
