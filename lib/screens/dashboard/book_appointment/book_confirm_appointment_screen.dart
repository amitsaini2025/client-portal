import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../config/stripe_config.dart';
import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/stripe_service.dart';
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
  bool isProcessingPayment = false;

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

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: StripeConfig.merchantDisplayName,
            style:
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light,
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        //final paymentIntentResult = await Stripe.instance.retrievePaymentIntent(clientSecret);
        //paymentMethodId = paymentIntentResult.paymentMethodId;
        paymentMethodId = paymentIntent['id'];
      }

      final appointmentResponse =
          AuthService.isAuthenticated
              ? await _createAppointment()
              : await _createAppointmentWithoutLogin();

      final appointmentId = appointmentResponse['data']['id'];

      if (appointmentId != null && paymentMethodId != null) {
        final requestData = {
          'appointment_id': appointmentId,
          'payment_intent_id': paymentMethodId,
        };
        print('recordAppointmentPayment REQUEST: $requestData');
        final paymentResponse =
            AuthService.isAuthenticated
                ? await ApiService.recordAppointmentPayment(
                  appointmentId: appointmentId,
                  paymentIntentId: paymentMethodId,
                )
                : await ApiService.recordAppointmentPaymentWithoutLogin(
                  appointmentId: appointmentId,
                  paymentIntentId: paymentMethodId,
                );

        print('recordAppointmentPayment RESPONSE: $paymentResponse');
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => BookAppointmentSuccessScreen(data: appointmentResponse),
        ),
      );
    } on StripeException catch (e) {
      final cancelled =
          e.error.code == FailureCode.Canceled ||
          e.error.message?.toLowerCase() == 'canceled';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cancelled
                ? 'Payment cancelled.'
                : (e.error.message ?? 'Payment failed.'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to complete booking: $e')));
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
        elevation: 0,
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
            const SizedBox(height: 40),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child:
                      (isLoading || isProcessingPayment)
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
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
