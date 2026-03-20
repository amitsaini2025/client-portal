import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class EnglishRequirementFor485TemporaryGraduateVisaTRScreen extends StatefulWidget {
  const EnglishRequirementFor485TemporaryGraduateVisaTRScreen({super.key});

  @override
  State<EnglishRequirementFor485TemporaryGraduateVisaTRScreen> createState() =>
      _EnglishRequirementFor485TemporaryGraduateVisaTRScreenState();
}

class _EnglishRequirementFor485TemporaryGraduateVisaTRScreenState
    extends State<EnglishRequirementFor485TemporaryGraduateVisaTRScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final data =
    selectedTab == 0 ? tableDataAfterAug2025 : tableDataBeforeAug2025;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "485 Temporary Graduate Visa (TR)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeConfig.white,
          ),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: ThemeConfig.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Temporary Graduate Visa (Subclass 485)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Specified Test Scores for English Requirement",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigoAccent,
                  ),
                ),
              ],
            ),
          ),
*/
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("After 7 Aug 2025"),
                  selected: selectedTab == 0,
                  selectedColor: Colors.indigo.shade100,
                  onSelected: (_) => setState(() => selectedTab = 0),
                ),
                ChoiceChip(
                  label: const Text("Before 6 Aug 2025"),
                  selected: selectedTab == 1,
                  selectedColor: Colors.indigo.shade100,
                  onSelected: (_) => setState(() => selectedTab = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),*/

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final row = data[index];

                if (row["isSection"] == true) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        row["level"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  shadowColor: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (row["level"] != "")
                          Text(
                            row["level"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.indigo,
                            ),
                          ),
                        if (row["component"] != "")
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 8),
                            child: Text(
                              row["component"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        _valueRow(Icons.school, "IELTS", row["ielts"]),
                        _valueRow(Icons.school, "PTE", row["pte"]),
                        _valueRow(Icons.school, "TOEFL", row["toefl"]),
                        _valueRow(Icons.language, "C1", row["c1"]),
                        _valueRow(Icons.language, "OET", row["oet"]),
                        _valueRow(Icons.language, "CELPIP", row["celpip"]),
                        _valueRow(Icons.language, "LanguageCert", row["languageCert"]),
                        _valueRow(Icons.school, "MET", row["met"]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          /*const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              "Department of Home Affairs - English language visa requirements",
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _valueRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.indigo.shade300),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get tableDataAfterAug2025 => [
    _row("Functional", "", "6.5", "55", "81", "", "1310", "8", "", ""),
    _section("Vocational"),
    _row("", "Listening", "5.5", "40", "12", "", "260", "6", "", ""),
    _row("", "Reading", "5.5", "42", "12", "", "280", "6", "", ""),
    _row("", "Writing", "5.5", "41", "14", "", "260", "6", "", ""),
    _row("", "Speaking", "5.5", "39", "17", "", "310", "6", "", ""),
  ];

  List<Map<String, dynamic>> get tableDataBeforeAug2025 => [
    _row("Functional", "", "6.5", "57", "83", "176", "B", "", "", ""),
    _section("Vocational"),
    _row("", "Listening", "5.5", "43", "7", "162", "", "", "", ""),
    _row("", "Reading", "5.5", "48", "8", "162", "", "", "", ""),
    _row("", "Writing", "5.5", "51", "18", "162", "", "", "", ""),
    _row("", "Speaking", "5.5", "42", "16", "162", "", "", "", ""),
  ];

  static Map<String, dynamic> _row(
      String level,
      String component,
      String ielts,
      String pte,
      String toefl,
      String c1,
      String oet,
      String celpip,
      String languageCert,
      String met,
      ) {
    return {
      "level": level,
      "component": component,
      "ielts": ielts,
      "pte": pte,
      "toefl": toefl,
      "c1": c1,
      "oet": oet,
      "celpip": celpip,
      "languageCert": languageCert,
      "met": met,
      "isSection": false,
    };
  }

  static Map<String, dynamic> _section(String title) {
    return {"level": title, "isSection": true};
  }
}