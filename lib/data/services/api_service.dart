import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for handling API communications with the legal AI backend
class ApiService {
  static const String baseUrl = 'https://ai.kanoony.com/api/ai/chat';
  static String? _sessionId;
  static int _messageCount = 0;

  static String get sessionId {
    if (_sessionId == null) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomId()}';
    }
    return _sessionId!;
  }

  static String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length]).join();
  }

  /// Sends a message to the AI legal assistant
  /// 
  /// [message] The text message to send
  /// [messageType] The type of message ('text' or 'voice')
  /// 
  /// Returns a Map containing the API response
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String messageType, // 'text' or 'voice'
  }) async {
    try {
      final payload = {
        'message': message,
        'message_type': messageType,
        'session_id': sessionId,
      };
      
      print('🌐 API REQUEST DETAILS:');
      print('📍 URL: $baseUrl');
      print('📦 Payload: ${jsonEncode(payload)}');
      print('🆔 Session ID: $sessionId');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Origin': 'https://ai.kanoony.com',
          'Referer': 'https://ai.kanoony.com/',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36',
        },
        body: jsonEncode(payload),
      );

      print('📡 HTTP Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _messageCount++;
        print('✅ API call successful! Message count: $_messageCount');
        return data;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Network Error: $e');
      throw Exception('Error sending message: $e');
    }
  }

  /// Resets the current session
  static void resetSession() {
    _sessionId = null;
    _messageCount = 0;
  }
}
