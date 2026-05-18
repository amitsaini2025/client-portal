import 'dart:convert';

import 'package:client/config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/stripe_config.dart';
import '../utils/app_loader.dart';

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

  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
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
        if (authToken != null) "Authorization": "Bearer $authToken",
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

  static final Uri _checkoutSessionUri = Uri.parse('${ApiConfig.baseUrl}/payments/create-checkout-session');

  static Future<Map<String, dynamic>> createCheckoutSession({
    required dynamic amount,
    required String currency,
    required String serviceName,
    required String customerEmail,
  }) async {
    final authToken = await AuthManager.getAuthToken();

    final Map<String, dynamic> payload = {
      'amount': amount,
      'currency': currency,
      'service_name': serviceName,
      'customer_email': customerEmail,
    };

    final response = await http
        .post(
      _checkoutSessionUri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(payload),
    )
        .timeout(
      StripeConfig.paymentTimeout,
      onTimeout: () {
        throw Exception('Checkout session request timed out.');
      },
    );

    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to create checkout session.');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> verifyCheckoutSession({
    required String sessionId,
  }) async {
    final authToken = await AuthManager.getAuthToken();

    final response = await http
        .get(
      Uri.parse('${ApiConfig.baseUrl}/payments/checkout-session/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    )
        .timeout(
      StripeConfig.paymentTimeout,
      onTimeout: () {
        throw Exception('Verification request timed out.');
      },
    );

    debugPrint('VERIFY STATUS: ${response.statusCode}');
    debugPrint('VERIFY BODY: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to verify payment.');
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

  /// Presents payment UI — web uses a CardFormField dialog, mobile uses PaymentSheet.
  static Future<void> presentPayment({
    required BuildContext context,
    required String clientSecret,
    ThemeMode style = ThemeMode.system,
  }) async {
    if (kIsWeb) {
      final success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _StripeWebPaymentDialog(clientSecret: clientSecret),
      );
      if (success != true) {
        throw const StripeException(
          error: LocalizedErrorMessage(
            code: FailureCode.Canceled,
            message: 'Canceled',
          ),
        );
      }
    } else {
      await initPaymentSheet(clientSecret: clientSecret, style: style);
      await presentPaymentSheet();
    }
  }
}

class _StripeWebPaymentDialog extends StatefulWidget {
  const _StripeWebPaymentDialog({required this.clientSecret});
  final String clientSecret;

  @override
  State<_StripeWebPaymentDialog> createState() =>
      _StripeWebPaymentDialogState();
}

class _StripeWebPaymentDialogState extends State<_StripeWebPaymentDialog> {
  bool _cardComplete = false;
  bool _isLoading = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on StripeException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.error.localizedMessage ??
              e.error.message ??
              'Payment failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Payment failed. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Card Details'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardFormField(
              onCardChanged: (card) {
                setState(() {
                  _cardComplete = card?.complete == true;
                });
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_cardComplete && !_isLoading) ? _pay : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E8B7E),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: AppLoader(),
                )
              : const Text('Pay'),
        ),
      ],
    );
  }
}
