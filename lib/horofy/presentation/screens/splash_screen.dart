import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/font_style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: double.infinity,
      duration: 4000,
      splash: SizedBox.expand(
        child: Image.asset('assets/images/splash.gif', fit: BoxFit.fill),
      ),
      nextScreen: NextScreen(),
    );
  }
}

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 300,
              left: 139,
              child: Text('تسجيل دخول', style: AppTextStyles.home),
            ),
            Positioned(
              top: 370,
              left: 170,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, loginScreen);
                },
                child: Text('طفل', style: AppTextStyles.home),
              ),
            ),
            Positioned(
              top: 420,
              left: 160,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, loginScreen);
                },
                child: Text('ولي الأمر', style: AppTextStyles.home),
              ),
            ),
            Positioned(
              top: 475,
              left: 180,
              child: GestureDetector(
                onTap: () {
                  //on boarding screen
                },
                child: Text('زائر', style: AppTextStyles.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
