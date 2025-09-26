import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Voice microphone widget with circular design
class VoiceMicrophoneWidget extends StatelessWidget {
  final bool isListening;
  final Animation<double> pulseAnimation;
  final Animation<double> waveAnimation;
  final VoidCallback onTap;

  const VoiceMicrophoneWidget({
    super.key,
    required this.isListening,
    required this.pulseAnimation,
    required this.waveAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulseAnimation, waveAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer wave circles
              if (isListening) ...[
                _buildWaveCircle(0.8, 0.3),
                _buildWaveCircle(0.6, 0.5),
                _buildWaveCircle(0.4, 0.7),
              ],
              
              // Main microphone circle
              Transform.scale(
                scale: isListening ? pulseAnimation.value : 1.0,
                child: Container(
                  width: 198.w,
                  height: 198.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF140D11),
                        Color(0xFF140D11),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF140D11).withOpacity(0.3),
                        blurRadius: 20.r,
                        spreadRadius: 5.r,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inner circle
                      Center(
                        child: Container(
                          width: 96.w,
                          height: 96.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF140D11),
                          ),
                        ),
                      ),
                      
                      // Microphone icon
                      Center(
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          size: 38.w,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWaveCircle(double scale, double opacity) {
    return Transform.scale(
      scale: scale + (waveAnimation.value * 0.2),
      child: Container(
        width: 198.w,
        height: 198.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF140D11).withOpacity(opacity),
            width: 1.w,
          ),
        ),
      ),
    );
  }
}
