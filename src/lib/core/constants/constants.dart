import 'package:flutter/material.dart';

enum ThemeMode {
  /// Always use the light mode regardless of device platform
  light,

  /// Always use the dark mode regardless of device platform
  dark,

  /// Follow the device's platform mode (light/dark based on system settings)
  system,
}

class AppConstants {
  // ===== App Metadata =====
  static const String appName = 'Park-it';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Parking Space Sharing App';
  static const String companyName = 'Your Company';
  static const String supportEmail = 'support@parkshare.com';
  static const String websiteUrl = '';
  static const String privacyPolicyUrl = '';
  static const String termsOfServiceUrl = '';

  // ===== API & Supabase =====
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // ===== Storage Keys =====
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUserEmail = 'user_email';
  static const String prefKeyUserName = 'user_name';
  static const String prefKeyIsLoggedIn = 'is_logged_in';
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLanguage = 'language';
  static const String prefKeyHasSeenOnboarding = 'has_seen_onboarding';

  // ===== Hive Box Names =====
  static const String hiveBoxSession = 'app_session';
  static const String hiveBoxSettings = 'app_settings';
  static const String hiveBoxOfflineQueue = 'offline_queue';
  static const String hiveBoxSearchHistory = 'search_history';
  static const String hiveBoxLocations = 'recent_locations';
  static const String hiveBoxSyncStatus = 'sync_status';
  static const String hiveBoxDeleteQueue = 'delete_queue';

  // ===== Animation Durations =====
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration debounceDuration = Duration(milliseconds: 500);
  static const Duration throttleDuration = Duration(milliseconds: 300);

  // ===== Pagination =====
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int searchHistoryLimit = 20;
  static const int recentLocationsLimit = 10;

  // ===== Map Constants =====
  static const double defaultMapLatitude = 40.7128; // New York
  static const double defaultMapLongitude = -74.0060;
  static const double defaultMapZoom = 14.0;
  static const double searchRadiusKm = 5.0;
  static const double maxSearchRadiusKm = 50.0;

  // ===== Validation =====
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxReviewLength = 1000;
  static const int phoneNumberLength = 10;

