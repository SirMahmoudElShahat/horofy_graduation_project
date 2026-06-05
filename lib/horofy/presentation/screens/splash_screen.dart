import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/helper/orientation_helper.dart';
import 'package:horofy/core/services/ml_kit_model_service.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/presentation/screens/login_screen.dart';
import 'package:horofy/horofy/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.1;
  String _status = '...جاري تجهيز التطبيق';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    OrientationHelper.portrait();
    _prepareApp();
  }

  Future<void> _prepareApp() async {
    if (!mounted) return;

    setState(() {
      _progress = 0.1;
      _status = '...جاري إعداد التطبيق';
      _errorMessage = null;
    });

    try {
      await MlKitModelService.instance.ensureReady('ar');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _progress = 0.0;
        _status = '.فشل تحميل النموذج';
        _errorMessage = '.الرجاء التحقق من اتصال الإنترنت ثم حاول مرة أخرى';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _progress = 1.0;
      _status = '...التطبيق جاهز. جاري الانتقال';
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _goNext();
  }

  void _goNext() async {
    final isSeen = await context.read<OnboardingCubit>().isOnboardingSeen();

    if (!mounted) return;

    if (!isSeen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final rememberMe = CacheHelper.getBool('rememberMe');
    final accessToken = CacheHelper.getString('accessToken');

    if (rememberMe && accessToken != null && accessToken.isNotEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        mainHomeScreen,
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_errorMessage == null) ...[
                              Text(
                                _status,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  size: 40,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'عذراً، حدث خطأ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _prepareApp,
                                  child: const Text(
                                    'إعادة المحاولة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
