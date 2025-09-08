import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
import 'api_service.dart';
import 'helpers/speech_helper.dart';
import 'helpers/tts_helper.dart';
import 'helpers/storage_helper.dart';
import 'helpers/ui_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Lawyer AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const ChatBotPage(),
    );
  }
}

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isVoiceMode = true;
  bool _isListening = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _speechEnabled = false;
  bool _ttsEnabled = false;
  String _lastWords = '';
  bool _isLoading = false;
  String _storagePath = '';
  bool _isWaitingForSilence = false;
  bool _isAISpeaking = false;
  Timer? _listeningCheckTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initSpeech();
    _initTts();
    _initStorage();
    _startListeningCheck();
  }

  void _initSpeech() async {
    // Set up error callback for error_no_match
    SpeechHelper.setErrorCallback(() {
      print('🎤 Error callback triggered - restarting listening');
      _handleSpeechError();
    });
    
    _speechEnabled = await SpeechHelper.initializeSpeech(_speech);
    setState(() {});
  }

  void _handleSpeechError() {
    print('🎤 Handling speech error - stopping and restarting');
    // Stop any current listening
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _isWaitingForSilence = false;
      });
    }
    
    // Wait a bit then restart
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isVoiceMode && !_isListening) {
        print('🎤 Restarting listening after error_no_match');
        // Reinitialize speech first
        _reinitializeSpeech();
      }
    });
  }

  void _reinitializeSpeech() async {
    try {
      print('🎤 Reinitializing speech recognition...');
      _speechEnabled = await SpeechHelper.initializeSpeech(_speech);
      if (_speechEnabled) {
        print('🎤 Speech reinitialized successfully - starting listening');
        setState(() {});
        // Start listening after reinitialization
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isVoiceMode && !_isListening) {
            _toggleListening();
          }
        });
      } else {
        print('🎤 Speech reinitialization failed');
      }
    } catch (e) {
      print('🎤 Speech reinitialization error: $e');
    }
  }

  void _startListeningCheck() {
    // Check every 5 seconds if we should be listening but aren't
    _listeningCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isVoiceMode && !_isListening && !_isAISpeaking && _speechEnabled) {
        print('🎤 Periodic check - should be listening but not, restarting...');
        _toggleListening();
      }
    });
  }

  void _initTts() async {
    _ttsEnabled = await TTSHelper.initializeTTS(
      _flutterTts,
      _onTTSStart,
      _onTTSComplete,
      _onTTSError,
    );
    setState(() {});
  }

  void _onTTSStart() {
    print('🔊 TTS started - stopping listening to avoid AI voice detection');
    _isAISpeaking = true;
    // Stop listening immediately when AI starts speaking
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _isWaitingForSilence = false;
      });
      print('🎤 Stopped listening - AI started speaking');
    }
    // Start listening for user interruption
    _startListeningForInterruption();
  }

  void _onTTSComplete() {
    print('🔊 TTS completed');
    _isAISpeaking = false;
    print('🎤 AI finished speaking - can start listening again');
    // Always restart listening after TTS completes in voice mode
    if (_isVoiceMode) {
      _restartListeningAfterDelay();
    }
  }

  void _onTTSError() {
    print('🔊 TTS Error occurred');
    _ttsEnabled = false;
    _isAISpeaking = false;
    setState(() {});
    // Restart listening even if TTS fails
    if (_isVoiceMode) {
      _restartListeningAfterDelay();
    }
  }

  void _initStorage() async {
    try {
      _storagePath = '/data/data/com.example.pocket_lawyer/files/chat_messages.json';
      await _loadMessages();
    } catch (e) {
      print('💾 Error initializing storage: $e');
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    _messages.add(StorageHelper.createWelcomeMessage());
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await StorageHelper.loadMessages(_storagePath);
    if (loadedMessages.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages);
      });
    } else {
      _addWelcomeMessage();
      await _saveMessages();
    }
  }

  Future<void> _saveMessages() async {
    await StorageHelper.saveMessages(_messages, _storagePath);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _listeningCheckTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final messageText = _textController.text.trim();
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    await _saveMessages();
    _scrollToBottom();

    // Send to API
    await _sendToAPI(messageText, 'text');
  }

  void _sendVoiceMessage() async {
    print('🎤 _sendVoiceMessage called with: "$_lastWords"');
    if (_lastWords.isNotEmpty) {
      print('🎤 Sending voice message to API...');
      setState(() {
        _messages.add(ChatMessage(
          text: _lastWords,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _isLoading = true;
      });

      await _saveMessages();
      _scrollToBottom();

      // Send to API
      print('🎤 Calling _sendToAPI with message: "$_lastWords"');
      await _sendToAPI(_lastWords, 'voice');
      _lastWords = '';
    } else {
      print('🎤 _lastWords is empty, not sending to API');
    }
  }

  Future<void> _sendToAPI(String message, String messageType) async {
    try {
      print('🚀 SENDING API REQUEST:');
      print('📤 Payload: {message: "$message", messageType: "$messageType"}');

      final response = await ApiService.sendMessage(
        message: message,
        messageType: messageType,
      );

      print('📥 API RESPONSE:');
      print('✅ Success: ${response['success']}');
      print('💬 Response: ${response['response']}');
      print('🔢 Token Usage: ${response['token_usage']}');
      print('🎵 TTS Info: ${response['tts']}');

      if (response['success'] == true) {
        final aiResponse =
            response['response'] ?? 'Sorry, I could not process your request.';

        setState(() {
          _messages.add(ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
          // Clear the text field when API response is received
          _textController.clear();
        });

        await _saveMessages();
        _scrollToBottom();

        // If voice input, speak the response
        if (messageType == 'voice') {
          print('🔊 Speaking response: $aiResponse');
          if (_ttsEnabled) {
            await TTSHelper.speak(_flutterTts, aiResponse);
          } else {
            // If TTS is not enabled, try to reinitialize it
            print('🔊 TTS not enabled, trying to reinitialize...');
            _ttsEnabled = await TTSHelper.initializeTTS(
              _flutterTts,
              _onTTSStart,
              _onTTSComplete,
              _onTTSError,
            );
            if (_ttsEnabled) {
              await TTSHelper.speak(_flutterTts, aiResponse);
            } else {
              print('🔊 TTS initialization failed, continuing without speech');
            }
          }
        }
      } else {
        throw Exception('API returned error');
      }
    } catch (e) {
      print('❌ API ERROR: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
        // Clear the text field when error response is received
        _textController.clear();
      });
      await _saveMessages();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleInputMode() {
    // If switching from voice to text mode, stop listening immediately
    if (_isVoiceMode && _isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
      });
      print('🎤 Stopped listening - switched to text mode');
    } else {
      setState(() {
        _isVoiceMode = !_isVoiceMode;
      });
    }
  }

  void _toggleListening() async {
    // Don't start listening if AI is speaking
    if (_isAISpeaking) {
      print('🎤 Cannot start listening - AI is currently speaking');
      return;
    }

    // First, stop any ongoing TTS if it's playing
    if (_ttsEnabled) {
      try {
        await _flutterTts.stop();
        print('🔊 Stopped TTS to start listening');
      } catch (e) {
        print('🔊 Error stopping TTS: $e');
      }
    }

    if (!_speechEnabled) {
      // Check and request microphone permission
      final microphonePermission = await Permission.microphone.status;
      if (!microphonePermission.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Microphone permission is required for voice input. Please enable it in settings.'),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }
      }

      // Try to reinitialize speech recognition
      _initSpeech();
      if (!_speechEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Speech recognition not available. Please check microphone permissions.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      // Auto-send the voice message after stopping
      if (_lastWords.isNotEmpty) {
        print('🎤 Voice input captured: "$_lastWords"');
        _sendVoiceMessage();
      }
    } else {
      setState(() {
        _isListening = true;
        _lastWords = '';
        _textController.clear(); // Clear text field when starting
      });

      print('🎤 Starting voice recording...');
      try {
        // Set up a timer to auto-send after 2 seconds of silence
        Timer? silenceTimer;
        Timer? noSpeechTimer;

        // Set a timer to stop listening if no speech is detected for 10 seconds
        noSpeechTimer = Timer(const Duration(seconds: 10), () {
          if (_isListening && _lastWords.isEmpty) {
            print('🎤 No speech detected for 10 seconds - stopping listening');
            _speech.stop();
            setState(() {
              _isListening = false;
            });
          }
        });

              await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            // Don't show text in field during continuous listening
            // Only show when user actually starts speaking
          });
          // print('🎤 Partial result: "$_lastWords"');

          // Cancel no-speech timer since we detected speech
          noSpeechTimer?.cancel();

          // Reset timer on any speech activity
          silenceTimer?.cancel();

          // Set timer for 2 seconds of silence
          if (_lastWords.isNotEmpty) {
            print('🎤 Setting 2-second silence timer for: "$_lastWords"');
            _isWaitingForSilence = true;
            
            // Show text in field when user actually speaks
            setState(() {
              _textController.text = _lastWords;
            });
            
            // Stop AI if it's speaking when user starts talking
            if (_isAISpeaking) {
              print('🎤 User started speaking while AI is talking - stopping AI');
              _flutterTts.stop();
              _isAISpeaking = false;
            }
            
            silenceTimer = Timer(const Duration(seconds: 2), () {
              print('🎤 Silence timer triggered! _isListening: $_isListening, _lastWords: "$_lastWords"');
              if (_lastWords.isNotEmpty) {
                print(
                    '🎤 Auto-sending after 2 seconds of silence: "$_lastWords"');
                setState(() {
                  _isListening = false;
                  _isWaitingForSilence = false;
                });
                _sendVoiceMessage();
              } else {
                print('🎤 Not sending - _lastWords is empty');
                _isWaitingForSilence = false;
              }
            });
          }
        },
          listenFor: const Duration(minutes: 5), // Long listening duration
          pauseFor: const Duration(seconds: 15), // Long pause duration
          partialResults: true,
          localeId: 'en_US',
          listenMode: stt.ListenMode.dictation,
          onSoundLevelChange: (level) {
            // print('🎤 Sound level: $level');
            // Reset timer on any sound activity
            if (level > 0) {
              noSpeechTimer?.cancel(); // Cancel no-speech timer on any sound
              silenceTimer?.cancel();
              _isWaitingForSilence = false;
              
              // Stop AI if it's speaking when user makes sound
              if (_isAISpeaking) {
                print('🎤 User made sound while AI is talking - stopping AI');
                _flutterTts.stop();
                _isAISpeaking = false;
              }
              
              if (_lastWords.isNotEmpty) {
                // Show text in field when user makes sound
                setState(() {
                  _textController.text = _lastWords;
                });
                
                _isWaitingForSilence = true;
                silenceTimer = Timer(const Duration(seconds: 2), () {
                  if (_lastWords.isNotEmpty) {
                    print(
                        '🎤 Auto-sending after 2 seconds of silence: "$_lastWords"');
                    setState(() {
                      _isListening = false;
                      _isWaitingForSilence = false;
                    });
                    _sendVoiceMessage();
                  }
                });
              }
            }
          },
        );
      } catch (e) {
        print('🎤 Speech listening error: $e');
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    // Removed haptic feedback sound
  }

  void _restartListeningAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isVoiceMode && !_isListening && !_isAISpeaking) {
        print('🎤 Restarting listening after AI response...');
        _toggleListening();
      } else {
        print('🎤 Not restarting - _isVoiceMode: $_isVoiceMode, _isListening: $_isListening, _isAISpeaking: $_isAISpeaking');
      }
    });
  }

  void _startListeningForInterruption() {
    // Start listening after a short delay to avoid detecting AI voice
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isVoiceMode && !_isListening && _isAISpeaking) {
        print('🎤 Starting interruption listening...');
        _startInterruptionListening();
      }
    });
  }

  void _startInterruptionListening() async {
    if (!_speechEnabled) return;

    setState(() {
      _isListening = true;
      _lastWords = '';
      _textController.clear();
    });

    print('🎤 Starting interruption voice recording...');
    try {
      // Set up a timer to auto-send after 2 seconds of silence
      Timer? silenceTimer;
      Timer? noSpeechTimer;

      // Set a timer to stop listening if no speech is detected for 10 seconds
      noSpeechTimer = Timer(const Duration(seconds: 10), () {
        if (_isListening && _lastWords.isEmpty) {
          print('🎤 No speech detected for 10 seconds - stopping interruption listening');
          _speech.stop();
          setState(() {
            _isListening = false;
          });
        }
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            // Show text in field when user actually speaks
            _textController.text = _lastWords;
          });
          // print('🎤 Interruption result: "$_lastWords"');

          // Cancel no-speech timer since we detected speech
          noSpeechTimer?.cancel();

          // Reset timer on any speech activity
          silenceTimer?.cancel();

          // Set timer for 2 seconds of silence
          if (_lastWords.isNotEmpty) {
            print('🎤 Setting 2-second silence timer for interruption: "$_lastWords"');
            _isWaitingForSilence = true;
            silenceTimer = Timer(const Duration(seconds: 2), () {
              print('🎤 Interruption silence timer triggered! _isListening: $_isListening, _lastWords: "$_lastWords"');
              if (_lastWords.isNotEmpty) {
                print('🎤 User interrupted AI - stopping TTS and sending message');
                // Stop AI speaking immediately
                _flutterTts.stop();
                _isAISpeaking = false;
                setState(() {
                  _isListening = false;
                  _isWaitingForSilence = false;
                });
                _sendVoiceMessage();
              } else {
                print('🎤 Not sending interruption - _lastWords is empty');
                _isWaitingForSilence = false;
              }
            });
          }
        },
        listenFor: const Duration(minutes: 5), // Long listening duration
        pauseFor: const Duration(seconds: 15), // Long pause duration
        partialResults: true,
        localeId: 'en_US',
        listenMode: stt.ListenMode.dictation,
        onSoundLevelChange: (level) {
          // print('🎤 Interruption sound level: $level');
          // Reset timer on any sound activity
          if (level > 0) {
            noSpeechTimer?.cancel(); // Cancel no-speech timer on any sound
            silenceTimer?.cancel();
            _isWaitingForSilence = false;
            if (_lastWords.isNotEmpty) {
              _isWaitingForSilence = true;
              silenceTimer = Timer(const Duration(seconds: 2), () {
                if (_lastWords.isNotEmpty) {
                  print('🎤 User interrupted AI - stopping TTS and sending message');
                  // Stop AI speaking immediately
                  _flutterTts.stop();
                  _isAISpeaking = false;
                  setState(() {
                    _isListening = false;
                    _isWaitingForSilence = false;
                  });
                  _sendVoiceMessage();
                }
              });
            }
          }
        },
      );
    } catch (e) {
      print('🎤 Interruption speech listening error: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'kanoony',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and Subtitle
               const   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pocket Lawyer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
            const Text(
                          'Your UAE Legal - Powered by Kanoony',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicators
                  // Row(
                  //   children: [
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //       decoration: BoxDecoration(
                  //         color: Colors.green,
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: const Text(
                  //         'Online',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //       decoration: BoxDecoration(
                  //         color: Colors.black,
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: const Text(
                  //         '00:00',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return const LoadingBubble();
                  }
                  final message = _messages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            // Input Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Input Mode Toggle
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _toggleInputMode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isVoiceMode
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard,
                                  size: 16,
                                  color: !_isVoiceMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Text',
                                  style: TextStyle(
                                    color: !_isVoiceMode
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _toggleInputMode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isVoiceMode
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mic,
                                  size: 16,
                                  color: _isVoiceMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
            Text(
                                  'Voice',
                                  style: TextStyle(
                                    color: _isVoiceMode
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Input Field and Send Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: _isVoiceMode
                                  ? 'Voice input mode - click microphone to speak'
                                  : 'Type your message here...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (_isVoiceMode) {
                            if (_isListening) {
                              // Stop listening and put text in field
                              _toggleListening();
                            } else {
                              // Start listening
                              _toggleListening();
                            }
                          } else {
                            // Send text message
                            _sendMessage();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isListening ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      _isListening ? Colors.red : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isVoiceMode
                                      ? (_isListening ? Icons.stop : Icons.mic)
                                      : Icons.send,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  UIHelper.formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

}

class LoadingBubble extends StatefulWidget {
  const LoadingBubble({super.key});

  @override
  State<LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<LoadingBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _animation.value,
                      child: const Text(
                        'AI is thinking',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
