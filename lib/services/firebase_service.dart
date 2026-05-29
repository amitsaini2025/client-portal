import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Singleton accessors for Firebase observability services.
/// Each property is null on platforms where the service is unsupported.
class FirebaseObservability {
  FirebaseObservability._();

  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;

  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseCrashlytics? get crashlytics => _crashlytics;
  static FirebasePerformance? get performance => _performance;

  /// Call once after [Firebase.initializeApp].
  static Future<void> initialize() async {
    await _initializeCrashlytics();
    await _initializeAnalytics();
    await _initializePerformance();
  }

  // Crashlytics: Android, iOS, macOS
  static Future<void> _initializeCrashlytics() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;

    _crashlytics = FirebaseCrashlytics.instance;
    // Disable collection in debug mode to keep the Crashlytics dashboard clean.
    await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = _crashlytics!.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics!.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Analytics: Android, iOS, Web, macOS
  static Future<void> _initializeAnalytics() async {
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;

    _analytics = FirebaseAnalytics.instance;
    await _analytics!.setAnalyticsCollectionEnabled(true);
  }

  // Performance: Android, iOS, Web
  static Future<void> _initializePerformance() async {
    final bool supported =
        kIsWeb || (!kIsWeb && (Platform.isAndroid || Platform.isIOS));
    if (!supported) return;

    _performance = FirebasePerformance.instance;
    await _performance!.setPerformanceCollectionEnabled(true);
  }
}
