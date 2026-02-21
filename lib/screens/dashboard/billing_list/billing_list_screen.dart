import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../config/theme_config.dart';
import '../../../models/billing_list/invoice.dart';
import '../../../services/auth_service.dart';
import '../../../services/stripe_service.dart';
import '../../../config/stripe_config.dart';

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

  int _currentPage = 1;
  final int _perPage = 10;

  final Set<int> _processingPayments = {};

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

    if (!_hasMore) return;

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

  // ==========================
  // 🔥 PAYMENT FUNCTION
  // ==========================

  Future<void> _handleInvoicePayment(Invoice invoice) async {
    setState(() {
      _processingPayments.add(invoice.id);
    });

    try {
      final amount =
      StripeService.amountToMinorUnit(invoice.totalAmount ?? 0);

      final paymentIntent = await StripeService.createPaymentIntent(
        amountInMinorUnit: amount,
        currency: StripeConfig.defaultCurrency.toLowerCase(),
        description: 'Invoice Payment ${invoice.invoiceNumber}',
        metadata: {
          'invoice_id': invoice.id.toString(),
        },
      );

      final clientSecret = paymentIntent['client_secret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: StripeConfig.merchantDisplayName,

          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "US",
            currencyCode: "USD",
            testEnv: true,
          ),

          applePay: const PaymentSheetApplePay(
            merchantCountryCode: "US",
          ),

          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Record payment in backend
      /*await ApiService.recordInvoicePayment(
        invoiceId: invoice.id!,
        paymentIntentId: paymentIntent['id'],
      );*/

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful")),
      );

      _fetchInvoices(refresh: true);
    } catch (e) {
      debugPrint("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      setState(() {
        _processingPayments.remove(invoice.id);
      });
    }
  }

  // ==========================

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchInvoices(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(),
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () => _fetchInvoices(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _invoices.length +
                    (_isPaginating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _invoices.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child:
                          CircularProgressIndicator()),
                    );
                  }

                  return _buildInvoiceCard(
                      _invoices[index]);
                },
              ),
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
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isPaid = invoice.status == 'paid';
    final isProcessing =
    _processingPayments.contains(invoice.id);

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
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.invoiceNumber ??
                      "INV-${invoice.id}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                _statusBadge(invoice.status ?? ""),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "\$${invoice.totalAmount?.toStringAsFixed(2) ?? "0.00"}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            if (!isPaid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () =>
                      _handleInvoicePayment(invoice),
                  child: isProcessing
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("Pay Now"),
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
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
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
          color: isPaid
              ? Colors.green
              : Colors.orange,
        ),
      ),
    );
  }
}