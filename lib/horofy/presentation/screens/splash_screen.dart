import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/presentation/screens/login_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool> _isOnboardingSeen;

  @override
  void initState() {
    super.initState();
    _isOnboardingSeen = Future.value(
      context.read<OnboardingCubit>().isOnboardingSeen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingSeen,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking, show a loading or just the splash
          return AnimatedSplashScreen(
            splashIconSize: double.infinity,
            duration: 4000,
            splash: SizedBox.expand(
              child: Image.asset('assets/images/splash.gif', fit: BoxFit.fill),
            ),
            nextScreen: Container(), // Placeholder
          );
        } else {
          final isSeen = snapshot.data ?? false;
          final nextScreen = isSeen
              ? const LoginScreen()
              : const OnboardingScreen();

          return AnimatedSplashScreen(
            splashIconSize: double.infinity,
            duration: 4000,
            splash: SizedBox.expand(
              child: Image.asset('assets/images/splash.gif', fit: BoxFit.fill),
            ),
            nextScreen: nextScreen,
          );
        }
      },
    );
  }
}
