import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Helper đơn giản để xử lý đăng nhập với error handling và timeout
/// 
/// Usage:
/// ```dart
/// await logIn(context, 'duong123', '123456789');
/// await logOut();
/// ```
class SimpleAuthHelper {
  // API Configuration
  static const String _loginUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/auth/login';
  static const int _timeoutSeconds = 30; // Tăng lên 30 giây vì API phản hồi chậm
  
  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
}

/// Hàm đăng nhập chính
/// 
/// Parameters:
/// - context: BuildContext để hiển thị SnackBar
/// - username: Tên đăng nhập (vd: "duong123")
/// - password: Mật khẩu (vd: "123456789")
/// 
/// Throws:
/// - Không throw exception, tất cả lỗi được xử lý nội bộ
/// 
/// Returns:
/// - Future<bool> - true nếu đăng nhập thành công, false nếu thất bại
Future<bool> logIn(BuildContext context, String username, String password) async {
  print('[LOGIN] 🔐 Bắt đầu đăng nhập - username: $username');
  
  try {
    // Prepare request body
    final requestBody = {
      'ten_dang_nhap': username,
      'mat_khau': password,
    };
    
    print('[LOGIN] 📤 Sending request to: ${SimpleAuthHelper._loginUrl}');
    print('[LOGIN] 📤 Request body: ${jsonEncode(requestBody)}');
    
    // Send POST request with timeout
    final response = await http.post(
      Uri.parse(SimpleAuthHelper._loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(
      Duration(seconds: SimpleAuthHelper._timeoutSeconds),
      onTimeout: () {
        print('[LOGIN] ⏱️ Network error: Timeout - Vui lòng thử lại');
        throw TimeoutException('Request timeout');
      },
    );
    
    print('[LOGIN] 📥 Response status: ${response.statusCode}');
    print('[LOGIN] 📥 Response body: ${response.body}');
    
    // Check status code
    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ SUCCESS - Parse response
      try {
        final jsonData = jsonDecode(response.body);
        final token = jsonData['token'] as String?;
        final userData = jsonData['data'] as Map<String, dynamic>?;
        
        if (token == null || userData == null) {
          throw FormatException('Invalid response format: missing token or data');
        }
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(SimpleAuthHelper._tokenKey, token);
        await prefs.setString(SimpleAuthHelper._userDataKey, jsonEncode(userData));
        await prefs.setBool(SimpleAuthHelper._isLoggedInKey, true);
        
        final userDisplayName = userData['ten_dang_nhap'] ?? username;
        print('[LOGIN] ✅ Success - username: $userDisplayName');
        print('[LOGIN] 🎫 Token saved: ${token.substring(0, 20)}...');
        
        // Show success SnackBar (GREEN)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        
        return true; // ✅ Đăng nhập thành công
        
      } catch (e) {
        print('[LOGIN] ❌ Error parsing response: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi xử lý dữ liệu từ máy chủ'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false; // ❌ Lỗi parse response
      }
      
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // ❌ UNAUTHORIZED - Wrong credentials
      print('[LOGIN] ❌ Sai tên đăng nhập hoặc mật khẩu');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sai tên đăng nhập hoặc mật khẩu!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      return false; // ❌ Sai mật khẩu
      
    } else {
      // ❌ OTHER ERROR
      print('[LOGIN] ❌ Server error: ${response.statusCode}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi máy chủ (${response.statusCode})'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      return false; // ❌ Lỗi server
    }
    
  } on TimeoutException catch (e) {
    // ⏱️ TIMEOUT
    print('[LOGIN] ⏱️ Network error: Timeout - Vui lòng thử lại');
    print('[LOGIN] ⏱️ Error details: $e');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết nối đến máy chủ. Vui lòng thử lại!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    return false; // ❌ Timeout
    
  } on SocketException catch (e) {
    // 🌐 NETWORK ERROR (No internet, DNS resolution failed, etc.)
    print('[LOGIN] 🌐 Network error: SocketException - ${e.message}');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết nối đến máy chủ. Vui lòng thử lại!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    return false; // ❌ Network error
    
  } on http.ClientException catch (e) {
    // 🔌 HTTP CLIENT ERROR
    print('[LOGIN] 🔌 Network error: ClientException - $e');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết nối đến máy chủ. Vui lòng thử lại!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    return false; // ❌ HTTP client error
    
  } catch (e) {
    // 💥 UNKNOWN ERROR
    print('[LOGIN] 💥 Unexpected error: $e');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã có lỗi xảy ra: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    return false; // ❌ Unknown error
  }
}

/// Hàm đăng xuất
/// 
/// Xóa tất cả dữ liệu authentication khỏi SharedPreferences:
/// - Token
/// - User data
/// - Login status
/// 
/// Returns:
/// - Future<void> - Hoàn thành khi đã xóa xong
Future<void> logOut() async {
  print('[LOGOUT] 🚪 Đang đăng xuất...');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove all auth data
    await prefs.remove(SimpleAuthHelper._tokenKey);
    await prefs.remove(SimpleAuthHelper._userDataKey);
    await prefs.remove(SimpleAuthHelper._isLoggedInKey);
    
    print('[LOGOUT] ✅ Đăng xuất thành công - Đã xóa token và user data');
    
  } catch (e) {
    print('[LOGOUT] ❌ Lỗi khi đăng xuất: $e');
    // Even if error, try to remove data individually
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Last resort: clear all data
      print('[LOGOUT] ✅ Đã xóa tất cả dữ liệu local');
    } catch (e2) {
      print('[LOGOUT] ❌ Không thể xóa dữ liệu: $e2');
    }
  }
}

/// Kiểm tra trạng thái đăng nhập
/// 
/// Returns:
/// - Future<bool> - true nếu đã đăng nhập, false nếu chưa
Future<bool> isLoggedIn() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString(SimpleAuthHelper._tokenKey) != null;
    final isLoggedIn = prefs.getBool(SimpleAuthHelper._isLoggedInKey) ?? false;
    return hasToken && isLoggedIn;
  } catch (e) {
    print('[AUTH] ❌ Lỗi kiểm tra login status: $e');
    return false;
  }
}

/// Lấy token đã lưu
/// 
/// Returns:
/// - Future<String?> - Token nếu có, null nếu không có
Future<String?> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SimpleAuthHelper._tokenKey);
  } catch (e) {
    print('[AUTH] ❌ Lỗi lấy token: $e');
    return null;
  }
}

/// Lấy user data đã lưu
/// 
/// Returns:
/// - Future<Map<String, dynamic>?> - User data nếu có, null nếu không có
Future<Map<String, dynamic>?> getUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(SimpleAuthHelper._userDataKey);
    
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    
    return null;
  } catch (e) {
    print('[AUTH] ❌ Lỗi lấy user data: $e');
    return null;
  }
}
