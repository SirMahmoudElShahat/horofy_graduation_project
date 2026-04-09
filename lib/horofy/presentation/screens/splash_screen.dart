import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/helper/orientation_helper.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/presentation/screens/login_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    OrientationHelper.portrait();
    _goNext();
  }

  void _goNext() async {
    final isSeen = await context.read<OnboardingCubit>().isOnboardingSeen();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (!isSeen) {
      // أول مرة فتح التطبيق → Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // تحقق من بيانات تسجيل الدخول المحفوظة
      final rememberMe = CacheHelper.getBool('rememberMe');
      final accessToken = CacheHelper.getString('accessToken');

      if (rememberMe && accessToken != null && accessToken.isNotEmpty) {
        // بيانات موجودة → اذهب للشاشة الرئيسية
        Navigator.pushNamedAndRemoveUntil(
          context,
          mainHomeScreen,
          (route) => false,
        );
      } else {
        // لا توجد بيانات → اذهب لتسجيل الدخول
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: SizedBox.expand(
        child: Image.asset('assets/images/splash.jpg', fit: BoxFit.cover),
      ),
    );
  }
}
