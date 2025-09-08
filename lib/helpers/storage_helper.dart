import 'dart:convert';
import 'dart:io';
import 'package:pocket_lawyer/main.dart';
class StorageHelper {
  static Future<void> saveMessages(List<ChatMessage> messages, String storagePath) async {
    try {
      if (storagePath.isNotEmpty) {
        final file = File(storagePath);
        final messagesJson = jsonEncode(messages
            .map((message) => {
                  'text': message.text,
                  'isUser': message.isUser,
                  'timestamp': message.timestamp.toIso8601String(),
                })
            .toList());
        await file.writeAsString(messagesJson);
        print('💾 Saved ${messages.length} messages to storage');
      }
    } catch (e) {
      print('💾 Error saving messages: $e');
    }
  }

  static Future<List<ChatMessage>> loadMessages(String storagePath) async {
    try {
      final file = File(storagePath);
      if (await file.exists()) {
        final messagesJson = await file.readAsString();
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        final messages = <ChatMessage>[];
        for (var messageData in messagesList) {
          messages.add(ChatMessage(
            text: messageData['text'],
            isUser: messageData['isUser'],
            timestamp: DateTime.parse(messageData['timestamp']),
          ));
        }
        print('💾 Loaded ${messages.length} messages from storage');
        return messages;
      } else {
        return [];
      }
    } catch (e) {
      print('💾 Error loading messages: $e');
      return [];
    }
  }

  static ChatMessage createWelcomeMessage() {
    return ChatMessage(
      text: "Welcome to Pocket Lawyer!\n\nClick the microphone button to start auto-detection mode. The AI will listen continuously and respond automatically. When you start speaking, the AI will immediately stop talking and listen to your new question - just like a real conversation where you can interrupt and ask something else!",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
