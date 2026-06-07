import 'package:flutter/material.dart';
import 'package:get/get.dart';

void customAppToast(
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
