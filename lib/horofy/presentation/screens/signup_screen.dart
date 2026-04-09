import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:horofy/horofy/presentation/widgets/custom_toast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscure = true;
  bool _confirmationObscure = true;
  bool _agree = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 100),
              Center(child: Image.asset('assets/images/login.png')),
              const SizedBox(height: 40),
              Text(
                'ﺇنشاء حساب',
                style: AppTextStyles.blackFont.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 40),
              
              // Email field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'عنوان الايميل',
                    hintStyle: AppTextStyles.greyFont,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Password field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.center,
                  obscureText: _obscure,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'الرقم السري',
                    hintStyle: AppTextStyles.greyFont,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    prefixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Confirmation Password field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  textAlign: TextAlign.center,
                  obscureText: _confirmationObscure,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'تأكيد الرقم السري',
                    hintStyle: AppTextStyles.greyFont,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    prefixIcon: IconButton(
                      onPressed: () => setState(
                        () => _confirmationObscure = !_confirmationObscure,
                      ),
                      icon: Icon(
                        _confirmationObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '.أنا أوافق علي كل الشروط والصلاحيات',
                    style: AppTextStyles.blackFont.copyWith(fontSize: 14),
                  ),
                  Checkbox(
                    value: _agree,
                    onChanged: (value) {
                      setState(() {
                        _agree = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Signup button
              CustomButton(
                text: 'ﺇرسال',
                onPressed: () {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _confirmPasswordController.text.isEmpty) {
                    customAppToast(
                      context,
                      'تنبيه',
                      'من فضلك أدخل جميع البيانات',
                      isError: true,
                    );
                    return;
                  }
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    customAppToast(
                      context,
                      'تنبيه',
                      'كلمات المرور غير متطابقة',
                      isError: true,
                    );
                    return;
                  }
                  if (_passwordController.text.length < 8) {
                    customAppToast(
                      context,
                      'تنبيه',
                      'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
                      isError: true,
                    );
                    return;
                  }
                  if (!_agree) {
                    customAppToast(
                      context,
                      'تنبيه',
                      'من فضلك وافق على الشروط والصلاحيات',
                      isError: true,
                    );
                    return;
                  }

                  Navigator.pushReplacementNamed(
                    context,
                    verifyOtpScreen,
                    arguments: {
                      'isFromSignup': true,
                      'email': _emailController.text.trim(),
                      'password': _passwordController.text,
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, loginScreen);
                    },
                    child: Text(
                      'ﺇضغط هنا',
                      style: AppTextStyles.blackFont.copyWith(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'هل لديك حساب بالفعل؟',
                    style: AppTextStyles.blackFont.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
