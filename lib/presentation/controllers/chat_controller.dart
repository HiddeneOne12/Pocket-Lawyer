import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../helpers/storage_helper.dart';
import '../../domain/models/chat_message.dart';
import '../services/voice_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Controller for managing chat functionality
class ChatController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isVoiceMode = false;
  bool _isListening = false;
  String _storagePath = '';
  
  late VoiceService _voiceService;
  late stt.SpeechToText _speech;

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isVoiceMode => _isVoiceMode;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    _voiceService = VoiceService();
    _speech = stt.SpeechToText();
    await _voiceService.initialize();
     _initStorage();
  }

  void _initStorage() async {
    try {
      _storagePath = '/data/data/com.example.pocket_lawyer/files/chat_messages.json';
      await _loadMessages();
    } catch (e) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    _messages.add(StorageHelper.createWelcomeMessage());
    notifyListeners();
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await StorageHelper.loadMessages(_storagePath);
    if (loadedMessages.isNotEmpty) {
      _messages.clear();
      _messages.addAll(loadedMessages);
    } else {
      _addWelcomeMessage();
      await _saveMessages();
    }
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    await StorageHelper.saveMessages(_messages, _storagePath);
  }

  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: messageText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    await _saveMessages();
    await _sendToAPI(messageText.trim(), 'text');
  }

  Future<void> sendVoiceMessage() async {
    if (_voiceService.lastWords.isNotEmpty) {
      _messages.add(ChatMessage(
        text: _voiceService.lastWords,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      notifyListeners();

      await _saveMessages();
      await _sendToAPI(_voiceService.lastWords, 'voice');
      _voiceService.clearLastWords();
    }
  }

  Future<void> _sendToAPI(String message, String messageType) async {
    try {
      final response = await ApiService.sendMessage(
        message: message,
        messageType: messageType,
      );

      if (response['success'] == true) {
        final aiResponse = response['response'] ?? 'Sorry, I could not process your request.';

        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
        notifyListeners();

        await _saveMessages();

        if (messageType == 'voice') {
          await _voiceService.speak(aiResponse);
        }
      } else {
        throw Exception('API returned error');
      }
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
      notifyListeners();
      await _saveMessages();
    }
  }

  void toggleInputMode() {
    if (_isVoiceMode && _isListening) {
      _speech.stop();
      _isListening = false;
      _isVoiceMode = false;
    } else {
      _isVoiceMode = !_isVoiceMode;
    }
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (_voiceService.isAISpeaking) return;

    await _voiceService.stopSpeaking();

    if (!_voiceService.speechEnabled) {
      final hasPermission = await _voiceService.requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Microphone permission is required for voice input.');
      }
    }

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      if (_voiceService.lastWords.isNotEmpty) {
        await sendVoiceMessage();
      }
    } else {
      _isListening = true;
      _voiceService.clearLastWords();

      try {
        Timer? silenceTimer;
        Timer? noSpeechTimer;

        noSpeechTimer = Timer(const Duration(seconds: 10), () {
          if (_isListening && _voiceService.lastWords.isEmpty) {
            _speech.stop();
            _isListening = false;
            notifyListeners();
          }
        });

        await _speech.listen(
          onResult: (result) {
            _voiceService.setLastWords(result.recognizedWords);
            notifyListeners();

            noSpeechTimer?.cancel();
            silenceTimer?.cancel();

            if (_voiceService.lastWords.isNotEmpty) {
              _voiceService.setWaitingForSilence(true);
              
              if (_voiceService.isAISpeaking) {
                _voiceService.stopSpeaking();
              }
              
              silenceTimer = Timer(const Duration(seconds: 2), () {
                if (_voiceService.lastWords.isNotEmpty) {
                  _isListening = false;
                  _voiceService.setWaitingForSilence(false);
                  notifyListeners();
                  sendVoiceMessage();
                } else {
                  _voiceService.setWaitingForSilence(false);
                }
              });
            }
          },
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 15),
          partialResults: true,
          localeId: 'en_US',
          listenMode: stt.ListenMode.dictation,
          onSoundLevelChange: (level) {
            if (level > 0) {
              noSpeechTimer?.cancel();
              silenceTimer?.cancel();
              _voiceService.setWaitingForSilence(false);
              
              if (_voiceService.isAISpeaking) {
                _voiceService.stopSpeaking();
              }
              
              if (_voiceService.lastWords.isNotEmpty) {
                _voiceService.setWaitingForSilence(true);
                silenceTimer = Timer(const Duration(seconds: 2), () {
                  if (_voiceService.lastWords.isNotEmpty) {
                    _isListening = false;
                    _voiceService.setWaitingForSilence(false);
                    notifyListeners();
                    sendVoiceMessage();
                  }
                });
              }
            }
          },
        );
      } catch (e) {
        _isListening = false;
        notifyListeners();
        throw Exception('Speech recognition error: $e');
      }
    }
    notifyListeners();
  }
}
