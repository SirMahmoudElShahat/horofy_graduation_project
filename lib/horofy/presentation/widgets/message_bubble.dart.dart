import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/horofy/presentation/cubit/onboarding_cubit.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.hasButton,
  });

  final String text;
  final bool isMe;
  final bool hasButton;

  Alignment get alignment =>
      isMe ? Alignment.centerRight : Alignment.centerLeft;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.white : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              border: isMe ? Border.all(color: Colors.grey, width: 2) : null,
            ),
            child: Text(text, style: AppTextStyles.blackFont),
          ),

          if (hasButton)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<OnboardingCubit>().completeOnboarding();
                  Navigator.pushNamed(context, loginScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "ابدأ التطبيق",
                  style: AppTextStyles.whiteFont,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
