import 'package:flutter/material.dart';
import 'package:horofy/core/style/font_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? buttonColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonColor ?? Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.blackFont.copyWith(fontSize: 32),
        ),
      ),
    );
  }
}
