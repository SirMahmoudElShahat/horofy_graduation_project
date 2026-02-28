import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تأكيد تسجيل الخروج',
            style: TextStyle(
              color: Color(0xFF34C759),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'هل أنت متأكد من أنك تريد تسجيل الخروج؟ سيتم إعادة توجيهك إلى صفحة تسجيل الدخول',
            style: TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF8FFE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'تأكيد',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    _showSnackBar(context, 'تم', 'تم تسجيل الخروج بنجاح', isError: false);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(loginScreen, (Route<dynamic> route) => false);
  }

  void _showSnackBar(
    BuildContext context,
    String title,
    String message, {
    bool isError = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
      colorText: Theme.of(context).cardColor,
      icon: Icon(
        isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: Theme.of(context).cardColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Center(child: Image.asset('assets/images/login.png')),
            const SizedBox(height: 100),
            CustomButton(
              text: 'لوحة التحكم',
              onPressed: () {
                // Navigate to Parent Home Screen
              },
              buttonColor: const Color(0xFF34C759),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'التحدث مع شلبى',
              onPressed: () {
                Navigator.pushNamed(context, chatScreen);
              },
              buttonColor: const Color(0xFFBF8FFE),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'قائمة الأطفال',
              onPressed: () {
                Navigator.pushNamed(context, childsListScreen);
              },
              buttonColor: const Color(0xFF64B5F6),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'ٳضافة طفل',
              onPressed: () {
                Navigator.pushNamed(context, childInformationScreen);
              },
              buttonColor: const Color(0xFFFFB74D),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'تسجيل الخروج',
              onPressed: () {
                _showLogoutDialog(context);
              },
              buttonColor: const Color(0xFFE57373),
            ),
          ],
        ),
      ),
    );
  }
}
