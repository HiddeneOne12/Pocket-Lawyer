import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

/// Main entry point of the Pocket Lawyer application
void main() {
  runApp(const PocketLawyerApp());
}

/// Root application widget
class PocketLawyerApp extends StatelessWidget {
  const PocketLawyerApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Pocket Lawyer AI',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppThemes.primaryBlue),
            useMaterial3: true,
            fontFamily: AppThemes.fontFamily,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}