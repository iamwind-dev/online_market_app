import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth/simple_auth_helper.dart';

/// Service để xử lý thanh toán VNPay
class VNPayService {
  static const String _baseUrl =
      'https://subtle-seat-475108-v5.et.r.appspot.com/api/payment';

  /// Tạo checkout VNPay
  Future<VNPayCheckoutResponse> createVNPayCheckout({
    required String maDonHang,
    String bankCode = 'MBBANK',
  }) async {
    print('💳 [VNPAY] Creating checkout...');
    print('💳 [VNPAY] ma_don_hang: $maDonHang');
    print('💳 [VNPAY] bankCode: $bankCode');

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('$_baseUrl/vnpay/checkout');
      
      final requestBody = {
        'ma_don_hang': maDonHang,
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
