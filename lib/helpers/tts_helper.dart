import 'package:flutter_tts/flutter_tts.dart';

class TTSHelper {
  static Future<bool> initializeTTS(FlutterTts flutterTts, Function onStart, Function onComplete, Function onError) async {
    try {
      // Initialize TTS with Android 15 compatibility
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      // Set up TTS completion handler
      flutterTts.setCompletionHandler(() {
        print('🔊 TTS completed');
        onComplete();
      });

      // Set up TTS error handler
      flutterTts.setErrorHandler((msg) {
        print('🔊 TTS Error: $msg');
        onError();
      });

      // Set up TTS start handler
      flutterTts.setStartHandler(() {
        print('🔊 TTS started');
        onStart();
      });

      // Test TTS with a simple phrase for Android 15
      try {
        await flutterTts.speak("test");
        await flutterTts.stop();
        print('🔊 TTS initialized successfully');
        return true;
      } catch (testError) {
        print('🔊 TTS test failed: $testError');
        // Try alternative initialization for Android 15
        try {
          await flutterTts.setLanguage("en");
          await flutterTts.setSpeechRate(0.6);
          print('🔊 TTS initialized with fallback settings');
          return true;
        } catch (fallbackError) {
          print('🔊 TTS fallback failed: $fallbackError');
          return false;
        }
      }
    } catch (e) {
      print('🔊 TTS initialization failed: $e');
      return false;
    }
  }

  static Future<bool> speak(FlutterTts flutterTts, String text) async {
    try {
      // Stop any ongoing speech first
      await flutterTts.stop();
      // Wait a bit before starting new speech
      await Future.delayed(const Duration(milliseconds: 200));

      // Try multiple approaches for Android 15 compatibility
      bool speakSuccess = false;

      // Approach 1: Standard speak
      try {
        await flutterTts.speak(text);
        speakSuccess = true;
      } catch (e) {
        print('🔊 TTS approach 1 failed: $e');
      }

      // Approach 2: Reset and try again
      if (!speakSuccess) {
        try {
          await flutterTts.setLanguage("en-US");
          await flutterTts.setSpeechRate(0.5);
          await flutterTts.setVolume(1.0);
          await flutterTts.speak(text);
          speakSuccess = true;
        } catch (e) {
          print('🔊 TTS approach 2 failed: $e');
        }
      }

      // Approach 3: Alternative language code
      if (!speakSuccess) {
        try {
          await flutterTts.setLanguage("en");
          await flutterTts.setSpeechRate(0.6);
          await flutterTts.speak(text);
          speakSuccess = true;
        } catch (e) {
          print('🔊 TTS approach 3 failed: $e');
        }
      }

      if (!speakSuccess) {
        print('🔊 All TTS approaches failed');
      }

      return speakSuccess;
    } catch (e) {
      print('🔊 TTS speaking error: $e');
      return false;
    }
  }
}
