import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Side drawer widget for the chat screen
/// Based on the Figma design with pixel-perfect implementation
class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330.w,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar area
          SizedBox(height: 36.h),

          // Header with logo
          _buildHeader(),

          // Divider line
          Container(
            height: 1.h,
            color: Colors.black.withOpacity(0.1),
            margin: EdgeInsets.symmetric(vertical: 20.h),
          ),

          // Menu items
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 25.h),
      child: Image.asset(
        'assets/logo.png',
        height: 47.h,
        width: 150.h,
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Column(
        children: [
          _buildMenuItem(
            'Privacy Policy',
            () {
              // Handle privacy policy
              Navigator.pop(context);
            },
          ),

          SizedBox(height: 20.h),

          // Divider
          Container(
            height: 1.h,
            color: Colors.black.withOpacity(0.1),
          ),

          SizedBox(height: 20.h),

          _buildMenuItem(
            'Terms & Conditions',
            () {
              // Handle terms & conditions
              Navigator.pop(context);
            },
          ),

          SizedBox(height: 20.h),

          // Divider
          Container(
            height: 1.h,
            color: Colors.black.withOpacity(0.1),
          ),

          SizedBox(height: 20.h),

          _buildMenuItem(
            'Logout',
            () {
              // Handle logout
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF140D11),
            letterSpacing: 0.32,
          ),
        ),
      ),
    );
  }
}
