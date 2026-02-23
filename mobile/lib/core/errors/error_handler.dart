import 'dart:developer' as dev;
import 'app_exceptions.dart';

class ErrorHandler {
  // Log error details
  static void log(Object error, [StackTrace? stackTrace]) {
    dev.log(
      'Error: $error',
      error: error,
      stackTrace: stackTrace,
      name: 'ErrorHandler',
    );
  }

  // Wrap to AppException
  static AppException wrap(Object error) {
    if (error is AppException) return error;
    return ConfigurationException(error.toString());
  }

  // Get display message
  static String getMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An error occurred';
  }

  // Handle with callback
  static Future<T?> handle<T>(
    Future<T> Function() action, {
    Function(AppException)? onError,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      log(e, stackTrace);
      final exception = wrap(e);
      onError?.call(exception);
      return null;
    }
  }

  // Execute with fallback
  static Future<T> withDefault<T>(
    Future<T> Function() action,
    T defaultValue,
  ) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      log(e, stackTrace);
      return defaultValue;
    }
  }
}
