import 'package:client/utils/app_loader.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pay/pay.dart';

import '../../../config/stripe_config.dart';
import '../../../models/billing_list/invoice.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/stripe_service.dart';
import '../../../utils/payment_config.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';

class BillingListScreen extends StatefulWidget {
  final int? matterID;

  const BillingListScreen({super.key, required this.matterID});

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
        clientMatterId: widget.matterID ?? 0,
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
    try {
      await ApiService.updateInvoicePayment(
        billingInvoiceId: invoice.id,
        clientMatterId: invoice.clientMatterId,
        paymentType:
            defaultTargetPlatform == TargetPlatform.iOS
                ? "apple_pay"
                : "google_pay",
        paymentToken: result.toString(),
        paymentStatus: "completed",
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment successful")));

      _fetchInvoices(refresh: true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment error: $e")));
    }
  }

  Future<void> _handleStripePayment(Invoice invoice) async {
    setState(() => _processingStripeInvoiceId = invoice.id);

    try {
      final rawAmount = invoice.totalAmount ?? 0;
      final amountDouble = double.tryParse(rawAmount.toString()) ?? 0;

      if (amountDouble <= 0) {
        throw Exception("Invalid invoice amount");
      }

      final amountInMinorUnit = StripeService.amountToMinorUnit(amountDouble);

      final paymentIntent = await StripeService.createPaymentIntent(
        amountInMinorUnit: amountInMinorUnit,
        currency: StripeConfig.defaultCurrency.toLowerCase(),
        description: 'Payment for invoice ${invoice.invoiceNumber}',
        metadata: {
          'invoice_id': invoice.id.toString(),
          'client_matter_id': invoice.clientMatterId.toString(),
        },
      );

      final clientSecret = paymentIntent['client_secret'];

      if (clientSecret == null) {
        throw Exception("Missing client secret");
      }

      if (kIsWeb) {
        await _handleStripeWebPayment(clientSecret, invoice);
      } else {
        await StripeService.presentPayment(
          context: context,
          clientSecret: clientSecret,
          style:
              Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
        );
      }

      await ApiService.updateInvoicePayment(
        billingInvoiceId: invoice.id,
        clientMatterId: invoice.clientMatterId,
        paymentType: "stripe",
        paymentToken: paymentIntent['id'],
        paymentStatus: "completed",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stripe payment successful")),
      );

      _fetchInvoices(refresh: true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Stripe payment failed: $e")));
    } finally {
      setState(() => _processingStripeInvoiceId = null);
    }
  }

  Future<void> _handleStripeWebPayment(
    String clientSecret,
    Invoice invoice,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Card Details"),
          content: CardField(onCardChanged: (card) {}),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Stripe.instance.createPaymentMethod(
                    params: const PaymentMethodParams.card(
                      paymentMethodData: PaymentMethodData(),
                    ),
                  );

                  await Stripe.instance.confirmPayment(
                    paymentIntentClientSecret: clientSecret,
                    data: PaymentMethodParams.card(
                      paymentMethodData: PaymentMethodData(
                        billingDetails: BillingDetails(),
                      ),
                    ),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context);
                  throw Exception(e.toString());
                }
              },
              child: const Text("Pay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CommonAppBar(
        titleName: 'Billing & Invoices',
        matterID: AuthService.selectedMatterId,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child: Column(
            children: [
              _buildSummary(),
              Expanded(
                child:
                    _isInitialLoading
                        ? const Center(child: AppLoader())
                        : ListView.builder(
                          controller: _scrollController,
                          padding: AppResponsive.pagePadding(context),
                          itemCount: _invoices.length,
                          itemBuilder: (context, index) {
                            return _buildInvoiceCard(_invoices[index]);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: AppResponsive.horizontalPadding(
        context,
      ).copyWith(top: 16, bottom: 8),
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
    String title,
    double amount,
    Gradient gradient,
    IconData icon,
  ) {
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
    final isProcessing = _processingStripeInvoiceId == invoice.id;

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

              if (!kIsWeb) ...[
                defaultTargetPlatform == TargetPlatform.iOS
                    ? ApplePayButton(
                      paymentConfiguration: PaymentConfiguration.fromJsonString(
                        applePayConfig,
                      ),
                      paymentItems: [
                        PaymentItem(
                          label: "Invoice ${invoice.invoiceNumber}",
                          amount: invoice.totalAmount?.toString() ?? '0',
                          status: PaymentItemStatus.final_price,
                        ),
                      ],
                      width: double.infinity,
                      height: 48,
                      onPaymentResult: (r) => _onPaymentResult(r, invoice),
                    )
                    : GooglePayButton(
                      paymentConfiguration: PaymentConfiguration.fromJsonString(
                        googlePayConfig,
                      ),
                      paymentItems: [
                        PaymentItem(
                          label: "Invoice ${invoice.invoiceNumber}",
                          amount: invoice.totalAmount?.toString() ?? '0',
                          status: PaymentItemStatus.final_price,
                        ),
                      ],
                      width: double.infinity,
                      height: 48,
                      onPaymentResult: (r) => _onPaymentResult(r, invoice),
                    ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isProcessing ? null : () => _handleStripePayment(invoice),
                  child:
                      isProcessing
                          ? const AppLoader(size: 20)
                          : const Text("Pay with Stripe"),
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
        color:
            isPaid
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
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
