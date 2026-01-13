import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class PRCalculatorScreen extends StatefulWidget {
  const PRCalculatorScreen({super.key});

  @override
  State<PRCalculatorScreen> createState() => _PRCalculatorScreenState();
}

class _PRCalculatorScreenState extends State<PRCalculatorScreen> {
  String? age;
  String? english;
  String? education;
  String? overseasExp;
  String? ausExp;
  String? partner;

  bool australianStudy = false;
  bool specialistEducation = false;
  bool communityLanguage = false;
  bool professionalYear = false;
  bool regionalStudy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PR Calculator',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Calculate Your Points",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _infoBox(),
                    const SizedBox(height: 24),

                    _dropdown(
                      label: "Age (at time of invitation)",
                      value: age,
                      items: ["18–24", "25–32", "33–39", "40–44", "45+"],
                      onChanged: (v) => setState(() => age = v),
                    ),

                    _dropdown(
                      label: "English Language Proficiency",
                      value: english,
                      helper:
                      "IELTS 6/PTE 50 = Competent, IELTS 7/PTE 65 = Proficient, IELTS 8/PTE 79 = Superior",
                      items: [
                        "Competent English",
                        "Proficient English",
                        "Superior English",
                      ],
                      onChanged: (v) => setState(() => english = v),
                    ),

                    _dropdown(
                      label: "Educational Qualifications",
                      value: education,
                      helper:
                      "Qualification must be recognized by the relevant assessing authority",
                      items: [
                        "Diploma or Trade Qualification",
                        "Bachelor Degree",
                        "Master Degree",
                        "PhD",
                      ],
                      onChanged: (v) => setState(() => education = v),
                    ),

                    _dropdown(
                      label: "Skilled Employment Experience (Overseas)",
                      value: overseasExp,
                      items: [
                        "Less than 3 years",
                        "3–4 years",
                        "5–7 years",
                        "8+ years",
                      ],
                      onChanged: (v) => setState(() => overseasExp = v),
                    ),

                    _dropdown(
                      label: "Skilled Employment Experience (Australia)",
                      value: ausExp,
                      items: [
                        "Less than 1 year",
                        "1–2 years",
                        "3–4 years",
                        "5–7 years",
                        "8+ years",
                      ],
                      onChanged: (v) => setState(() => ausExp = v),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Additional Points",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    _checkbox(
                      "Australian study requirement (5 points)",
                      australianStudy,
                          (v) => setState(() => australianStudy = v),
                    ),
                    _checkbox(
                      "Specialist Education Qualification (10 points)",
                      specialistEducation,
                          (v) => setState(() => specialistEducation = v),
                      subtitle:
                      "Master's by research or PhD from Australian institution in STEMM field",
                    ),
                    _checkbox(
                      "Credentialed Community Language (5 points)",
                      communityLanguage,
                          (v) => setState(() => communityLanguage = v),
                    ),
                    _checkbox(
                      "Professional Year in Australia (5 points)",
                      professionalYear,
                          (v) => setState(() => professionalYear = v),
                    ),
                    _checkbox(
                      "Regional study (5 points)",
                      regionalStudy,
                          (v) => setState(() => regionalStudy = v),
                    ),

                    const SizedBox(height: 24),
                    _dropdown(
                      label: "Partner / Spouse Status",
                      value: partner,
                      helper:
                      "Partner skills require positive skills assessment and competent English",
                      items: [
                        "No partner included in application (0 points)",
                        "Partner with competent English (5 points)",
                        "Partner with skills assessment (10 points)",
                      ],
                      onChanged: (v) => setState(() => partner = v),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Calculate My Points",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.blue.shade700, width: 4),
        ),
      ),
      child: const Text(
        "Note: This calculator shows your base points. Additional points "
            "(5 for State/Territory nomination or 15 for regional nomination) "
            "may apply when you receive an invitation.",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    String? helper,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true, // ⭐ prevents overflow
            hint: const Text("Select"),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(e, overflow: TextOverflow.ellipsis),
              ),
            )
                .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _checkbox(
      String title,
      bool value,
      ValueChanged<bool> onChanged, {
        String? subtitle,
      }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
