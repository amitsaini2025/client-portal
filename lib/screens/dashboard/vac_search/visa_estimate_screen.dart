import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../models/visa_search/visa_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';

class VisaEstimateScreen extends StatefulWidget {
  final VisaModel visa;

  const VisaEstimateScreen({super.key, required this.visa});

  @override
  State<VisaEstimateScreen> createState() => _VisaEstimateScreenState();
}

class _VisaEstimateScreenState extends State<VisaEstimateScreen> {
  int adultCount = 0;
  int childCount = 0;
  bool isLoading = false;

  Map<String, dynamic>? estimate;

  int baseCharge = 0;
  int additionalAdultCharge = 0;
  int additionalChildCharge = 0;

  int topBaseCharge = 0;
  int topAdultCharge = 0;
  int topChildCharge = 0;

  final List<String> paymentMethods = [
    "BPAY",
    "PayPal",
    "VISA",
    "UnionPay",
    "Other",
  ];

  final List<double> surchargeRates = [0.0, 0.0101, 0.014, 0.019, 0.0199];

  int selectedPaymentIndex = 0;

  int get subtotal =>
      baseCharge + additionalAdultCharge + additionalChildCharge;

  double get surchargeAmount => subtotal * surchargeRates[selectedPaymentIndex];

  double get finalTotal => subtotal + surchargeAmount;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _calculateTopSection();
    await _calculateEstimate();
  }

  Future<void> _calculateTopSection() async {
    try {
      final response = await ApiService.getVisaEstimate(
        visaId: widget.visa.id,
        additional18Plus: 1,
        additionalU18: 1,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final lineItems = data['line_items'] as List<dynamic>? ?? [];

        setState(() {
          topBaseCharge =
              lineItems.isNotEmpty ? lineItems[0]['price']?.toInt() ?? 0 : 0;

          topAdultCharge =
              lineItems.length > 1 ? lineItems[1]['price']?.toInt() ?? 0 : 0;

          topChildCharge =
              lineItems.length > 2 ? lineItems[2]['price']?.toInt() ?? 0 : 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _calculateEstimate() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getVisaEstimate(
        visaId: widget.visa.id,
        additional18Plus: adultCount,
        additionalU18: childCount,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final lineItems = data['line_items'] as List<dynamic>? ?? [];

        setState(() {
          estimate = data;

          baseCharge =
              lineItems.isNotEmpty ? lineItems[0]['price']?.toInt() ?? 0 : 0;

          additionalAdultCharge =
              lineItems.length > 1 ? lineItems[1]['price']?.toInt() ?? 0 : 0;

          additionalChildCharge =
              lineItems.length > 2 ? lineItems[2]['price']?.toInt() ?? 0 : 0;

          isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _tableRow({
    required Widget left,
    required Widget right,
    Color? bg,
    bool bold = false,
  }) {
    return Container(
      width: double.infinity,
      color: bg ?? Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.black,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
              child: left,
            ),
          ),
          DefaultTextStyle(
            style: TextStyle(
              color: Colors.black,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
            child: right,
          ),
        ],
      ),
    );
  }

  Widget _counterBox(int value, Function(int) onChanged) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed:
                value > 0
                    ? () async {
                      onChanged(value - 1);
                      await _calculateEstimate();
                    }
                    : null,
            icon: const Icon(Icons.remove),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              onChanged(value + 1);
              await _calculateEstimate();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _paymentSelector() {
    return Wrap(
      spacing: 12,
      children: List.generate(paymentMethods.length, (index) {
        return ChoiceChip(
          label: Text(paymentMethods[index]),
          selected: selectedPaymentIndex == index,
          selectedColor: ThemeConfig.goldenYellow.withValues(alpha: 0.3),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black),
          onSelected: (val) {
            setState(() {
              selectedPaymentIndex = index;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = estimate?['currency'] ?? "AUD";

    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        title: const Text(
          "Visa Estimate",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.black,
      ),*/
      appBar: CommonAppBar(
        titleName: "Visa Estimate",
        matterID: AuthService.selectedMatterId,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsive.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: AppResponsive.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "for any other applicant:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _tableRow(
                          left: const Text("1  Base application charge"),
                          right: Text("$currency $topBaseCharge"),
                        ),
                        _tableRow(
                          left: const Text(
                            "2  Additional applicant charge >= 18",
                          ),
                          right: Text("$currency $topAdultCharge"),
                        ),
                        _tableRow(
                          left: const Text(
                            "3  Additional applicant charge < 18",
                          ),
                          right: Text("$currency $topChildCharge"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "PAYABLE FEES & SURCHARGE",
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _paymentSelector(),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _tableRow(
                          left: const Text("Base application charge"),
                          right: Text("$currency $baseCharge"),
                        ),
                        _tableRow(
                          left: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Additional applicant charge >= 18"),
                              const SizedBox(height: 8),
                              _counterBox(
                                adultCount,
                                (v) => setState(() => adultCount = v),
                              ),
                            ],
                          ),
                          right: Text("$currency $additionalAdultCharge"),
                        ),
                        _tableRow(
                          left: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Additional applicant charge < 18"),
                              const SizedBox(height: 8),
                              _counterBox(
                                childCount,
                                (v) => setState(() => childCount = v),
                              ),
                            ],
                          ),
                          right: Text("$currency $additionalChildCharge"),
                        ),
                        _tableRow(
                          left: const Text("Subtotal"),
                          right: Text("$currency $subtotal"),
                          bold: true,
                        ),
                        _tableRow(
                          left: Text(
                            "Surcharge (+ ${(surchargeRates[selectedPaymentIndex] * 100).toStringAsFixed(2)}%)",
                          ),
                          right: Text(
                            "$currency ${surchargeAmount.toStringAsFixed(2)}",
                          ),
                        ),
                        _tableRow(
                          left: const Text("TOTAL"),
                          right: Text(
                            "$currency ${finalTotal.toStringAsFixed(2)}",
                          ),
                          bold: true,
                          bg: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
