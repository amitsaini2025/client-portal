import 'dart:convert';

import 'package:client/config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/stripe_config.dart';

class AuthManager {
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveUserID(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userID);
  }

  static Future<String?> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}


class StripeService {
  const StripeService._();

  static final Uri _paymentIntentUri =
      Uri.parse('${ApiConfig.baseUrl}/payments/create-payment-intent');

  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amountInMinorUnit,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    final authToken = await AuthManager.getAuthToken();
    if (authToken == null) {
      throw Exception("Auth token is missing");
    }

    // Build JSON payload exactly like curl
    final Map<String, dynamic> payload = {
      "amount": amountInMinorUnit,
      "currency": currency,
      if (description != null) "description": description,
      if (metadata != null && metadata.isNotEmpty) "metadata": metadata,
    };

    final response = await http
        .post(
      _paymentIntentUri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        // IMPORTANT: Use the exact same token as curl
        "Authorization":
        "Bearer $authToken",
      },
      body: jsonEncode(payload),
    )
        .timeout(
      StripeConfig.paymentTimeout,
      onTimeout: () {
        throw Exception("Payment request timed out.");
      },
    );

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Unable to create payment intent.");
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }


  /*static Future<Map<String, dynamic>> createPaymentIntent({
    required int amountInMinorUnit,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    final Map<String, dynamic> payload = {
      'amount': amountInMinorUnit,
      'currency': currency,
      'automatic_payment_methods': {'enabled': true},
      'capture_method': 'automatic',
      'payment_method_types': ['card'],
    };

    if (description?.isNotEmpty ?? false) {
      payload['description'] = description!;
    }

    if (metadata != null && metadata.isNotEmpty) {
      payload['metadata'] = metadata;
    }

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final response = await http.post(
      _paymentIntentUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(payload),
    ).timeout(
      StripeConfig.paymentTimeout,
      onTimeout: () {
        throw Exception('Payment request timed out. Please try again.');
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('Stripe createPaymentIntent error ${response.statusCode}: ${response.body}');
      throw Exception('Unable to create payment intent. Please try again.');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;

  }*/

  static Future<void> initPaymentSheet({
    required String clientSecret,
    ThemeMode style = ThemeMode.system,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        //merchantCountryCode: StripeConfig.merchantCountryCode,
        style: style,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF5E8B7E),
          ),
        ),
      ),
    );
  }

  static Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }

  static int amountToMinorUnit(double amount) {
    return (amount * 100).round();
  }
}

