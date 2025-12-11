import 'package:flutter/material.dart';
import 'package:serfix/app/themes/app_colors.dart';

extension ContextExtension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10, left: 14, right: 14),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10, left: 14, right: 14),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          textAlign: TextAlign.left,
        ),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10, left: 14, right: 14),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
