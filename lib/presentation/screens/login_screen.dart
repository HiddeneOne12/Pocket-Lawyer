import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),

                // Logo and Title
                _buildHeader(),

                SizedBox(height: 40.h),

                // Form fields
                _buildForm(),

                SizedBox(height: 15.h),

                // Forgot Password
                _buildForgotPassword(),

                SizedBox(height: 60.h),

                // Sign In Button
                _buildSignInButton(),

                SizedBox(height: 40.h),

                // Social Login
              
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Row
        Image.asset("assets/logo.png",height: 47.h,width: 190.h,fit: BoxFit.cover,),
        SizedBox(height: 45.h),
        Text(
          "Pocket Lawyer",
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 26.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF202020),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Let’s dive into your account!",
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF696969),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField("Email", "stanley.cohen@gmail.com",
            controller: _emailController, obscure: false),
        SizedBox(height: 20.h),
        _buildTextField("Password", "Enter your password",
            controller: _passwordController, obscure: true),
      ],
    );
  }

  Widget _buildTextField(String label, String hint,
      {required TextEditingController controller, required bool obscure}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF202020),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFDEDEDE), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure ? _obscurePassword : false,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF202020),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFB0B0B0),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              suffixIcon: obscure
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF929292),
                        size: 22.w,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF202020),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChatScreen(category: 'General')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF140D11),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "Sign In",
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                "or sign in with",
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF696969),
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon("assets/google.png"),
            SizedBox(width: 20.w),
            _buildSocialIcon("assets/facebook.png"),
            SizedBox(width: 20.w),
            _buildSocialIcon("assets/apple.png"),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String asset) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(asset, width: 22.w, height: 22.w),
      ),
    );
  }
}
