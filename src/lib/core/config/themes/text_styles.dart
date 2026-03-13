import 'package:flutter/material.dart';
import 'color_palette.dart';

class AppTextStyles {
  static const displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  static const displayMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  static const displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  // ===== HEADLINE STYLES =====
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );

  // ===== TITLE STYLES =====
  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  static const titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  // ===== BODY STYLES =====
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.textSecondaryLight,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.3,
    height: 1.5,
    color: AppColors.textTertiaryLight,
  );

  // ===== LABEL STYLES =====
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
    color: AppColors.textSecondaryLight,
  );

  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.textTertiaryLight,
  );

  // ===== AIRBNB SPECIFIC STYLES =====
  static const priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrice,
  );

  static const priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrice,
  );

  static const priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrice,
  );

  static const rating = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textRating,
  );

  static const superhost = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.superhost,
  );

  static const category = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryLight,
  );

  // ===== BUTTON STYLES =====
  static const buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const buttonOutline = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  // ===== CAPTION / OVERLINE =====
  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.2,
    color: AppColors.textSecondaryLight,
  );
}

// Extension for easy access with context
extension TextStylesContext on BuildContext {
  AppTextStyles get textStyles => AppTextStyles();

  // Common text style combinations
  TextStyle get priceStyle => AppTextStyles.priceMedium;
  TextStyle get ratingStyle => AppTextStyles.rating;
  TextStyle get superhostStyle => AppTextStyles.superhost;
}
