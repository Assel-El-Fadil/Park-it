import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:src/core/enums/app_enums.dart';

class NavigationResult {
  /// Whether the navigation operation was successful
  final bool success;

  /// Optional message (success message or error details)
  final String? message;

  /// Error type if operation failed
  final NavigationError? error;

  /// Additional data that might be returned (like distance, ETA)
  final Map<String, dynamic>? data;

  const NavigationResult({
    required this.success,
    this.message,
    this.error,
    this.data,
  }) : assert(
         success ? error == null : error != null,
         'Error must be provided for failed operations',
       );

  // Factory constructors for common cases
  factory NavigationResult.success({
    String? message,
    Map<String, dynamic>? data,
  }) {
    return NavigationResult(
      success: true,
      message: message ?? 'Navigation started successfully',
      data: data,
    );
  }

  factory NavigationResult.failure(
    NavigationError error, {
    String? message,
    Map<String, dynamic>? data,
  }) {
    return NavigationResult(
      success: false,
      error: error,
      message: message ?? error.userMessage,
      data: data,
    );
  }

  // Check if operation was successful
  bool get isSuccess => success;
  bool get isFailure => !success;

  // Get error message safely
  String get errorMessage => message ?? error?.userMessage ?? 'Unknown error';

  // Get error title
  String get errorTitle => error?.title ?? 'Error';

  // Get error icon
  IconData get errorIcon => error?.icon ?? Icons.error_outline;

  // Check if error is recoverable
  bool get isRecoverable => error?.isRecoverable ?? false;

  // Get suggested action
  String? get suggestedAction => error?.suggestedAction;

  // Convert to string representation
  @override
  String toString() {
    if (success) {
      return 'NavigationResult(success: true, message: $message)';
    } else {
      return 'NavigationResult(success: false, error: $error, message: $message)';
    }
  }

  // Create a copy with modified fields
  NavigationResult copyWith({
    bool? success,
    String? message,
    NavigationError? error,
    Map<String, dynamic>? data,
  }) {
    return NavigationResult(
      success: success ?? this.success,
      message: message ?? this.message,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }

  // Show error dialog
  Future<void> showErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(errorIcon, color: Colors.red),
            const SizedBox(width: 8),
            Text(errorTitle),
          ],
        ),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (suggestedAction != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSuggestedAction(context);
              },
              child: Text(suggestedAction!),
            ),
        ],
      ),
    );
  }

  // Handle suggested action based on error type
  void _handleSuggestedAction(BuildContext context) {
    switch (error) {
      case NavigationError.locationServicesDisabled:
        Geolocator.openLocationSettings();
        break;
      case NavigationError.permissionDenied:
        // Request permission again
        Geolocator.requestPermission();
        break;
      case NavigationError.permissionDeniedForever:
        Geolocator.openAppSettings();
        break;
      case NavigationError.networkError:
      case NavigationError.locationTimeout:
        // Just retry - handled by caller
        break;
      default:
        break;
    }
  }
}

/// Extension for handling multiple navigation results
extension NavigationResultListExtension on List<NavigationResult> {
  /// Check if all operations were successful
  bool get allSuccess => every((result) => result.success);

  /// Check if any operation failed
  bool get anyFailure => any((result) => result.isFailure);

  /// Get all failed results
  List<NavigationResult> get failures =>
      where((result) => result.isFailure).toList();

  /// Get all successful results
  List<NavigationResult> get successes =>
      where((result) => result.isSuccess).toList();

  /// Get first error message
  String? get firstErrorMessage {
    final firstFailure = failures.firstOrNull;
    return firstFailure?.errorMessage;
  }
}
