import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/helper/orientation_helper.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<String> images = [
    'assets/images/onboarding1.jpg',
    'assets/images/onboarding2.jpg',
    'assets/images/onboarding3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    OrientationHelper.portrait();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            reverse: false,
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots indicators
                Row(
                  textDirection: TextDirection.ltr,
                  children: List.generate(images.length, (i) {
                    final bool active = i == currentIndex;
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: active ? 14 : 10,
                        height: active ? 14 : 10,
                        decoration: BoxDecoration(
                          color: active
                              ? Theme.of(context).primaryColor
                              : Colors.white.withOpacity(0.7),
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }),
                ),

                // Next or Finish button
                currentIndex == images.length - 1
                    ? ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<OnboardingCubit>()
                              .completeOnboarding();
                          Navigator.pushNamed(context, signupScreen);
                          //Navigator.pushNamed(context, visitorScreen);
                          //await context.read<OnboardingCubit>().completeOnboarding();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(110, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'كمّل',
                          style: AppTextStyles.blackFont.copyWith(fontSize: 16),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.95),
                          minimumSize: const Size(90, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          'التالي',
                          style: AppTextStyles.blackFont.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
