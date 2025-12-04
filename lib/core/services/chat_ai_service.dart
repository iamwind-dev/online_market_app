import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_ai_model.dart';
import 'auth/auth_service.dart';
import '../dependency/injection.dart';

class ChatAIService {
  static const String baseUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com';
  final AuthService _authService = getIt<AuthService>();

  /// Gửi tin nhắn chat đến AI
  Future<ChatAIResponse> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      final token = await _authService.getToken();
      
      final body = {
        'message': message,
        if (conversationId != null) 'conversation_id': conversationId,
      };

      print('🔍 [ChatAIService] Sending message...');
      print('   Message: $message');
      print('   Conversation ID: $conversationId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('🔍 [ChatAIService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final result = ChatAIResponse.fromJson(jsonData);
        print('✅ [ChatAIService] Chat response received');
        print('   Conversation ID: ${result.conversationId}');
        return result;
      } else {
        throw Exception('Failed to send chat message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ChatAIService] Error: $e');
      rethrow;
    }
  }
}
