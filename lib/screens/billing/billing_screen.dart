import 'package:client/utils/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:intl/intl.dart';

import '../../config/stripe_config.dart';
import '../../models/invoice.dart';
import '../../services/stripe_service.dart';
import '../../utils/responsive_utils.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _isProcessingPayment = false;
  int? _processingInvoiceId;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mock invoices data - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _invoices = [
          Invoice(
            id: 1,
            invoiceNumber: 'INV-2024-001',
            totalAmount: 2500.00,
            status: 'paid',
            dueDate: DateTime.now().subtract(const Duration(days: 10)),
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now().subtract(const Duration(days: 10)),
            notes: 'Immigration Visa Application Fee',
          ),
          Invoice(
            id: 2,
            invoiceNumber: 'INV-2024-002',
            totalAmount: 1500.00,
            status: 'pending',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
            notes: 'Document Review Service',
          ),
          Invoice(
            id: 3,
            invoiceNumber: 'INV-2024-003',
            totalAmount: 800.00,
            status: 'overdue',
            dueDate: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
            updatedAt: DateTime.now().subtract(const Duration(days: 3)),
            notes: 'Consultation Fee',
          ),
          Invoice(
            id: 4,
            invoiceNumber: 'INV-2024-004',
            totalAmount: 3200.00,
            status: 'paid',
            dueDate: DateTime.now().subtract(const Duration(days: 25)),
            createdAt: DateTime.now().subtract(const Duration(days: 45)),
            updatedAt: DateTime.now().subtract(const Duration(days: 25)),
            notes: 'Work Permit Application Fee',
          ),
          Invoice(
            id: 5,
            invoiceNumber: 'INV-2024-005',
            totalAmount: 500.00,
            status: 'draft',
            dueDate: DateTime.now().add(const Duration(days: 15)),
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
            notes: 'Additional Document Processing',
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load invoices: ${e.toString()}';
      });
    }
  }

  List<Invoice> get _filteredInvoices {
    return _invoices.where((invoice) {
      final matchesSearch =
          (invoice.invoiceNumber?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false) ||
          (invoice.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesStatus =
          _statusFilter == 'all' || invoice.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      case 'cancelled':
        return Colors.red[300]!;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
      case 'draft':
        return 'Draft';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      case 'draft':
        return Icons.edit;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  bool _isOverdue(DateTime dueDate, String status) {
    return dueDate.isBefore(DateTime.now()) && status != 'paid';
  }

  bool _isProcessingInvoice(int invoiceId) {
    return _isProcessingPayment && _processingInvoiceId == invoiceId;
  }

  Future<void> _handlePayInvoice(Invoice invoice) async {
    if (_isProcessingInvoice(invoice.id)) {
      return;
    }

    final totalAmount = invoice.totalAmount;
    if (totalAmount == null || totalAmount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This invoice does not have a payable amount yet.'),
          ),
        );
      }
      return;
    }

    final currency =
        (invoice.currency ?? StripeConfig.defaultCurrency).toLowerCase();
    final amountInMinorUnit = StripeService.amountToMinorUnit(totalAmount);
    final description =
        invoice.notes?.isNotEmpty == true
            ? invoice.notes!
            : 'Payment for ${invoice.displayInvoiceNumber}';

    setState(() {
      _isProcessingPayment = true;
      _processingInvoiceId = invoice.id;
    });

    try {
      final paymentIntent = await StripeService.createPaymentIntent(
        amountInMinorUnit: amountInMinorUnit,
        currency: currency,
        description: description,
        metadata: {
          'order_id': invoice.id.toString(),
          if (invoice.invoiceNumber != null)
            'order_number': invoice.invoiceNumber!,
        },
      );

      final clientSecret = paymentIntent['client_secret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception(
          'Missing Stripe client secret. Please contact support.',
        );
      }

      await StripeService.presentPayment(
        context: context,
        clientSecret: clientSecret,
        style:
            Theme.of(context).brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
      );

      if (!mounted) return;
      setState(() {
        _invoices =
            _invoices
                .map(
                  (existing) =>
                      existing.id == invoice.id
                          ? existing.copyWith(
                            status: 'paid',
                            paidDate: DateTime.now(),
                            updatedAt: DateTime.now(),
                          )
                          : existing,
                )
                .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment confirmed for ${invoice.displayInvoiceNumber}.',
          ),
          backgroundColor: Colors.green[600],
        ),
      );
    } on StripeException catch (error) {
      if (!mounted) return;
      final wasCancelled =
          error.error.code == FailureCode.Canceled ||
          error.error.message?.toLowerCase() == 'canceled';
      final message =
          wasCancelled
              ? 'Payment cancelled.'
              : (error.error.message ?? 'Payment failed. Please try again.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error, stackTrace) {
      debugPrint('Stripe payment error: $error');
      debugPrint('Stripe payment stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to process payment right now. Please try again shortly.',
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessingPayment = false;
        _processingInvoiceId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _invoices.fold(
      0.0,
      (sum, invoice) => sum + (invoice.totalAmount ?? 0.0),
    );
    final paidAmount = _invoices
        .where((invoice) => invoice.status == 'paid')
        .fold(0.0, (sum, invoice) => sum + (invoice.totalAmount ?? 0.0));
    final pendingAmount = _invoices
        .where(
          (invoice) =>
              invoice.status == 'pending' || invoice.status == 'overdue',
        )
        .fold(0.0, (sum, invoice) => sum + (invoice.totalAmount ?? 0.0));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Billing & Invoices'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsive.maxContentWidth,
            ),
            child: Column(
              children: [
                // Summary Cards
                Container(
                  padding: AppResponsive.pagePadding(context),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      final summaryCards = [
                        _buildSummaryCard(
                          'Total Amount',
                          '\$${NumberFormat('#,##0.00').format(totalAmount)}',
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                        _buildSummaryCard(
                          'Paid',
                          '\$${NumberFormat('#,##0.00').format(paidAmount)}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildSummaryCard(
                          'Pending',
                          '\$${NumberFormat('#,##0.00').format(pendingAmount)}',
                          Icons.schedule,
                          Colors.orange,
                        ),
                        _buildSummaryCard(
                          'Overdue',
                          '\$${NumberFormat('#,##0.00').format(_invoices.where((i) => i.status == 'overdue').fold(0.0, (sum, i) => sum + (i.totalAmount ?? 0.0)))}',
                          Icons.warning,
                          Colors.red,
                        ),
                      ];
                      if (isWide) {
                        return Row(
                          children:
                              summaryCards
                                  .map(
                                    (c) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: c,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: summaryCards[0]),
                              const SizedBox(width: 12),
                              Expanded(child: summaryCards[1]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: summaryCards[2]),
                              const SizedBox(width: 12),
                              Expanded(child: summaryCards[3]),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Search and Filter Bar
                Container(
                  padding: AppResponsive.horizontalPadding(context),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search invoices...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Paid', 'paid'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending', 'pending'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Overdue', 'overdue'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Draft', 'draft'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Invoices List
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: AppLoader())
                          : _errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadInvoices,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                          : _filteredInvoices.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _statusFilter != 'all'
                                      ? 'No invoices match your search'
                                      : 'No invoices found',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: _loadInvoices,
                            child: ListView.builder(
                              padding: AppResponsive.horizontalPadding(context),
                              itemCount: _filteredInvoices.length,
                              itemBuilder: (context, index) {
                                final invoice = _filteredInvoices[index];
                                return _buildInvoiceCard(invoice);
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isOverdue =
        invoice.dueDate != null
            ? _isOverdue(invoice.dueDate!, invoice.status ?? 'draft')
            : false;
    final isProcessing = _isProcessingInvoice(invoice.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isProcessing ? null : () => _showInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber ?? 'INV-${invoice.id}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          invoice.notes ?? 'No description',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${NumberFormat('#,##0.00').format(invoice.totalAmount ?? 0.0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            invoice.status ?? 'draft',
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(
                              invoice.status ?? 'draft',
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(invoice.status ?? 'draft'),
                              size: 14,
                              color: _getStatusColor(invoice.status ?? 'draft'),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(invoice.status ?? 'draft'),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: _getStatusColor(
                                  invoice.status ?? 'draft',
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${invoice.dueDate != null ? DateFormat('MMM d, y').format(invoice.dueDate!) : 'No due date'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created: ${DateFormat('MMM d, y').format(invoice.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 14, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Payment Overdue',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isProcessing) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(height: 18, width: 18, child: AppLoader()),
                    const SizedBox(width: 8),
                    Text(
                      'Processing payment...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      invoice.invoiceNumber ?? 'INV-${invoice.id}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      invoice.notes ?? 'No description',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow(
                      Icons.attach_money,
                      'Amount',
                      '\$${NumberFormat('#,##0.00').format(invoice.totalAmount ?? 0.0)}',
                    ),
                    _buildDetailRow(
                      Icons.info,
                      'Status',
                      _getStatusText(invoice.status ?? 'draft'),
                    ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Due Date',
                      invoice.dueDate != null
                          ? DateFormat(
                            'EEEE, MMMM d, y',
                          ).format(invoice.dueDate!)
                          : 'No due date',
                    ),
                    _buildDetailRow(
                      Icons.schedule,
                      'Created',
                      DateFormat('MMM d, y').format(invoice.createdAt),
                    ),

                    const SizedBox(height: 24),

                    if (invoice.status == 'pending' ||
                        invoice.status == 'overdue')
                      SizedBox(
                        width: double.infinity,
                        child: Builder(
                          builder: (_) {
                            final processing = _isProcessingInvoice(invoice.id);
                            return ElevatedButton(
                              onPressed:
                                  processing
                                      ? null
                                      : () {
                                        Navigator.of(context).pop();
                                        _handlePayInvoice(invoice);
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.green
                                    .withValues(alpha: 0.6),
                              ),
                              child:
                                  processing
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: AppLoader(),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Processing...'),
                                        ],
                                      )
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.payment),
                                          SizedBox(width: 8),
                                          Text('Pay Now'),
                                        ],
                                      ),
                            );
                          },
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Implement download functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Download functionality not implemented yet',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download Invoice'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
