import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/horofy/presentation/screens/chat_screen.dart';
import 'package:horofy/horofy/presentation/screens/login_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_screen.dart';
import 'package:horofy/horofy/presentation/screens/signup_screen.dart';
import 'package:horofy/horofy/presentation/screens/splash_screen.dart';
import 'package:horofy/horofy/presentation/screens/visitor_screen.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signupScreen:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case onboardingScreen:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case visitorScreen:
        return MaterialPageRoute(
          builder: (_) => const VisitorScreen(),
        );

      case chatScreen:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        );

      default:
        return null;
    }
  }
}