  // ===== Price Constants =====
  static const double minPricePerHour = 1.0;
  static const double maxPricePerHour = 100.0;
  static const double minPricePerDay = 5.0;
  static const double maxPricePerDay = 500.0;
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
  ];

  // ===== Distance Units =====
  static const String distanceUnitKm = 'km';
  static const String distanceUnitMi = 'mi';
  static const List<String> supportedDistanceUnits = [
    distanceUnitKm,
    distanceUnitMi,
  ];

  // ===== Time Constants =====
  static const int minBookingHours = 1;
  static const int maxBookingDays = 30;
  static const int cancellationWindowHours = 24;
  static const int checkInGracePeriodMinutes = 30;

  // ===== Vehicle Types =====
  static const String vehicleTypeCar = 'car';
  static const String vehicleTypeMotorcycle = 'motorcycle';
  static const String vehicleTypeTruck = 'truck';
  static const String vehicleTypeVan = 'van';
  static const String vehicleTypeEv = 'electric_vehicle';
  static const String vehicleTypeAny = 'any';

  static const List<String> vehicleTypes = [
    vehicleTypeCar,
    vehicleTypeMotorcycle,
    vehicleTypeTruck,
    vehicleTypeVan,
    vehicleTypeEv,
    vehicleTypeAny,
  ];

  // ===== Amenities =====
  static const String amenitySecurity = '24/7 Security';
  static const String amenityLighting = 'Good Lighting';
  static const String amenityCovered = 'Covered Parking';
  static const String amenityEvCharging = 'EV Charging';
  static const String amenityHandicap = 'Handicap Accessible';
  static const String amenityCctv = 'CCTV Surveillance';
  static const String amenityGate = 'Gated Entry';
  static const String amenityValet = 'Valet Service';
  static const String amenityCarWash = 'Car Wash Available';
  static const String amenityAirPump = 'Air Pump';

  static const List<String> parkingAmenities = [
    amenitySecurity,
    amenityLighting,
    amenityCovered,
    amenityEvCharging,
    amenityHandicap,
    amenityCctv,
    amenityGate,
    amenityValet,
    amenityCarWash,
    amenityAirPump,
  ];

  // ===== Reservation Status =====
  static const String reservationStatusPending = 'pending';
  static const String reservationStatusConfirmed = 'confirmed';
  static const String reservationStatusActive = 'active';
  static const String reservationStatusCompleted = 'completed';
  static const String reservationStatusCancelled = 'cancelled';
  static const String reservationStatusNoShow = 'no_show';

  // ===== Payment Status =====
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusProcessing = 'processing';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';
  static const String paymentStatusPartiallyRefunded = 'partially_refunded';

  // ===== Payment Methods =====
  static const String paymentMethodCard = 'card';
  static const String paymentMethodPaypal = 'paypal';
  static const String paymentMethodApplePay = 'apple_pay';
  static const String paymentMethodGooglePay = 'google_pay';
  static const String paymentMethodCash = 'cash';

  // ===== User Roles =====
  static const String userRoleUser = 'user';
  static const String userRoleOwner = 'owner';
  static const String userRoleAdmin = 'admin';

  // ===== Theme Modes =====
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';
  static const String themeModeSystem = 'system';

  // ===== Languages =====
  static const String languageEnglish = 'en';
  static const String languageSpanish = 'es';
  static const String languageFrench = 'fr';
  static const String languageGerman = 'de';
  static const String languageItalian = 'it';
  static const String languagePortuguese = 'pt';
  static const String languageChinese = 'zh';
  static const String languageJapanese = 'ja';

  static const String languageEnglishString = 'English';
  static const String languageSpanishString = 'Spanish';
  static const String languageFrenchString = 'French';
  static const String languageChineseString = 'Chinese';
  static const String languageGermanString = 'German';

  static const List<String> supportedLanguagesFull = [
    languageEnglishString,
    languageSpanishString,
    languageFrenchString,
    languageGermanString,
    languageChineseString,
  ];

  static const List<String> supportedLanguages = [
    languageEnglish,
    languageSpanish,
    languageFrench,
    languageGerman,
    languageItalian,
    languagePortuguese,
    languageChinese,
    languageJapanese,
  ];

  // ===== Cache & Storage =====
  static const int cacheMaxAgeDays = 7;
  static const int maxOfflineQueueSize = 1000;
  static const int maxSyncRetries = 3;
  static const Duration syncRetryDelay = Duration(minutes: 5);

  // ===== Error Messages =====
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized =
      'You are not authorized to perform this action.';
  static const String errorInvalidCredentials = 'Invalid email or password.';
  static const String errorEmailInUse = 'This email is already registered.';
  static const String errorWeakPassword = 'Password is too weak.';
  static const String errorUserNotFound = 'User not found.';
  static const String errorInvalidData = 'Invalid data provided.';
  static const String errorPermissionDenied =
      'You don\'t have permission to do that.';
  static const String errorResourceNotFound = 'Resource not found.';
  static const String errorBookingConflict =
      'This time slot is already booked.';
  static const String errorPaymentFailed = 'Payment failed. Please try again.';

  // ===== Success Messages =====
  static const String successLogin = 'Successfully logged in!';
  static const String successLogout = 'Successfully logged out!';
  static const String successRegister = 'Account created successfully!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successBooking = 'Parking space booked successfully!';
  static const String successCancellation =
      'Reservation cancelled successfully!';
  static const String successPayment = 'Payment completed successfully!';
  static const String successReview = 'Review posted successfully!';
  static const String successSettingsSaved = 'Settings saved successfully!';

  // ===== Validation Messages =====
  static const String validationRequired = 'This field is required';
  static const String validationEmail = 'Please enter a valid email address';
  static const String validationPassword =
      'Password must be at least 8 characters';
  static const String validationPasswordMatch = 'Passwords do not match';
  static const String validationPhone = 'Please enter a valid phone number';
  static const String validationName = 'Name must be at least 2 characters';
  static const String validationPrice = 'Please enter a valid price';
  static const String validationDateRange = 'End date must be after start date';
  static const String validationMinBooking =
      'Minimum booking duration is 1 hour';
  static const String validationMaxBooking =
      'Maximum booking duration is 30 days';

  // ===== UI Constants =====
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double maxContentWidth = 1200.0;

  // ===== Animation Curves =====
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSmooth = Curves.easeOutCubic;

  // ===== Date Formats =====
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String timeFormatDisplay = 'hh:mm a';
  static const String dateTimeFormatDisplay = 'MMM dd, yyyy • hh:mm a';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatApi = 'yyyy-MM-ddTHH:mm:ss';

  // ===== Regex Patterns =====
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String passwordRegex = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';

  // ===== Feature Flags =====
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
  static const bool enableInAppReviews = true;
  static const bool enableOfflineMode = true;
  static const bool enableDarkMode = true;
  static const bool enableBiometricAuth = false;

  // ===== Deep Link Routes =====
  static const String deepLinkPrefix = 'parkshare://';
  static const String deepLinkSpace = 'parkshare://space/';
  static const String deepLinkReservation = 'parkshare://reservation/';
  static const String deepLinkProfile = 'parkshare://profile/';
  static const String deepLinkReview = 'parkshare://review/';

  // ===== Sharing Messages =====
  static const String shareAppMessage =
      'Check out ParkShare - the best way to find and share parking spaces!';
  static const String shareSpaceMessage =
      'Check out this parking space on ParkShare: ';
  static const String shareReservationMessage =
      'I just booked a parking space on ParkShare!';
}

// ===== Extension Methods for Easy Access =====
extension AppConstantsExtension on BuildContext {
  AppConstants get constants => AppConstants();

  // Helper getters for common values
  double get defaultPadding => AppConstants.defaultPadding;
  double get smallPadding => AppConstants.smallPadding;
  double get largePadding => AppConstants.largePadding;
  double get defaultBorderRadius => AppConstants.defaultBorderRadius;

  // Error messages
  String get errorGeneric => AppConstants.errorGeneric;
  String get errorNetwork => AppConstants.errorNetwork;

  // Success messages
  String get successLogin => AppConstants.successLogin;
  String get successBooking => AppConstants.successBooking;
}
