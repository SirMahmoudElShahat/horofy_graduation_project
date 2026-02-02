import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) async {
        if (state is OnboardingSeen) {
          Navigator.pushNamed(context, visitorScreen);
        }
        if (state is OnboardingNotSeen) {
          Navigator.pushNamed(context, onboardingScreen);
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            //Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/main_home.jpg',
                fit: BoxFit.cover,
              ),
            ),

            //Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Center(child: Image.asset('assets/images/login.jpg')),
                  SizedBox(height: 10),
                  Text(
                    'تسجيل الدخول كـ',
                    style: AppTextStyles.blackFont.copyWith(fontSize: 24),
                  ),
                  SizedBox(height: 50),
                  CustomButton(
                    text: 'ولى أمر',
                    onPressed: () {
                      Navigator.pushNamed(context, parentHomeScreen);
                    },
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'محمود',
                    onPressed: () {
                      // Navigate to Child Home Screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
