import 'dart:io';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pay/pay.dart';

import '../../../config/stripe_config.dart';
import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/stripe_service.dart';
import '../../../utils/payment_config.dart';
import 'book_appointment_success_screen.dart';

class BookConfirmAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> selectedOptions;

  const BookConfirmAppointmentScreen({
    super.key,
    required this.selectedOptions,
  });

  @override
  State<BookConfirmAppointmentScreen> createState() =>
      _BookConfirmAppointmentScreenState();
}

class _BookConfirmAppointmentScreenState
    extends State<BookConfirmAppointmentScreen> {
  bool isLoading = false;
  bool isLoadingWallet = false;
  bool isProcessingPayment = false;

  Future<void> _handleWalletPayment(Map<String, dynamic> result) async {
    final price = widget.selectedOptions['service_price'] ?? 0;

    setState(() {
      isLoadingWallet = true;
    });

    try {
      //String paymentToken = result.toString();
      final paymentToken =
          result['paymentMethodData']?['tokenizationData']?['token'] ??
          result.toString();

      final appointmentResponse =
          AuthService.isAuthenticated
              ? await _createAppointment()
              : await _createAppointmentWithoutLogin();

      final appointmentId = appointmentResponse['data']['id'];

      if (appointmentId != null) {
        AuthService.isAuthenticated
            ? await ApiService.recordPaymentWallet(
              appointmentId: appointmentId,
              paymentIntentId: paymentToken,
              paymentType: defaultTargetPlatform == TargetPlatform.iOS ? "apple_pay" : "gpay",
            )
            : await ApiService.recordPaymentWalletWithoutLogin(
              appointmentId: appointmentId,
              paymentIntentId: paymentToken,
              paymentType: defaultTargetPlatform == TargetPlatform.iOS ? "apple_pay" : "gpay",
            );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => BookAppointmentSuccessScreen(data: appointmentResponse),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Wallet payment failed: $e")));
    } finally {
      setState(() {
        isLoadingWallet = false;
      });
    }
  }

  Future<Map<String, dynamic>> _createAppointment() async {
    final serviceId =
        int.tryParse(widget.selectedOptions['service_id'].toString()) ?? 0;
    final noeId =
        int.tryParse(widget.selectedOptions['noe_id'].toString()) ?? 0;
    final inPersonAddress =
        int.tryParse(
          widget.selectedOptions['inperson_address']?.toString() ?? '0',
        ) ??
        0;

    final response = await ApiService.createAppointmentNew(
      noeId: noeId,
      serviceId: serviceId,
      appointDate: widget.selectedOptions['appoint_date'],
      appointTime: widget.selectedOptions['appoint_time'],
      description: widget.selectedOptions['description'],
      appointmentDetails: widget.selectedOptions['appointment_details'] ?? '',
      preferredLanguage: widget.selectedOptions['preferred_language'] ?? '',
      inPersonAddress: inPersonAddress,
    );

    return response;
  }

  Future<Map<String, dynamic>> _createAppointmentWithoutLogin() async {
    final serviceId =
        int.tryParse(widget.selectedOptions['service_id'].toString()) ?? 0;

    final noeId =
        int.tryParse(widget.selectedOptions['noe_id'].toString()) ?? 0;

    final inPersonAddress =
        int.tryParse(
          widget.selectedOptions['inperson_address']?.toString() ?? '0',
        ) ??
        0;

    final appointmentDetails =
        int.tryParse(
          widget.selectedOptions['appointment_details']?.toString() ?? '0',
        ) ??
        0;

    final preferredLanguage =
        int.tryParse(
          widget.selectedOptions['preferred_language']?.toString() ?? '0',
        ) ??
        0;

    final response = await ApiService.createAppointmentWithoutLogin(
      noeId: noeId,
      serviceId: serviceId,
      appointDate: widget.selectedOptions['appoint_date'],
      appointTime: widget.selectedOptions['appoint_time'],
      description: widget.selectedOptions['description'],
      appointmentDetails: appointmentDetails,
      preferredLanguage: preferredLanguage,
      inPersonAddress: inPersonAddress,
      fullName: widget.selectedOptions['full_name'] ?? '',
      email: widget.selectedOptions['email'] ?? '',
      phone: widget.selectedOptions['phone'] ?? '',
      countryCode: widget.selectedOptions['country_code'] ?? '"+61"',
    );

    return response;
  }

  Future<void> _handlePaymentAndCreateAppointment() async {
    final price = widget.selectedOptions['service_price'] ?? 0;

    setState(() {
      isLoading = true;
      isProcessingPayment = true;
    });

    try {
      String? paymentMethodId;

      if (price != 0) {
        final amountInMinorUnit = StripeService.amountToMinorUnit(
          price.toDouble(),
        );

        final paymentIntent = await StripeService.createPaymentIntent(
          amountInMinorUnit: amountInMinorUnit,
          currency: StripeConfig.defaultCurrency.toLowerCase(),
          description:
              'Appointment payment for ${widget.selectedOptions['service_name']}',
          metadata: {
            'service_id':
                widget.selectedOptions['service_id']?.toString() ?? '',
            'appointment_date':
                widget.selectedOptions['appoint_date']?.toString() ?? '',
            'appointment_time':
                widget.selectedOptions['appoint_time']?.toString() ?? '',
          },
        );

        final clientSecret = paymentIntent['client_secret'];
        if (clientSecret == null || clientSecret.isEmpty) {
          throw Exception('Missing Stripe client secret');
        }

        await StripeService.presentPayment(
          context: context,
          clientSecret: clientSecret,
        );

        paymentMethodId = paymentIntent['id'];
      }

      final appointmentResponse =
          AuthService.isAuthenticated
              ? await _createAppointment()
              : await _createAppointmentWithoutLogin();

      final appointmentId = appointmentResponse['data']['id'];

      if (appointmentId != null && paymentMethodId != null) {
        AuthService.isAuthenticated
            ? await ApiService.recordAppointmentPayment(
              appointmentId: appointmentId,
              paymentIntentId: paymentMethodId,
            )
            : await ApiService.recordAppointmentPaymentWithoutLogin(
              appointmentId: appointmentId,
              paymentIntentId: paymentMethodId,
            );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => BookAppointmentSuccessScreen(data: appointmentResponse),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      setState(() {
        isLoading = false;
        isProcessingPayment = false;
      });
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opts = widget.selectedOptions;
    final price = opts['service_price'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Your Appointment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Full Name', opts['full_name'] ?? '-'),
            _row('Email', opts['email'] ?? '-'),
            _row('Phone', opts['phone'] ?? '-'),
            _row('Location', opts['location_name'] ?? '-'),
            _row('Meeting Type', opts['meeting_type'] ?? '-'),
            _row('Service', opts['service_name'] ?? '-'),
            _row(
              'Date & Time',
              '${opts['appoint_date']} at ${opts['appoint_time']}',
            ),
            _row('Enquiry Details', opts['description'] ?? '-'),

            const SizedBox(height: 30),

            // ================= WALLET BUTTON =================
            if (price != 0 && !kIsWeb) ...[
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                      Platform.isIOS
                          ? AbsorbPointer(
                            absorbing: isLoadingWallet,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ApplePayButton(
                                  paymentConfiguration:
                                      PaymentConfiguration.fromJsonString(
                                        applePayConfig,
                                      ),
                                  paymentItems: [
                                    PaymentItem(
                                      label: opts['service_name'],
                                      amount: price.toString(),
                                      status: PaymentItemStatus.final_price,
                                    ),
                                  ],
                                  width: double.infinity,
                                  height: 50,
                                  onPaymentResult: _handleWalletPayment,
                                ),
                                if (isLoadingWallet)
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          )
                          : AbsorbPointer(
                            absorbing: isLoadingWallet,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GooglePayButton(
                                  paymentConfiguration:
                                      PaymentConfiguration.fromJsonString(
                                        googlePayConfig,
                                      ),
                                  paymentItems: [
                                    PaymentItem(
                                      label: opts['service_name'],
                                      amount: price.toString(),
                                      status: PaymentItemStatus.final_price,
                                    ),
                                  ],
                                  width: double.infinity,
                                  height: 50,
                                  onPaymentResult: _handleWalletPayment,
                                ),
                                if (isLoadingWallet)
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 12),
              const Center(child: Text("OR")),
              const SizedBox(height: 12),
            ],

            Center(
              child: SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      (isLoading || isProcessingPayment)
                          ? null
                          : _handlePaymentAndCreateAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    foregroundColor: Colors.white,
                  ),
                  child:
                      (isLoading || isProcessingPayment)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            price == 0
                                ? 'Submit'
                                : 'Pay & Submit (\$${price.toStringAsFixed(2)})',
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
