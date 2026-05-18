import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      colors: true,
      printTime: true,
    ),
  );

  static void debug(String message) {
    if (kDebugMode) _logger.d(message);
  }

  static void info(String message) {
    if (kDebugMode) _logger.i(message);
  }

  static void warning(String message) {
    if (kDebugMode) _logger.w(message);
  }

  static void error(String message, Object? error, StackTrace? stack) {
    if(kDebugMode)
      _logger.e(message, error: error, stackTrace: stack);
  }
}