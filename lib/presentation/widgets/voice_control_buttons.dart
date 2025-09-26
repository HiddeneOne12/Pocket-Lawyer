import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Voice control buttons widget
class VoiceControlButtons extends StatelessWidget {
  final bool isListening;
  final bool hasText;
  final VoidCallback onStop;
  final VoidCallback onClear;

  const VoiceControlButtons({
    super.key,
    required this.isListening,
    required this.hasText,
    required this.onStop,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Stop button
        if (isListening)
          _buildControlButton(
            icon: Icons.stop,
            onTap: onStop,
            backgroundColor: const Color(0xFF140D11),
          ),
        
        // Clear button
        if (hasText)
          _buildControlButton(
            icon: Icons.clear,
            onTap: onClear,
            backgroundColor: const Color(0xFF140D11),
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );
  }
}
