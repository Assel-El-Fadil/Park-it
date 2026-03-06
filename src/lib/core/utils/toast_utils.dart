import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:src/core/config/themes/color_palette.dart';

class ToastUtils {
  static void showSuccessToast(BuildContext context, String message) {
    _showFlushbar(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: AppColors.successLight,
      iconColor: AppColors.success,
      textColor: AppColors.success,
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    _showFlushbar(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: AppColors.errorLight,
      iconColor: AppColors.error,
      textColor: AppColors.error,
    );
  }

  static void showWarningToast(BuildContext context, String message) {
    _showFlushbar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.warningLight,
      iconColor: AppColors.warning,
      textColor: AppColors.warning,
    );
  }

  static void showInfoToast(BuildContext context, String message) {
    _showFlushbar(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: AppColors.infoLight,
      iconColor: AppColors.info,
      textColor: AppColors.info,
    );
  }

  static void showPrimaryToast(BuildContext context, String message) {
    _showFlushbar(
      context,
      message: message,
      icon: Icons.favorite,
      backgroundColor: AppColors.primaryContainer,
      iconColor: AppColors.primary,
      textColor: AppColors.primary,
    );
  }

  static void showNeutralToast(BuildContext context, String message) {
    _showFlushbar(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: AppColors.lightSurfaceVariant,
      iconColor: AppColors.textSecondaryLight,
      textColor: AppColors.textPrimaryLight,
    );
  }

  static void _showFlushbar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    Duration duration = const Duration(seconds: 3),
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Flushbar(
      message: message,
      icon: Icon(icon, color: iconColor, size: 24),
      duration: duration,
      backgroundColor: isDarkMode
          ? backgroundColor.withValues(alpha: 0.2)
          : backgroundColor,
      messageColor: isDarkMode ? Colors.white : textColor,
      messageSize: 14,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      flushbarPosition: position,
      boxShadows: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],

      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,

      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCirc,
    ).show(context);
  }
}

// Extension for even easier access
extension ToastExtension on BuildContext {
  void showSuccess(String message) =>
      ToastUtils.showSuccessToast(this, message);
  void showError(String message) => ToastUtils.showErrorToast(this, message);
  void showWarning(String message) =>
      ToastUtils.showWarningToast(this, message);
  void showInfo(String message) => ToastUtils.showInfoToast(this, message);
  void showPrimary(String message) =>
      ToastUtils.showPrimaryToast(this, message);
  void showNeutral(String message) =>
      ToastUtils.showNeutralToast(this, message);
}

// Alternative: Using an enum for more type-safe toasts
enum ToastType { success, error, warning, info, primary, neutral }

class ToastUtilsTyped {
  static void showToast(BuildContext context, String message, ToastType type) {
    switch (type) {
      case ToastType.success:
        ToastUtils.showSuccessToast(context, message);
        break;
      case ToastType.error:
        ToastUtils.showErrorToast(context, message);
        break;
      case ToastType.warning:
        ToastUtils.showWarningToast(context, message);
        break;
      case ToastType.info:
        ToastUtils.showInfoToast(context, message);
        break;
      case ToastType.primary:
        ToastUtils.showPrimaryToast(context, message);
        break;
      case ToastType.neutral:
        ToastUtils.showNeutralToast(context, message);
        break;
    }
  }
}
