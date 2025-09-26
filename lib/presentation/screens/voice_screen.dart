import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_lawyer/presentation/widgets/chat_header.dart';
import 'package:pocket_lawyer/presentation/widgets/side_drawer.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10.h,
            ),
            // ---------------- Header ----------------

            // Back button
            const ChatHeader(),

            // ---------------- Sphere animation ----------------
            Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.black54, Colors.black87],
                    center: Alignment(-0.3, -0.3),
                    radius: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ---------------- Microphone + controls ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left: speaker button
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(Icons.volume_up,
                      color: Colors.white, size: 24),
                ),
                SizedBox(width: 40.w),

                // Middle: microphone with pulse
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child:
                          const Icon(Icons.mic, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                SizedBox(width: 40.w),

                // Right: close button
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ],
            ),

            const Spacer(),

            // ---------------- Text / Voice Toggle ----------------
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Text",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Voice button
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "Voice",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
