import 'package:flutter/material.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/widgets/custom_button.dart';

class VerfiyOtpScreen extends StatefulWidget {
  final bool isFromSignup;

  const VerfiyOtpScreen({super.key, required this.isFromSignup});

  @override
  State<VerfiyOtpScreen> createState() => _VerfiyOtpScreenState();
}

class _VerfiyOtpScreenState extends State<VerfiyOtpScreen> {
  final int _otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
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
                onPressed: _isFilled
                    ? () {
                        if (widget.isFromSignup) {
                          Navigator.pushReplacementNamed(context, visitorScreen);
                        } else {
                          Navigator.pushReplacementNamed(context, resetPasswordScreen);
                        }
                      }
                    : () {},
                buttonColor: _isFilled
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
            ],
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