import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Controller for managing voice functionality
class VoiceController extends ChangeNotifier {
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  String _status = 'Tap to start speaking';
  
  late stt.SpeechToText _speech;

  // Getters
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  String get status => _status;

  Future<void> initialize() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        _status = status;
        notifyListeners();
        if (status == 'done' && _isListening) {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (errorNotification) {
        _isListening = false;
        _status = 'Error: ${errorNotification.errorMsg}';
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (!_speechEnabled) {
      final microphonePermission = await Permission.microphone.status;
      if (!microphonePermission.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          _status = 'Microphone permission required';
          notifyListeners();
          return;
        }
      }
      await initialize();
      if (!_speechEnabled) {
        _status = 'Speech recognition not available';
        notifyListeners();
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      _status = 'Stopped listening';
    } else {
      _isListening = true;
      _lastWords = '';
      _status = 'Listening...';
      
      try {
        await _speech.listen(
          onResult: (result) {
            _lastWords = result.recognizedWords;
            notifyListeners();
          },
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'en_US',
          listenMode: stt.ListenMode.dictation,
        );
      } catch (e) {
        _isListening = false;
        _status = 'Error: $e';
      }
    }
    notifyListeners();
  }

  void stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      _status = 'Stopped';
      notifyListeners();
    }
  }

  void clearText() {
    _lastWords = '';
    _status = 'Tap to start speaking';
    notifyListeners();
  }
}
