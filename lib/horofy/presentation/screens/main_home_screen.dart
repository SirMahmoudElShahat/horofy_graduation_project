import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChildCubit>().loadChildren();
  }

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
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Center(child: Image.asset('assets/images/login.png')),
                const SizedBox(height: 80),
                Text(
                  'تسجيل الدخول كـ',
                  style: AppTextStyles.blackFont.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 50),
                CustomButton(
                  text: 'ولى أمر',
                  onPressed: () {
                    Navigator.pushNamed(context, parentHomeScreen);
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<ChildCubit, ChildState>(
                  builder: (context, state) {
                    if (state is ChildLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChildLoaded) {
                      if (state.children.isEmpty) {
                        return Text(
                          'لا يوجد أطفال مضافين',
                          style: AppTextStyles.greyFont,
                        );
                      }
                      return Column(
                        children: state.children.map((child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: CustomButton(
                              text: child.name,
                              onPressed: () {
                                // Navigate to Child Home Screen
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
