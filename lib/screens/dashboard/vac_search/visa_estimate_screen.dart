import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import '../../../models/visa_search/visa_model.dart';
import '../../../services/api_service.dart';

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

  int get subtotal => baseCharge + additionalAdultCharge + additionalChildCharge;

  Future<void> _calculateEstimate() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getVisaEstimate(
        visaId: widget.visa.id,
        additional18Plus: adultCount,
        additionalU18: childCount,
      );

      if (response['success'] == true) {
        setState(() {
          estimate = response['data'];

          // Parse line items
          final lineItems = estimate?['line_items'] as List<dynamic>? ?? [];
          baseCharge = lineItems.isNotEmpty
              ? lineItems[0]['price']?.toInt() ?? 0
              : 0;
          additionalAdultCharge = lineItems.length > 1
              ? lineItems[1]['price']?.toInt() ?? 0
              : 0;
          additionalChildCharge = lineItems.length > 2
              ? lineItems[2]['price']?.toInt() ?? 0
              : 0;

          isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black,
              ),
              child: left,
            ),
          ),
          const SizedBox(width: 8),
          DefaultTextStyle(
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black,
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
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              value.toString(),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _verticalChargeSection({
    required String title,
    required int count,
    required int charge,
    required Function(int) onChanged,
    required String currency,
  }) {
    return _tableRow(
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          _counterBox(count, onChanged),
        ],
      ),
      right: Text(
        "$currency $charge",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = estimate?['currency'] ?? "AUD";
    final lineItems = estimate?['line_items'] as List<dynamic>? ?? [];
    final total = estimate?['total']?.toInt() ?? subtotal;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Visa Estimate"),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.visa.label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            const Text(
              "PAYABLE FEES & SURCHARGE",
              style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _tableRow(
                    left: const Text(
                      "Base application charge",
                      style: TextStyle(fontSize: 16),
                    ),
                    right: Text("$currency $baseCharge"),
                  ),

                  _verticalChargeSection(
                    title: "Additional applicant charge >= 18",
                    count: adultCount,
                    charge: additionalAdultCharge,
                    currency: currency,
                    onChanged: (v) {
                      setState(() {
                        adultCount = v;
                        additionalAdultCharge = 4685 * v; // from response
                      });
                    },
                  ),

                  _verticalChargeSection(
                    title: "Additional applicant charge < 18",
                    count: childCount,
                    charge: additionalChildCharge,
                    currency: currency,
                    onChanged: (v) {
                      setState(() {
                        childCount = v;
                        additionalChildCharge = 7035 ~/ 3 * v; // each child
                      });
                    },
                  ),

                  ...lineItems.skip(3).map((item) {
                    return _tableRow(
                      left: Text("${item['product']} x${item['quantity']}"),
                      right: Text("$currency ${item['price']}"),
                    );
                  }).toList(),

                  _tableRow(
                    left: const Text("TOTAL"),
                    right: Text("$currency $total"),
                    bold: true,
                    bg: Colors.grey.shade300,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _calculateEstimate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.goldenYellow,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Calculate Estimate",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 18),

            if (estimate != null)
              Text(
                estimate!['disclaimer'] ?? "",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}