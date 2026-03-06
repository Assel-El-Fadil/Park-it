import 'package:flutter/material.dart';

class AppColors {
  // Airbnb's iconic "Rausch" red/pink - Primary brand color
  static const Color primary = Color(0xFFFF385C); // Airbnb Pink/Rausch
  static const Color primaryLight = Color(0xFFFF717B); // Lighter variant
  static const Color primaryDark = Color(0xFFE31C5F); // Darker variant
  static const Color primaryContainer = Color(
    0xFFFFE7E9,
  ); // Light pink background

  // Secondary/Earth tones - Warm, welcoming colors
  static const Color secondary = Color(0xFF008489); // Teal/Airbnb Green
  static const Color secondaryLight = Color(0xFF4AA3A7);
  static const Color secondaryDark = Color(0xFF006A70);
  static const Color secondaryContainer = Color(
    0xFFE0F0F1,
  ); // Light teal background

  // Accent/Warmth
  static const Color accent = Color(0xFFFFB400); // Golden yellow for highlights
  static const Color accentLight = Color(0xFFFFC94B);
  static const Color accentDark = Color(0xFFE5A000);

  // ===== BACKGROUND & SURFACE =====
  // Light Theme
  static const Color lightBackground = Color(
    0xFFFFFFFF,
  ); // Pure white background
  static const Color lightSurface = Color(
    0xFFF7F7F7,
  ); // Light gray for cards/surfaces
  static const Color lightSurfaceVariant = Color(
    0xFFEBEBEB,
  ); // Slightly darker gray

  // Dark Theme
  static const Color darkBackground = Color(
    0xFF222222,
  ); // Airbnb dark background
  static const Color darkSurface = Color(0xFF2C2C2C); // Dark surfaces
  static const Color darkSurfaceVariant = Color(
    0xFF383838,
  ); // Variant for contrast

  // ===== TEXT COLORS =====
  // Light Theme Text
  static const Color textPrimaryLight = Color(
    0xFF222222,
  ); // Almost black for primary text
  static const Color textSecondaryLight = Color(
    0xFF717171,
  ); // Medium gray for secondary
  static const Color textTertiaryLight = Color(
    0xFFB0B0B0,
  ); // Light gray for hints/disabled

  // Dark Theme Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White primary text
  static const Color textSecondaryDark = Color(
    0xFFDDDDDD,
  ); // Off-white secondary
  static const Color textTertiaryDark = Color(0xFF9C9C9C); // Gray for tertiary

  // Special Text Colors
  static const Color textLink = Color(
    0xFF008489,
  ); // Teal for links (same as secondary)
  static const Color textPrice = Color(0xFF222222); // Bold price text
  static const Color textRating = Color(0xFF222222); // Rating text

  // ===== STATUS COLORS =====
  static const Color success = Color(0xFF008A05); // Green for success
  static const Color successLight = Color(0xFFE6F2E6);
  static const Color warning = Color(0xFFFFB400); // Yellow/gold for warnings
  static const Color warningLight = Color(0xFFFFF1D6);
  static const Color error = Color(0xFFFF385C); // Using primary red for errors
  static const Color errorLight = Color(0xFFFFE7E9);
  static const Color info = Color(0xFF008489); // Teal for info
  static const Color infoLight = Color(0xFFE0F0F1);

  // ===== UI ELEMENTS =====
  // Borders & Dividers
  static const Color border = Color(0xFFDDDDDD);
  static const Color borderLight = Color(0xFFEBEBEB);
  static const Color divider = Color(0xFFEBEBEB);

  // Shadows
  static const Color shadow = Color(0x1A000000); // 10% opacity black
  static const Color shadowLight = Color(0x0D000000); // 5% opacity black

  // Overlays
  static const Color overlay = Color(0x8A000000); // 54% opacity black
  static const Color overlayLight = Color(0x1A000000); // 10% opacity black

  // Icons
  static const Color iconPrimary = Color(0xFF222222);
  static const Color iconSecondary = Color(0xFF717171);
  static const Color iconAccent = Color(0xFFFF385C);

  // ===== AIRBNB SPECIFIC =====
  // Superhost badge
  static const Color superhost = Color(
    0xFFB31D5C,
  ); // Deep pink/red for superhost

  // Plus badge
  static const Color plus = Color(0xFF914669); // Purple-pink for Airbnb Plus

  // Luxe badge
  static const Color luxe = Color(0xFF8B5A2B); // Gold/brown for Airbnb Luxe

  // Experiences
  static const Color experiences = Color(0xFF6A4E9B); // Purple for experiences

  // Categories
  static const Color categoryArctic = Color(0xFF8AA8B9); // Icons background
  static const Color categoryBeach = Color(0xFFE8C39E);
  static const Color categoryCabins = Color(0xFFB6855B);
  static const Color categoryDesign = Color(0xFFB48B9C);

  // Gradients (start and end colors)
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF008489), Color(0xFF006A70)],
  );

  static const Gradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB400), Color(0xFFFF385C)],
  );
}

// Extension for easy theme access
extension AppColorScheme on ColorScheme {
  // Airbnb custom colors
  Color get primary => AppColors.primary;
  Color get secondary => AppColors.secondary;
  Color get accent => AppColors.accent;
  Color get superhost => AppColors.superhost;
  Color get plus => AppColors.plus;
  Color get luxe => AppColors.luxe;
  Color get experiences => AppColors.experiences;

  // Surface colors based on brightness
  Color get surfaceVariant => brightness == Brightness.light
      ? AppColors.lightSurfaceVariant
      : AppColors.darkSurfaceVariant;

  // Text colors based on brightness
  Color get textPrimary => brightness == Brightness.light
      ? AppColors.textPrimaryLight
      : AppColors.textPrimaryDark;

  Color get textSecondary => brightness == Brightness.light
      ? AppColors.textSecondaryLight
      : AppColors.textSecondaryDark;

  Color get textTertiary => brightness == Brightness.light
      ? AppColors.textTertiaryLight
      : AppColors.textTertiaryDark;

  // Status colors with context
  Color get success => AppColors.success;
  Color get successContainer => AppColors.successLight;
  Color get warning => AppColors.warning;
  Color get warningContainer => AppColors.warningLight;
  Color get error => AppColors.error;
  Color get errorContainer => AppColors.errorLight;
  Color get info => AppColors.info;
  Color get infoContainer => AppColors.infoLight;

  // Borders
  Color get border => AppColors.border;
  Color get borderLight => AppColors.borderLight;
  Color get divider => AppColors.divider;
}

// Theme data extension for easy access
extension AppThemeContext on BuildContext {
  AppColors get colors => AppColors();

  // Helper getters for common colors
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => AppColors.accent;
  Color get superhostColor => AppColors.superhost;
}
