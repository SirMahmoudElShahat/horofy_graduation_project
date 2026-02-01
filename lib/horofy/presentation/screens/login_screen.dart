import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Center(child: Image.asset('assets/images/login.jpg')),
              SizedBox(height: 40),
              Text(
                'تسجيل الدخول',
                style: AppTextStyles.blackFont.copyWith(fontSize: 24),
              ),
              SizedBox(height: 40),
              // Email field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'عنوان الايميل',
                    hintStyle: AppTextStyles.greyFont,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    prefixIcon: SizedBox(width: 48),
                  ),
                ),
              ),
              SizedBox(height: 25),
              // Password field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  obscureText: _obscure,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'الرقم السري',
                    hintStyle: AppTextStyles.greyFont,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 48),
                    prefixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _remember,
                        onChanged: (value) {
                          setState(() {
                            _remember = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'تذكرني',
                        style: AppTextStyles.blackFont.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    'هل نسيت الرقم السري؟',
                    style: AppTextStyles.blackFont.copyWith(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 25),
              CustomButton(
                text: 'ابدأ',
                onPressed: () {
                  Navigator.pushNamed(context, mainHomeScreen);
                },
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, signupScreen);
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
                    'حساب جديد؟',
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
