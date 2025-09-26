import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../../helpers/tts_helper.dart';

/// Service class for handling voice input and TTS functionality
class VoiceService {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  bool _speechEnabled = false;
  bool _ttsEnabled = false;
  bool _isAISpeaking = false;
  bool _isWaitingForSilence = false;
  String _lastWords = '';
  
  Timer? _listeningCheckTimer;

  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get ttsEnabled => _ttsEnabled;
  bool get isAISpeaking => _isAISpeaking;
  bool get isWaitingForSilence => _isWaitingForSilence;
  String get lastWords => _lastWords;

  Future<void> initialize() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize();
    
    _flutterTts = FlutterTts();
    _ttsEnabled = await TTSHelper.initializeTTS(
      _flutterTts,
      _onTTSStart,
      _onTTSComplete,
      _onTTSError,
    );
  }

  void _onTTSStart() {
    _isAISpeaking = true;
  }

  void _onTTSComplete() {
    _isAISpeaking = false;
  }

  void _onTTSError() {
    _ttsEnabled = false;
    _isAISpeaking = false;
  }

  Future<bool> requestMicrophonePermission() async {
    final microphonePermission = await Permission.microphone.status;
    if (!microphonePermission.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> speak(String text) async {
    if (_ttsEnabled) {
      await TTSHelper.speak(_flutterTts, text);
    } else {
      _ttsEnabled = await TTSHelper.initializeTTS(
        _flutterTts,
        _onTTSStart,
        _onTTSComplete,
        _onTTSError,
      );
      if (_ttsEnabled) {
        await TTSHelper.speak(_flutterTts, text);
      }
    }
  }

  Future<void> stopSpeaking() async {
    if (_ttsEnabled) {
      try {
        await _flutterTts.stop();
      } catch (e) {
        // Handle error
      }
    }
  }

  void setLastWords(String words) {
    _lastWords = words;
  }

  void clearLastWords() {
    _lastWords = '';
  }

  void setWaitingForSilence(bool waiting) {
    _isWaitingForSilence = waiting;
  }

  void dispose() {
    _listeningCheckTimer?.cancel();
  }
}
