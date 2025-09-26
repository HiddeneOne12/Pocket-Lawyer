import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Background image
            _buildBackgroundImage(),

            // Gradient overlay
            _buildGradientOverlay(),

            // Content
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/welcome.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00000000),
              Color(0xAA000000), // dark overlay
              Color(0xFF000000), // full black bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),

            // Logo + App Name Row
            Row(
              children: [
                GestureDetector(
         //   onTap: () => Navigator.of(context).pop(),
            child: Container(
                 width: 42.5,
                   height: 42.5,
                 decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
              child: Icon(
                Icons.arrow_back_ios,
               color: Colors.black,
                size: 30.h,
              ),
            ),
          ),
                // Container(
                //   width: 42.w,
                //   height: 42.w,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(8.r),
                //   ),
                //   child: Icon(
                //     Icons.arrow_back_ios_new,
                //     size: 20.w,
                //     color: Colors.black,
                //   ),
                // ),
                SizedBox(width: 12.w),
                Text(
                  "Pocket Lawyer",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Heading
            Text(
              "Legal Advice,\nAnytime, Anywhere",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.4,
              ),
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              "Get instant, reliable legal guidance from Pocket Lawyer.",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.85),
                height: 1.5,
              ),
            ),

            SizedBox(height: 30.h),

            // Get Started Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                 onPressed: () {
                   Navigator.of(context).pushReplacement(
                     MaterialPageRoute(
                       builder: (context) => const LoginScreen(),
                     ),
                   );
                 },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
