import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../config/stripe_config.dart';
import '../../../config/theme_config.dart';
import '../../../models/billing_list/invoice.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/payment_config.dart';
import '../../../services/stripe_service.dart';

class BillingListScreen extends StatefulWidget {
  const BillingListScreen({super.key});

  @override
  State<BillingListScreen> createState() => _BillingListScreenState();
}

class _BillingListScreenState extends State<BillingListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Invoice> _invoices = [];

  bool _isInitialLoading = true;
  bool _isPaginating = false;
  bool _hasMore = true;

  int? _processingStripeInvoiceId;

  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(_paginationListener);
  }

  void _paginationListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150 &&
        !_isPaginating &&
        _hasMore) {
      _fetchInvoices();
    }
  }

  Future<void> _fetchInvoices({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _invoices.clear();
    }

    setState(() {
      refresh ? _isInitialLoading = true : _isPaginating = true;
    });

    try {
      final response = await ApiService.getInvoices(
        clientMatterId: AuthService.selectedMatterId ?? 0,
        page: _currentPage,
        perPage: _perPage,
      );

      final data = response['data'];
      final invoicesJson = data['invoices'] as List;
      final pagination = data['pagination'];

      final fetchedInvoices =
      invoicesJson.map((e) => Invoice.fromJson(e)).toList();

      setState(() {
        _invoices.addAll(fetchedInvoices);
        _hasMore = _currentPage < pagination['last_page'];
        _currentPage++;
      });
    } catch (e) {
      debugPrint("Error loading invoices: $e");
    } finally {
      setState(() {
        _isInitialLoading = false;
        _isPaginating = false;
      });
    }
  }

  double get totalAmount =>
      _invoices.fold(0, (sum, i) => sum + (i.totalAmount ?? 0));

  double get pendingAmount => _invoices
      .where((i) => i.status == 'pending')
      .fold(0, (sum, i) => sum + (i.totalAmount ?? 0));

  void _onPaymentResult(Map<String, dynamic> result, Invoice invoice) async {
    debugPrint("Payment Result: $result");

    try {
      String paymentToken = result.toString();

      await ApiService.updateInvoicePayment(
        billingInvoiceId: invoice.id!,
        clientMatterId: invoice.clientMatterId!,
        paymentType: Platform.isIOS ? "apple_pay" : "google_pay",
        paymentToken: paymentToken,
        paymentStatus: "completed",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful")),
      );

      _fetchInvoices(refresh: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $e")),
      );
    }
  }

  Future<void> _handleStripePayment(Invoice invoice) async {
    // Process one invoice at a time
    setState(() => _processingStripeInvoiceId = invoice.id);

    try {
      final rawAmount = invoice.totalAmount ?? 0;
      final amountDouble = double.tryParse(rawAmount.toString()) ?? 0;

      if (amountDouble <= 0) {
        throw Exception("Invalid invoice amount: $rawAmount");
      }

      // Convert to minor unit (cents/paisa)
      final amountInMinorUnit = StripeService.amountToMinorUnit(amountDouble);

      // Create PaymentIntent via backend
      final paymentIntent = await StripeService.createPaymentIntent(
        amountInMinorUnit: amountInMinorUnit,
        currency: StripeConfig.defaultCurrency.toLowerCase(),
        description: 'Payment for invoice ${invoice.invoiceNumber}',
        metadata: {
          'invoice_id': invoice.id!.toString(),
          'client_matter_id': invoice.clientMatterId!.toString(),
        },
      );

      final clientSecret = paymentIntent['client_secret'];
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Missing Stripe client secret');
      }

      // Initialize Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: StripeConfig.merchantDisplayName,
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      );

      // Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // Record payment in backend
      await ApiService.updateInvoicePayment(
        billingInvoiceId: invoice.id!,
        clientMatterId: invoice.clientMatterId!,
        paymentType: "stripe",
        paymentToken: paymentIntent['id'], // Stripe PaymentIntent ID
        paymentStatus: "completed",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stripe payment successful")),
      );

      _fetchInvoices(refresh: true);
    } on StripeException catch (e) {
      final cancelled = e.error.code == FailureCode.Canceled ||
          e.error.message?.toLowerCase() == 'canceled';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cancelled ? 'Payment cancelled.' : (e.error.message ?? 'Payment failed'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stripe payment failed: $e")),
      );
    } finally {
      setState(() => _processingStripeInvoiceId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        title: const Text(
          "Billing & Invoices",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSummary(),
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                return _buildInvoiceCard(_invoices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _modernSummaryCard(
              "Total",
              totalAmount,
              const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
              Icons.receipt_long,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _modernSummaryCard(
              "Pending",
              pendingAmount,
              const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
              ),
              Icons.pending_actions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernSummaryCard(
      String title, double amount, Gradient gradient, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 12),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isPaid = invoice.status == 'paid';
    final isProcessingStripe = _processingStripeInvoiceId == invoice.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.invoiceNumber ?? "INV-${invoice.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _statusBadge(invoice.status ?? ""),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "\$${invoice.totalAmount?.toStringAsFixed(2) ?? "0.00"}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!isPaid) ...[
              const SizedBox(height: 16),
              Platform.isIOS
                  ? ApplePayButton(
                paymentConfiguration:
                PaymentConfiguration.fromJsonString(applePayConfig),
                paymentItems: [
                  PaymentItem(
                    label: "Invoice ${invoice.invoiceNumber}",
                    amount: invoice.totalAmount!.toString(),
                    status: PaymentItemStatus.final_price,
                  ),
                ],
                width: double.infinity,
                height: 48,
                onPaymentResult: (result) =>
                    _onPaymentResult(result, invoice),
              )
                  : GooglePayButton(
                paymentConfiguration:
                PaymentConfiguration.fromJsonString(googlePayConfig),
                paymentItems: [
                  PaymentItem(
                    label: "Invoice ${invoice.invoiceNumber}",
                    amount: invoice.totalAmount!.toString(),
                    status: PaymentItemStatus.final_price,
                  ),
                ],
                width: double.infinity,
                height: 48,
                onPaymentResult: (result) =>
                    _onPaymentResult(result, invoice),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isProcessingStripe
                      ? null
                      : () => _handleStripePayment(invoice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: isProcessingStripe
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Pay with Stripe'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPaid ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}