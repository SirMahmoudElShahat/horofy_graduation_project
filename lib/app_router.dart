import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/widgets/offline_wrapper.dart';
import 'package:horofy/horofy/presentation/screens/chat_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_chat_screen.dart';
import 'package:horofy/horofy/presentation/screens/login_screen.dart';
import 'package:horofy/horofy/presentation/screens/main_home_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_screen.dart';
import 'package:horofy/horofy/presentation/screens/parent_home_screen.dart';
import 'package:horofy/horofy/presentation/screens/signup_screen.dart';
import 'package:horofy/horofy/presentation/screens/splash_screen.dart';
import 'package:horofy/horofy/presentation/screens/visitor_screen.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const SplashScreen()),
        );

      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const LoginScreen()),
        );

      case signupScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const SignupScreen()),
        );

      case onboardingScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const OnboardingScreen()),
        );

      case visitorScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const VisitorScreen()),
        );

      case onboardingChatScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const OnboardingChatScreen()),
        );

      case mainHomeScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const MainHomeScreen()),
        );

      case parentHomeScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const ParentHomeScreen()),
        );
      
      case chatScreen:
        return MaterialPageRoute(
          builder: (_) => OfflineWrapper(child: const ChatScreen()),
        );

      default:
        return null;
    }
  }
}
