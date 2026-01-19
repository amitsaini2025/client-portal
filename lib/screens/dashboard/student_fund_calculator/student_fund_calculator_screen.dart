import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';

class StudentFundCalculatorScreen extends StatefulWidget {
  const StudentFundCalculatorScreen({super.key});

  @override
  State<StudentFundCalculatorScreen> createState() =>
      _StudentFundCalculatorScreenState();
}

class _StudentFundCalculatorScreenState
    extends State<StudentFundCalculatorScreen> {
  bool loading = true;
  Map<String, dynamic>? data;

  final _courseCtrl = TextEditingController();
  final _tuitionCtrl = TextEditingController();
  final _travelCtrl = TextEditingController(text: "2000");

  Map<String, dynamic>? partner;
  Map<String, dynamic>? children;
  Map<String, dynamic>? schoolChildren;
  Map<String, dynamic>? accommodation;
  Map<String, dynamic>? oshc;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      final res = await ApiService.getStudentCalcLists();
      if (res['success'] == true) {
        setState(() {
          data = res['data'];
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Fund Calculator",
            style: TextStyle(color: Colors.white)),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: loading || data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Calculate Your Financial Requirements",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      _numberField("Course Duration (years)",
                          "Enter course duration", _courseCtrl),

                      _numberField("Annual Tuition Fee (AUD)",
                          "Enter annual tuition fee", _tuitionCtrl,
                          helper:
                          "For visa purposes: Max 12 months of fees required"),

                      _livingCostBox(),

                      _dropdown(
                          "Partner/Spouse Accompanying You",
                          data!['partner_spouse_options'],
                          partner,
                              (v) => setState(() => partner = v)),

                      _dropdown(
                          "Number of Dependent Children",
                          data!['dependent_children_options'],
                          children,
                              (v) => setState(() => children = v)),

                      _dropdown(
                          "Number of School-age Children",
                          data!['school_age_children_options'],
                          schoolChildren,
                              (v) => setState(() => schoolChildren = v)),

                      _dropdown(
                          "Additional Accommodation Costs",
                          data!['additional_accommodation_options'],
                          accommodation,
                              (v) => setState(() => accommodation = v)),

                      _dropdown("Overseas Student Health Cover (OSHC)",
                          data!['oshc_options'], oshc,
                              (v) => setState(() => oshc = v)),

                      _numberField("Travel Expenses (Return flights)",
                          "Include return airfare", _travelCtrl),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text("Calculate Requirements",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _incomeBox(),
                      const SizedBox(height: 16),
                      _notesBox(),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _numberField(String label, String hint, TextEditingController ctrl,
      {String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: hint, border: const OutlineInputBorder()),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(helper,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          )
      ]),
    );
  }

  Widget _dropdown(String label, List list, Map<String, dynamic>? value,
      ValueChanged<Map<String, dynamic>?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: value,
          isExpanded: true,
          hint: const Text("Select"),
          items: list
              .map<DropdownMenuItem<Map<String, dynamic>>>(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(e['label']),
            ),
          )
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        )
      ]),
    );
  }

  Widget _livingCostBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFEFF5FF),
          borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Annual Living Cost (Primary Student)",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text("AUD \$${data!['fixed_rates']['annual_living_cost_primary_student']}",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue)),
        const Text("Official rate (May 2024)",
            style: TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _incomeBox() {
    final income = data!['income_evidence_requirements'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Alternative: Income Evidence",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Without Dependants: AUD \$${income['without_dependants']}",
            style: const TextStyle(color: Colors.green)),
        Text("With Dependants: AUD \$${income['with_dependants']}",
            style: const TextStyle(color: Colors.green)),
        const SizedBox(height: 4),
        Text(income['note'],
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _notesBox() {
    final notes = data!['important_notes'] as List;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Important Notes",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...notes.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Text("• "),
              Expanded(child: Text(e, style: const TextStyle(fontSize: 12)))
            ]),
          ))
        ]),
      ),
    );
  }

  // ================= LOGIC =================

  void _calculate() async {
    if (_courseCtrl.text.isEmpty || _tuitionCtrl.text.isEmpty) {
      _showError("Please enter course duration and tuition fee");
      return;
    }

    final payload = {
      "course_duration": int.parse(_courseCtrl.text),
      "annual_tuition_fee": int.parse(_tuitionCtrl.text),
      "partner_spouse": partner?['value'] ?? 0,
      "dependent_children": children?['value'] ?? 0,
      "school_age_children": schoolChildren?['value'] ?? 0,
      "additional_accommodation": accommodation?['value'] ?? 0,
      "oshc_type": oshc?['value'] ?? 0,
      "travel_expenses": int.tryParse(_travelCtrl.text) ?? 0,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await ApiService.calculateStudentFund(payload: payload);
      Navigator.pop(context);

      if (res['success'] == true) {
        _showResult(res['data']);
      } else {
        _showError("Calculation failed");
      }
    } catch (e) {
      Navigator.pop(context);
      _showError(e.toString());
    }
  }

  void _showResult(Map<String, dynamic> d) {
    final breakdown = d['breakdown'];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Text("Financial Requirements",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text("AUD \$${d['total_financial_capacity_required']}",
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ...breakdown.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text(e.value['label'])),
                  Text("AUD \$${e.value['amount']}")
                ]),
              );
            }),

            const SizedBox(height: 16),

            Text(
              "OSHC Total: AUD \$${d['oshc']['total_cost']}",
              style: const TextStyle(color: Colors.green),
            ),

            const SizedBox(height: 12),

            Text(
              "Income Alternative: AUD \$${d['income_evidence_alternative']['required_annual_income']}",
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close")),
            )
          ]),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
