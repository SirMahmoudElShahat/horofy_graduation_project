import 'package:flutter/material.dart';
import 'package:horofy/core/style/font_style.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.isMe});

  final String text;
  final bool isMe;

  Alignment get alignment =>
      isMe ? Alignment.centerRight : Alignment.centerLeft;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
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
          border: isMe
              ? Border.all(color: Colors.grey, width: 2)
              : null,
        ),
        child: Text(text, style: AppTextStyles.blackFont),
      ),
    );
  }
}
