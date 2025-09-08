import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechHelper {
  static Function? _onErrorCallback;
  
  static void setErrorCallback(Function callback) {
    _onErrorCallback = callback;
  }

  static Future<bool> initializeSpeech(stt.SpeechToText speech) async {
    try {
      // Request microphone permission first
      final microphonePermission = await Permission.microphone.request();
      print('🎤 Microphone permission: $microphonePermission');

      if (microphonePermission.isGranted) {
        final speechEnabled = await speech.initialize(
          onError: (error) {
            print('🎤 Speech recognition error: $error');
            // Handle specific errors - don't stop listening for no_match
            if (error.errorMsg == 'error_network') {
              print('🎤 Network error - stopping listening');
            } else if (error.errorMsg == 'error_no_match') {
              print('🎤 No speech detected - triggering restart callback');
              // Call the error callback to restart listening
              if (_onErrorCallback != null) {
                _onErrorCallback!();
              }
            }
          },
          onStatus: (status) {
            print('🎤 Speech recognition status: $status');
          },
          debugLogging: true,
        );
        print('🎤 Speech recognition initialized: $speechEnabled');
        return speechEnabled;
      } else {
        print('🎤 Microphone permission denied');
        return false;
      }
    } catch (e) {
      print('🎤 Speech initialization failed: $e');
      return false;
    }
  }
}
