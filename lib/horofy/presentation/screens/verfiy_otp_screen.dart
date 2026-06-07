import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/auth_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/auth_state.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';
import 'package:horofy/horofy/presentation/widgets/custom_toast.dart';

class VerfiyOtpScreen extends StatefulWidget {
  final bool isFromSignup;
  final String? email;
  final String? password;
  final String? role;
  final String? otp;

  const VerfiyOtpScreen({
    super.key,
    required this.isFromSignup,
    this.email,
    this.password,
    this.role,
    this.otp,
  });

  @override
  State<VerfiyOtpScreen> createState() => _VerfiyOtpScreenState();
}

class _VerfiyOtpScreenState extends State<VerfiyOtpScreen> {
  final int _otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    // Auto-fill OTP if provided (useful for development with devOnlyOtp)
    if (widget.otp != null && widget.otp!.length == _otpLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < _otpLength; i++) {
          _controllers[i].text = widget.otp![i];
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isFilled => _otpCode.length == _otpLength;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);

          if (state is RegisterSuccess) {
            // After successful registration, use the returned OTP to verify automatically
            if (widget.isFromSignup) {
              final serverOtp = state.otp;
              if (widget.email != null) {
                context.read<AuthCubit>().verifyOtp(
                      email: widget.email!,
                      otp: serverOtp,
                    );
              }
            }
          } else if (state is VerifyOtpSuccess) {
            if (widget.isFromSignup) {
              customAppToast(
                context,
                'نجح',
                'تم التسجيل بنجاح',
                isError: false,
              );
              Future.delayed(const Duration(milliseconds: 5), () {
                Navigator.pushReplacementNamed(context, loginScreen);
              });
            }
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
                  'التحقق من الإيميل',
                  style: AppTextStyles.blackFont.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  'تم ارسال الي إيميلك كود مكون من 6 أرقام',
                  style: AppTextStyles.greyFont.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_otpLength, (i) => _buildOtpBox(i)),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'تأكيد',
                  isLoading: _isLoading,
                  onPressed: _isFilled && !_isLoading
                      ? () {
                          if (widget.isFromSignup) {
                            if (widget.email != null && widget.password != null) {
                              // Start Registration process
                              context.read<AuthCubit>().register(
                                    email: widget.email!,
                                    password: widget.password!,
                                  );
                            }
                          } else {
                            // FOR FORGOT PASSWORD: Just navigate to reset screen
                            if (widget.email != null) {
                              Navigator.pushReplacementNamed(
                                context,
                                resetPasswordScreen,
                                arguments: {
                                  'email': widget.email,
                                  'otp': _otpCode,
                                },
                              );
                            }
                          }
                        }
                      : () {},
                  buttonColor: _isFilled && !_isLoading
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isLoading ? null : () => Navigator.pop(context),
                  child: Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: Text(
                      'رجوع',
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

  Widget _buildOtpBox(int index) {
    final filled = _controllers[index].text.isNotEmpty;

    return Container(
      width: 40,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 8)),
        ],
        border: filled ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: AppTextStyles.blackFont.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onChanged(value, index),
      ),
    );
  }
}
