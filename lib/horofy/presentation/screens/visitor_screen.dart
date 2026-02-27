import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class VisitorScreen extends StatelessWidget {
  const VisitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Center(child: Image.asset('assets/images/visitor_screen_image.png')),
              SizedBox(height: 20),
              CustomButton(
                text: 'التحدث مع شلبى',
                onPressed: () {
                  Navigator.pushNamed(context, onboardingChatScreen);
                },
              ),
              SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "عند الضغط سوف تنتقل الى التحدث مع شلبى الذكى لتقييم حالة طفلك بكل سهولة وذكاء",
                  style: AppTextStyles.greyFont.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
