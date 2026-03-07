import 'package:flutter/material.dart';
import 'package:horofy/core/style/app_colors.dart';

class ExercisesButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? buttonColor;
  final IconData buttonIcon;

  const ExercisesButton({
    super.key,
    required this.onPressed,
    this.buttonColor,
    required this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primary,
              AppColors.primary.withOpacity(1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            /// اضاءة بيضا فوق اليمين
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 5,
              offset: const Offset(2, -2),
            ),

            /// ظل تحت اليسار
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(-2, 2),
            ),

            /// Glow عام
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            /// نقطة لمعان 1
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            /// نقطة لمعان 2
            Positioned(
              top: 16,
              right: 7,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            /// نقطة لمعان 3
            Positioned(
              bottom: 9,
              left: 9,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            /// الايقونة
            Center(
              child: Icon(
                buttonIcon,
                size: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
