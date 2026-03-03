import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class StudentVisaEnglishRequirementScreen extends StatefulWidget {
  const StudentVisaEnglishRequirementScreen({super.key});

  @override
  State<StudentVisaEnglishRequirementScreen> createState() =>
      _StudentVisaEnglishRequirementScreenState();
}

class _StudentVisaEnglishRequirementScreenState
    extends State<StudentVisaEnglishRequirementScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final data =
    selectedTab == 0 ? tableDataAfterAug2025 : tableDataBeforeAug2025;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "English Requirement for Student Visa",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Schedule 1—Required English language test scores",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                        _valueRow(Icons.school, "C1 Advanced", row["c1"]),
                        _valueRow(Icons.school, "CELPIP", row["celpip"]),
                        _valueRow(Icons.school, "IELTS Academic", row["ielts"]),
                        _valueRow(Icons.school, "IELTS General", row["ieltsGeneral"]),
                        _valueRow(Icons.school, "MET", row["met"]),
                        _valueRow(Icons.school, "OET", row["oet"]),
                        _valueRow(Icons.school, "PTE Academic", row["pte"]),
                        _valueRow(Icons.school, "LanguageCert", row["languageCert"]),
                        _valueRow(Icons.school, "TOEFL iBT", row["toefl"]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87),
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

  // Data after Aug 2025
  List<Map<String, dynamic>> get tableDataAfterAug2025 => [
    //_section("Functional"),
    _row("C1 Advanced", "Overall band score of 161", "", "", "", "", "", "", "", ""),
    _row("CELPIP General", "Overall band score of 7", "Overall band score of 6",
        "Overall band score of 5", "", "", "", "", "", ""),
    _row("IELTS Academic", "Average band score of 6.0", "Average band score of 5.5",
        "Average band score of 5.0", "", "", "", "", "", ""),
    _row("IELTS General Training", "Average band score of 6.0",
        "Average band score of 5.5", "Average band score of 5.0", "", "", "", "", "", ""),
    _row("LanguageCert Academic", "Overall band score of 61", "Overall band score of 54",
        "Overall band score of 46", "", "", "", "", "", ""),
    _row("MET", "Overall band score of 53", "Overall band score of 49", "Overall band score of 44",
        "", "", "", "", "", ""),
    _row("OET", "Overall band score of 1210", "Overall band score of 1090",
        "Overall band score of 1020", "", "", "", "", "", ""),
    _row("PTE Academic", "Overall band score of 47", "Overall band score of 39",
        "Overall band score of 31", "", "", "", "", "", ""),
    _row("TOEFL iBT", "Total band score of 67", "Total band score of 51",
        "Total band score of 37", "", "", "", "", "", ""),
  ];

  // Data before Aug 2025
  List<Map<String, dynamic>> get tableDataBeforeAug2025 => [
    _section("Functional"),
    _row("C1 Advanced", "Overall band score of 160", "", "", "", "", "", "", "", ""),
    _row("CELPIP General", "Overall band score of 6", "Overall band score of 5",
        "Overall band score of 4", "", "", "", "", "", ""),
    _row("IELTS Academic", "Average band score of 5.5", "Average band score of 5.0",
        "Average band score of 4.5", "", "", "", "", "", ""),
    _row("IELTS General Training", "Average band score of 5.5", "Average band score of 5.0",
        "Average band score of 4.5", "", "", "", "", "", ""),
    _row("LanguageCert Academic", "Overall band score of 60", "Overall band score of 50",
        "Overall band score of 45", "", "", "", "", "", ""),
    _row("MET", "Overall band score of 52", "Overall band score of 48", "Overall band score of 43",
        "", "", "", "", "", ""),
    _row("OET", "Overall band score of 1200", "Overall band score of 1080",
        "Overall band score of 1010", "", "", "", "", "", ""),
    _row("PTE Academic", "Overall band score of 46", "Overall band score of 38",
        "Overall band score of 30", "", "", "", "", "", ""),
    _row("TOEFL iBT", "Total band score of 66", "Total band score of 50",
        "Total band score of 36", "", "", "", "", "", ""),
  ];

  static Map<String, dynamic> _row(
      String level,
      String ielts,
      String pte,
      String toefl,
      String c1,
      String oet,
      String celpip,
      String languageCert,
      String met,
      String ieltsGeneral) {
    return {
      "level": level,
      "ielts": ielts,
      "pte": pte,
      "toefl": toefl,
      "c1": c1,
      "oet": oet,
      "celpip": celpip,
      "languageCert": languageCert,
      "met": met,
      "ieltsGeneral": ieltsGeneral,
      "component": "",
      "isSection": false,
    };
  }

  static Map<String, dynamic> _section(String title) {
    return {"level": title, "isSection": true};
  }
}