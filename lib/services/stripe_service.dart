import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../config/stripe_config.dart';

class StripeService {
  const StripeService._();

  static final Uri _paymentIntentUri =
      Uri.parse('https://api.stripe.com/v1/payment_intents');

  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amountInMinorUnit,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    final payload = <String, String>{
      'amount': amountInMinorUnit.toString(),
      'currency': currency,
      'automatic_payment_methods[enabled]': 'true',
      'capture_method': 'automatic',
      'payment_method_types[]': 'card',
    };

    if (description?.isNotEmpty ?? false) {
      payload['description'] = description!;
    }

    metadata?.forEach((key, value) {
      payload['metadata[$key]'] = value;
    });

    final response = await http
        .post(
          _paymentIntentUri,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
          },
          body: payload,
          encoding: Encoding.getByName('utf-8'),
        )
        .timeout(
      StripeConfig.paymentTimeout,
      onTimeout: () {
        throw const StripeException(
          error: StripeError(
            type: StripeErrorType.apiConnectionError,
            message: 'Payment request timed out. Please try again.',
          ),
        );
      },
    );

    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode < 200 || statusCode >= 300) {
      debugPrint('Stripe createPaymentIntent error $statusCode: $body');
      throw StripeException(
        error: StripeError(
          type: StripeErrorType.apiError,
          message: 'Unable to create payment intent. Please try again.',
        ),
      );
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }

  static Future<void> initPaymentSheet({
    required String clientSecret,
    ThemeMode style = ThemeMode.system,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        merchantCountryCode: StripeConfig.merchantCountryCode,
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

