import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/widgets/offline_wrapper.dart';
import 'package:horofy/horofy/presentation/screens/chat_screen.dart';
import 'package:horofy/horofy/presentation/screens/child_home_screen.dart';
import 'package:horofy/horofy/presentation/screens/child_information_screen.dart';
import 'package:horofy/horofy/presentation/screens/child_levels_screen.dart';
import 'package:horofy/horofy/presentation/screens/childs_list_screen.dart';
import 'package:horofy/horofy/presentation/screens/exercises_result_screen.dart';
import 'package:horofy/horofy/presentation/screens/forgot_password_screen.dart';
import 'package:horofy/horofy/presentation/screens/level1_listen_screen.dart';
import 'package:horofy/horofy/presentation/screens/level1_write_screen.dart';
import 'package:horofy/horofy/presentation/screens/level2_screen.dart';
import 'package:horofy/horofy/presentation/screens/level3_screen.dart';
import 'package:horofy/horofy/presentation/screens/level4_screen.dart';
import 'package:horofy/horofy/presentation/screens/level5_screen.dart';
import 'package:horofy/horofy/presentation/screens/level6_screen.dart';
import 'package:horofy/horofy/presentation/screens/level7_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_chat_screen.dart';
import 'package:horofy/horofy/presentation/screens/login_screen.dart';
import 'package:horofy/horofy/presentation/screens/main_home_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_screen.dart';
import 'package:horofy/horofy/presentation/screens/parent_home_screen.dart';
import 'package:horofy/horofy/presentation/screens/reset_password_screen.dart';
import 'package:horofy/horofy/presentation/screens/signup_screen.dart';
import 'package:horofy/horofy/presentation/screens/splash_screen.dart';
import 'package:horofy/horofy/presentation/screens/verfiy_otp_screen.dart';
import 'package:horofy/horofy/presentation/screens/visitor_screen.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const SplashScreen()),
        );

      case loginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const LoginScreen()),
        );

      case forgotPasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ForgotPasswordScreen()),
        );

      case resetPasswordScreen:
        final args = settings.arguments as Map<String, String?>?;
        final email = args?['email'];
        final otp = args?['otp'];
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(
            child: ResetPasswordScreen(otp: otp, email: email),
          ),
        );

      case verifyOtpScreen:
        final args = settings.arguments;
        bool isFromSignup = false;
        String? email;
        String? password;
        String? role;
        String? otp;

        if (args is Map<String, dynamic>) {
          isFromSignup = args['isFromSignup'] ?? false;
          email = args['email'];
          password = args['password'];
          role = args['role'];
          otp = args['otp'];
        } else if (args is bool) {
          isFromSignup = args;
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(
            child: VerfiyOtpScreen(
              isFromSignup: isFromSignup,
              email: email,
              password: password,
              role: role,
              otp: otp,
            ),
          ),
        );

      case signupScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const SignupScreen()),
        );

      case onboardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const OnboardingScreen()),
        );

      case visitorScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const VisitorScreen()),
        );

      case onboardingChatScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const OnboardingChatScreen()),
        );

      case mainHomeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const MainHomeScreen()),
        );

      case parentHomeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ParentHomeScreen()),
        );

      case chatScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ChatScreen()),
        );

      case childInformationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ChildInformationScreen()),
        );

      case childsListScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ChildsListScreen()),
        );

      case childHomeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ChildHomeScreen()),
        );

      case childLevelsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ChildLevelsScreen()),
        );

      case exercisesResultScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const ExercisesResultScreen()),
        );

      case level1ListenScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level1ListenScreen()),
        );

      case level1WriteScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level1WriteScreen()),
        );

      case level2Screen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level2Screen()),
        );

      case level3Screen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level3Screen()),
        );

      case level4Screen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level4Screen()),
        );

      case level5Screen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level5Screen()),
        );

      case level6Screen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level6Screen()),
        );

      case level7Screen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OfflineWrapper(child: const Level7Screen()),
        );

      default:
        return null;
    }
  }
}
