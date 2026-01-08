import 'package:client/config/api_config.dart';
import 'package:client/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class FCMService {

  // Singleton pattern
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  Future<bool> initialize() async {
    try {
      // Request permission for notifications (iOS)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: User granted notification permission');
        return true;
      } else {
        debugPrint('FCM: User denied notification permission');
        return false;
      }
    } catch (e) {
      debugPrint('FCM: Error initializing: $e');
      return false;
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
      return null;
    }
  }


  /// Retry failed token registration
  Future<bool> retryFailedRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final isRegistered = prefs.getBool('fcm_token_registered') ?? false;

    if (!isRegistered) {
      final storedToken = prefs.getString('fcm_token');
      if (storedToken != null) {
        debugPrint('FCM: Retrying token registration...');
        return await ApiService.registerFCMToken(storedToken);
      }
    }
    return false;
  }

  /// Set up message listeners
  void setupMessageListeners({
    required Function(RemoteMessage) onForegroundMessage,
    required Function(RemoteMessage) onBackgroundMessageTap,
  }) {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Listen for notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(onBackgroundMessageTap);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM: Token refreshed: $newToken');
      await ApiService.registerFCMToken(newToken);
    });
  }

  /// Handle initial message when app is opened from notification
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  /// Check if token is registered
  Future<bool> isTokenRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fcm_token_registered') ?? false;
  }

  /// Clear stored FCM data
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
    await prefs.remove('fcm_token_registered');
  }

  /// Get stored FCM token
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }
}
