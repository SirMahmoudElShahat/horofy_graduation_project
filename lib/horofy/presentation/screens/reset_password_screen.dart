import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/auth_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/auth_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:horofy/horofy/presentation/widgets/custom_toast.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? otp;
  final String? email;
  const ResetPasswordScreen({super.key, this.otp, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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

          if (state is ResetPasswordSuccess) {
            customAppToast(
              context,
              'نجح',
              'تم تغيير كلمة المرور بنجاح',
              isError: false,
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                loginScreen,
                (route) => false,
              );
            });
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
                  'إعادة تعيين الرقم السري',
                  style: AppTextStyles.blackFont.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  'أدخل الرقم السري الجديد وتأكيده',
                  style: AppTextStyles.greyFont.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

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
                    enabled: !_isLoading,
                    textAlign: TextAlign.center,
                    obscureText: _obscurePassword,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'الرقم السري الجديد',
                      hintStyle: AppTextStyles.greyFont,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 48),
                      prefixIcon: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Confirm Password field
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
                    controller: _confirmController,
                    enabled: !_isLoading,
                    textAlign: TextAlign.center,
                    obscureText: _obscureConfirm,
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
                        onPressed: _isLoading
                            ? null
                            : () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                CustomButton(
                  text: 'تأكيد',
                  isLoading: _isLoading,
                  onPressed: _isLoading
                      ? () {}
                      : () {
                          if (_passwordController.text.isEmpty ||
                              _confirmController.text.isEmpty) {
                            customAppToast(
                              context,
                              'تنبيه',
                              'من فضلك أدخل كلمة المرور',
                              isError: true,
                            );
                            return;
                          }
                          if (_passwordController.text !=
                              _confirmController.text) {
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
                          context.read<AuthCubit>().resetPassword(
                            email: widget.email ?? '',
                            otp: widget.otp ?? '',
                            newPassword: _passwordController.text,
                          );
                        },
                  buttonColor: _isLoading
                      ? Colors.grey.shade400
                      : Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
