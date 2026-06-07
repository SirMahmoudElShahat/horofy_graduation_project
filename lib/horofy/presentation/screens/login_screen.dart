import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:horofy/horofy/presentation/cubit/auth_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/auth_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _remember = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveLoginData(String userId, String token) {
    CacheHelper.saveData('rememberMe', true);
    CacheHelper.saveData('accessToken', token);
    CacheHelper.saveData('userId', userId);
  }

  void _clearLoginData() {
    CacheHelper.saveData('rememberMe', false);
    CacheHelper.removeData('accessToken');
    CacheHelper.removeData('userId');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);

          if (state is LoginSuccess) {
            // Always save token for current session use
            CacheHelper.saveData('accessToken', state.user.token ?? '');
            CacheHelper.saveData('userId', state.user.id);

            if (_remember) {
              // Also persist rememberMe flag for next launch
              CacheHelper.saveData('rememberMe', true);
            } else {
              // Clear rememberMe so next launch goes to login
              CacheHelper.saveData('rememberMe', false);
            }

            Navigator.pushNamedAndRemoveUntil(
              context,
              mainHomeScreen,
              (route) => false,
            );
            
          } else if (state is AuthError) {
            customAppToast(context, 'خطأ', state.message, isError: true);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                // Login image
                Center(child: Image.asset('assets/images/login.png')),
                SizedBox(height: 40),
                //header text
                Text(
                  'تسجيل الدخول',
                  style: AppTextStyles.blackFont.copyWith(fontSize: 24),
                ),
                SizedBox(height: 40),
                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
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
                    controller: _emailController,
                    enabled: !_isLoading,
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
                    color: AppColors.background,
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
                    controller: _passwordController,
                    enabled: !_isLoading,
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
                        onPressed: _isLoading
                            ? null
                            : () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                // Remember me and forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _remember,
                          onChanged: _isLoading
                              ? null
                              : (value) {
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
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                forgotPasswordScreen,
                              );
                            },
                      child: Opacity(
                        opacity: _isLoading ? 0.5 : 1.0,
                        child: Text(
                          'هل نسيت الرقم السري؟',
                          style: AppTextStyles.blackFont.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                // Login button
                CustomButton(
                  text: 'ابدأ',
                  isLoading: _isLoading,
                  onPressed: () {
                    if (_emailController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      customAppToast(
                        context,
                        'تنبيه',
                        'الرجاء ملء جميع الحقول',
                        isError: true,
                      );
                      return;
                    }
                    context.read<AuthCubit>().login(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  },
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(
                                context,
                                signupScreen,
                              );
                            },
                      child: Opacity(
                        opacity: _isLoading ? 0.5 : 1.0,
                        child: Text(
                          'ﺇضغط هنا',
                          style: AppTextStyles.blackFont.copyWith(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'حساب جديد؟',
                      style: AppTextStyles.blackFont.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
