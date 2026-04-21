import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/levels.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/domain/entities/child_entity.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  /// Show child selector bottom sheet
  void _showChildSelector(BuildContext context, List<ChildEntity> children) {
    if (children.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'لا توجد أطفال',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'يجب أن تضيف طفل أولاً',
            style: TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF8FFE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, childInformationScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'إضافة طفل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر الطفل',
                  style: AppTextStyles.blackFont.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (_, i) {
                    final child = children[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        Navigator.pop(context);
                
                        final token = CacheHelper.getString('accessToken');
                        final childId = child.id;
                
                        if (token == null || token.isEmpty) {
                          print("No token found");
                          return;
                        }
                
                        final url =
                            'https://dyslexia-desgraphia.netlify.app/?childId=$childId&token=$token';
                
                        await openUrl(url);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    child.name,
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.blackFont.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    levelEnToArabic(child.level),
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.greyFont.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(child.avatar),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Open a URL in the default browser
  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  /// Show logout confirmation dialog
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

  /// Perform logout by clearing cached data and navigating to login screen
  void _logout(BuildContext context) async {
    // مسح البيانات المحفوظة
    await CacheHelper.saveData('rememberMe', false);
    await CacheHelper.removeData('accessToken');
    await CacheHelper.removeData('userId');

    _showSnackBar(context, 'تم', 'تم تسجيل الخروج بنجاح', isError: false);

    // مسح الاستاك كله والذهاب لشاشة تسجيل الدخول
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(loginScreen, (Route<dynamic> route) => false);
  }

  /// Show a snackbar with customizable title, message, and error state
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
            // Parent Dashboard Button
            BlocBuilder<ChildCubit, ChildState>(
              builder: (context, state) {
                final children = state is ChildLoaded
                    ? state.children
                    : <ChildEntity>[];
                return CustomButton(
                  text: 'لوحة التحكم',
                  onPressed: () => _showChildSelector(context, children),
                  buttonColor: const Color(0xFF34C759),
                );
              },
            ),
            const SizedBox(height: 30),
            // Chat with Shelpy Button
            CustomButton(
              text: 'التحدث مع شلبى',
              onPressed: () {
                Navigator.pushNamed(context, conversationsListScreen);
              },
              buttonColor: const Color(0xFFBF8FFE),
            ),
            const SizedBox(height: 30),
            // Child List Button
            CustomButton(
              text: 'قائمة الأطفال',
              onPressed: () {
                Navigator.pushNamed(context, childsListScreen);
              },
              buttonColor: const Color(0xFF64B5F6),
            ),
            const SizedBox(height: 30),
            // Add Child Button
            CustomButton(
              text: 'ٳضافة طفل',
              onPressed: () {
                Navigator.pushNamed(context, childInformationScreen);
              },
              buttonColor: const Color(0xFFFFB74D),
            ),
            const SizedBox(height: 30),
            // logout button
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
