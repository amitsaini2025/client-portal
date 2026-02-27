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
          isLoading = false;
        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _counter({
    required String title,
    required int value,
    required Function(int) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(value.toString(), style: const TextStyle(fontSize: 16)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _lineItem(item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("${item['product']} (x${item['quantity']})")),
          Text("${estimate!['currency']} ${item['price']}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 14),

            _counter(
              title: "Additional Applicants (18+)",
              value: adultCount,
              onChanged: (v) => setState(() => adultCount = v),
            ),

            _counter(
              title: "Additional Applicants (<18)",
              value: childCount,
              onChanged: (v) => setState(() => childCount = v),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _calculateEstimate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.goldenYellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Calculate Estimate"),
              ),
            ),

            const SizedBox(height: 20),

            if (estimate != null) ...[
              const Text(
                "Breakdown",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children:
                  (estimate!['line_items'] as List)
                      .map((e) => _lineItem(e))
                      .toList(),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ThemeConfig.goldenYellow.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      estimate!['price_starts_from'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                estimate!['disclaimer'],
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}