import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/voice_screen.dart';

/// Chat input widget with text/voice toggle and send button
class ChatInput extends StatelessWidget {
  final TextEditingController textController;
  final bool isVoiceMode;
  final bool isListening;
  final Animation<double> pulseAnimation;
  final VoidCallback onToggleInputMode;
  final VoidCallback onToggleListening;
  final VoidCallback onSendMessage;

  const ChatInput({
    super.key,
    required this.textController,
    required this.isVoiceMode,
    required this.isListening,
    required this.pulseAnimation,
    required this.onToggleInputMode,
    required this.onToggleListening,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Input Mode Toggle
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onToggleInputMode,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: !isVoiceMode
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard,
                          size: 16.w,
                          color: !isVoiceMode
                              ? Colors.black
                              : Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Text',
                          style: TextStyle(
                            color: !isVoiceMode
                                ? Colors.black
                                : Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VoiceScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isVoiceMode
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic,
                          size: 16.w,
                          color: isVoiceMode
                              ? Colors.black
                              : Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Voice',
                          style: TextStyle(
                            color: isVoiceMode
                                ? Colors.black
                                : Colors.white,
                            fontSize: 12.sp,
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
          SizedBox(height: 12.h),
          // Input Field and Send Button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: isVoiceMode
                          ? 'Voice input mode - click microphone to speak'
                          : 'Type your message here...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => onSendMessage(),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  if (isVoiceMode) {
                    onToggleListening();
                  } else {
                    onSendMessage();
                  }
                },
                child: AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isListening ? pulseAnimation.value : 1.0,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: isListening ? Colors.red : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isVoiceMode
                              ? (isListening ? Icons.stop : Icons.mic)
                              : Icons.send,
                          color: Colors.white,
                          size: 24.w,
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
    );
  }
}
