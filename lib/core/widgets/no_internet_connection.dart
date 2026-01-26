import 'package:flutter/material.dart';
import 'package:horofy/core/style/font_style.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Can\'t connect .. check internet',
              style: AppTextStyles.blackFont.copyWith(fontSize: 25),
            ),
            SizedBox(height: 50),
            Image.asset('assets/images/no_internet.png'),
          ],
        ),
      ),
    );
  }
}
