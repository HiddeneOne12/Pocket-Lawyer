import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/side_drawer.dart';
import '../controllers/chat_controller.dart';

/// Chat screen for legal assistance conversations
class ChatScreen extends StatefulWidget {
  final String category;

  const ChatScreen({
    super.key,
    required this.category,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ChatController _chatController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _chatController = ChatController();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _chatController.initialize();
    _chatController.addListener(_onChatStateChanged);
  }

  void _onChatStateChanged() {
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _chatController.removeListener(_onChatStateChanged);
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final messageText = _textController.text.trim();
    if (messageText.isNotEmpty) {
      _textController.clear();
      await _chatController.sendMessage(messageText);
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
    _chatController.toggleInputMode();
  }

  void _toggleListening() async {
    try {
      await _chatController.toggleListening();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo
            const ChatHeader(),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _chatController.messages.length +
                    (_chatController.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _chatController.messages.length &&
                      _chatController.isLoading) {
                    return const LoadingBubble();
                  }
                  final message = _chatController.messages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),

            // Input Section
            ChatInput(
              textController: _textController,
              isVoiceMode: _chatController.isVoiceMode,
              isListening: _chatController.isListening,
              pulseAnimation: _pulseAnimation,
              onToggleInputMode: _toggleInputMode,
              onToggleListening: _toggleListening,
              onSendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
