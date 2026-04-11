import 'package:flutter/material.dart';
import 'package:horofy/core/style/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  // Optional size — defaults work for most screens
  final double size;
  final bool fullScreen;

  const LoadingWidget({
    super.key,
    this.size = 180,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final gif = Image.asset(
      'assets/images/Sandy Loading.gif',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: gif),
      );
    }

    return Center(child: gif);
  }
}