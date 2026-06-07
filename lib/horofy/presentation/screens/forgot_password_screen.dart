import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/auth_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/auth_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:horofy/horofy/presentation/widgets/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);

          if (state is ForgotPasswordSuccess) {
            Navigator.pushReplacementNamed(
              context,
              verifyOtpScreen,
              arguments: {
                'isFromSignup': false,
                'email': _emailController.text.trim(),
                'otp': state.otp,
              },
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
                const SizedBox(height: 100),
                Center(child: Image.asset('assets/images/login.png')),
                const SizedBox(height: 40),
                Text(
                  'نسيت الرقم السري',
                  style: AppTextStyles.blackFont.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 60),
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
                    enabled: !_isLoading,
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
                const SizedBox(height: 70),
                CustomButton(
                  text: 'إرسال',
                  isLoading: _isLoading,
                  onPressed: _isLoading
                      ? () {}
                      : () {
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            customAppToast(
                              context,
                              'تنبيه',
                              'من فضلك أدخل الايميل',
                              isError: true,
                            );
                            return;
                          }
                          context.read<AuthCubit>().forgotPassword(
                                email: email,
                              );
                        },
                  buttonColor: _isLoading
                      ? Colors.grey.shade400
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isLoading ? null : () => Navigator.pop(context),
                  child: Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: Text(
                      'العودة لتسجيل الدخول',
                      style: AppTextStyles.blackFont.copyWith(
                        fontSize: 15,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
