import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/common_app_bar.dart';

class EnglishRequirementSpecifiedTestScoresScreen extends StatelessWidget {
  const EnglishRequirementSpecifiedTestScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testData = _testData();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      /*appBar: AppBar(
        title: const Text(
          "English Requirement for Specified Test Scores",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeConfig.white,
          ),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: ThemeConfig.white),
        centerTitle: true,
      ),*/
      appBar: CommonAppBar(
        titleName: "English Requirement for Specified Test Scores",
        matterID: AuthService.selectedMatterId,
      ),
      body: const EnglishLanguageRequirementsWidget(),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data["item"]}. ${data["testName"]}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            _scoreRow("Score Level 1", data["col2"]),
            const Divider(),
            _scoreRow("Score Level 2", data["col3"]),
            const Divider(),
            _scoreRow("Score Level 3", data["col4"]),
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _testData() {
    return [
      {
        "item": "1",
        "testName": "C1 Advanced",
        "col2": "Overall band score of 161",
        "col3": "Not accepted",
        "col4": "Not accepted",
      },
      {
        "item": "2",
        "testName": "CELPIP General",
        "col2": "Overall band score of 7",
        "col3": "Overall band score of 6",
        "col4": "Overall band score of 5",
      },
      {
        "item": "3",
        "testName": "IELTS Academic",
        "col2": "Average band score of 6.0",
        "col3": "Average band score of 5.5",
        "col4": "Average band score of 5.0",
      },
      {
        "item": "4",
        "testName": "IELTS General Training",
        "col2": "Average band score of 6.0",
        "col3": "Average band score of 5.5",
        "col4": "Average band score of 5.0",
      },
      {
        "item": "5",
        "testName": "LanguageCert Academic",
        "col2": "Overall band score of 61",
        "col3": "Overall band score of 54",
        "col4": "Overall band score of 46",
      },
      {
        "item": "6",
        "testName": "MET",
        "col2": "Overall band score of 53",
        "col3": "Overall band score of 49",
        "col4": "Overall band score of 44",
      },
      {
        "item": "7",
        "testName": "OET",
        "col2": "Overall band score of 1210",
        "col3": "Overall band score of 1090",
        "col4": "Overall band score of 1020",
      },
      {
        "item": "8",
        "testName": "PTE Academic",
        "col2": "Overall band score of 47",
        "col3": "Overall band score of 39",
        "col4": "Overall band score of 31",
      },
      {
        "item": "9",
        "testName": "TOEFL iBT",
        "col2": "Total band score of 67",
        "col3": "Total band score of 51",
        "col4": "Total band score of 37",
      },
    ];
  }
}

class EnglishLanguageRequirementsWidget extends StatefulWidget {
  const EnglishLanguageRequirementsWidget({super.key});

  @override
  State<EnglishLanguageRequirementsWidget> createState() =>
      _EnglishLanguageRequirementsWidgetState();
}

class _EnglishLanguageRequirementsWidgetState
    extends State<EnglishLanguageRequirementsWidget> {
  int selectedTab = 0;
  int selectedLevelTab = 0;

  final List<String> levelTabs = [
    "Functional",
    "Vocational",
    "Competent (0 points)",
    "Proficient (10 points)",
    "Superior (20 points)",
  ];

  @override
  Widget build(BuildContext context) {
    final allData =
    selectedTab == 0 ? tableDataAfterAug2025 : tableDataBeforeAug2025;

    final selectedLevel = levelTabs[selectedLevelTab];
    final data = _filteredDataByLevel(allData, selectedLevel);
    final groupedData = _groupDataByTest(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "English Language Requirements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Specified Test Scores for Visa Requirements",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigoAccent,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.indigo.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("After 7 Aug 2025"),
                  selected: selectedTab == 0,
                  selectedColor: Colors.indigo.shade100,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: selectedTab == 0 ? Colors.indigo : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.indigo.shade100),
                  ),
                  onSelected: (_) => setState(() => selectedTab = 0),
                ),
                ChoiceChip(
                  label: const Text("Before 6 Aug 2025"),
                  selected: selectedTab == 1,
                  selectedColor: Colors.indigo.shade100,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: selectedTab == 1 ? Colors.indigo : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.indigo.shade100),
                  ),
                  onSelected: (_) => setState(() => selectedTab = 1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(levelTabs.length, (index) {
                return ChoiceChip(
                  label: Text(levelTabs[index]),
                  selected: selectedLevelTab == index,
                  selectedColor: Colors.indigo,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedLevelTab == index
                        ? Colors.white
                        : Colors.indigo,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                  onSelected: (_) => setState(() => selectedLevelTab = index),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedData.length,
            itemBuilder: (context, index) {
              final group = groupedData[index];
              return _buildGroupedCard(group);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Department of Home Affairs - English language visa requirements",
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedCard(Map<String, dynamic> group) {
    final List<Map<String, String>> values =
    (group["values"] as List).cast<Map<String, String>>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group["title"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.indigo,
              ),
            ),
            if ((group["subtitle"] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 10),
                child: Text(
                  group["subtitle"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              )
            else
              const SizedBox(height: 10),
            ...values.map(
                  (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${item["label"]}:",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        item["value"] ?? "",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupDataByTest(List<Map<String, dynamic>> data) {
    final List<Map<String, dynamic>> grouped = [];

    final List<Map<String, String>> tests = [
      {"label": "IELTS", "key": "ielts"},
      {"label": "PTE", "key": "pte"},
      {"label": "TOEFL", "key": "toefl"},
      {"label": "C1", "key": "c1"},
      {"label": "OET", "key": "oet"},
      {"label": "CELPIP", "key": "celpip"},
      {"label": "LanguageCert", "key": "languageCert"},
      {"label": "MET", "key": "met"},
    ];

    final bool isFunctional =
        levelTabs[selectedLevelTab] == "Functional" && data.isNotEmpty;

    for (final test in tests) {
      final List<Map<String, String>> values = [];

      if (isFunctional) {
        final row = data.first;
        final value = row[test["key"]];
        if (value != null && value.toString().isNotEmpty) {
          values.add({
            "label": "Score",
            "value": value.toString(),
          });
        }
      } else {
        for (final row in data) {
          if (row["isSection"] == true) continue;
          final value = row[test["key"]];
          if (value != null && value.toString().isNotEmpty) {
            values.add({
              "label": row["component"].toString(),
              "value": value.toString(),
            });
          }
        }
      }

      if (values.isNotEmpty) {
        grouped.add({
          "title": test["label"]!,
          "subtitle": isFunctional ? levelTabs[selectedLevelTab] : "",
          "values": values,
        });
      }
    }

    return grouped;
  }

  List<Map<String, dynamic>> _filteredDataByLevel(
      List<Map<String, dynamic>> allData,
      String selectedLevel,
      ) {
    final List<Map<String, dynamic>> filtered = [];

    for (int i = 0; i < allData.length; i++) {
      final row = allData[i];

      if ((selectedLevel == "Functional" && row["level"] == "Functional") ||
          (selectedLevel != "Functional" &&
              row["isSection"] == true &&
              row["level"] == selectedLevel)) {
        filtered.add(row);

        for (int j = i + 1; j < allData.length; j++) {
          final nextRow = allData[j];
          if (nextRow["isSection"] == true) {
            break;
          }
          filtered.add(nextRow);
        }
        break;
      }
    }

    return filtered;
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
                color: Colors.black87,
              ),
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
    _row(
      "Functional",
      "",
      "Average band score of at least 4.5",
      "Overall band score of at least 24",
      "Total band score of at least 26",
      "Excluded",
      "Overall band score of at least 1020",
      "Overall band score of at least 5",
      "Overall band score of at least 38",
      "Overall band score of at least 38",
    ),

    _section("Vocational"),
    _row("", "Listening", "5.0", "33", "8", "Excluded", "220", "5", "41", "49"),
    _row("", "Reading", "5.0", "36", "8", "Excluded", "240", "5", "44", "47"),
    _row("", "Writing", "5.0", "29", "9", "Excluded", "200", "5", "45", "45"),
    _row("", "Speaking", "5.0", "24", "14", "Excluded", "270", "5", "54", "38"),

    _section("Competent (0 points)"),
    _row("", "Listening", "6.0", "47", "16", "163", "290", "7", "57", "56"),
    _row("", "Reading", "6.0", "48", "16", "163", "310", "7", "60", "55"),
    _row("", "Writing", "6.0", "51", "19", "170", "290", "7", "64", "57"),
    _row("", "Speaking", "6.0", "54", "19", "179", "330", "7", "70", "48"),

    _section("Proficient (10 points)"),
    _row("", "Listening", "7.0", "58", "22", "175", "350", "9", "67", "61"),
    _row("", "Reading", "7.0", "59", "22", "179", "360", "8", "71", "63"),
    _row("", "Writing", "7.0", "69", "26", "193", "380", "10", "78", "74"),
    _row("", "Speaking", "7.0", "76", "24", "194", "360", "8", "82", "59"),

    _section("Superior (20 points)"),
    _row("", "Listening", "8.0", "69", "26", "186", "390", "10", "80", "Excluded"),
    _row("", "Reading", "8.0", "70", "27", "190", "400", "10", "83", "Excluded"),
    _row("", "Writing", "8.0", "85", "30", "210", "420", "12", "89", "Excluded"),
    _row("", "Speaking", "8.0", "88", "28", "208", "400", "10", "89", "Excluded"),
  ];

  List<Map<String, dynamic>> get tableDataBeforeAug2025 => [
    _row(
      "Functional",
      "",
      "Average band score of at least 4.5",
      "Overall band score of at least 30",
      "Total band score of at least 32",
      "Total band score of at least 147",
      "",
      "",
      "",
      "",
    ),

    _section("Vocational"),
    _row("", "Listening", "5.0", "36", "4", "154", "B", "", "", ""),
    _row("", "Reading", "5.0", "36", "4", "154", "B", "", "", ""),
    _row("", "Writing", "5.0", "36", "14", "154", "B", "", "", ""),
    _row("", "Speaking", "5.0", "36", "14", "154", "B", "", "", ""),

    _section("Competent (0 points)"),
    _row("", "Listening", "6.0", "50", "12", "169", "B", "", "", ""),
    _row("", "Reading", "6.0", "50", "13", "169", "B", "", "", ""),
    _row("", "Writing", "6.0", "50", "21", "169", "B", "", "", ""),
    _row("", "Speaking", "6.0", "50", "18", "169", "B", "", "", ""),

    _section("Proficient (10 points)"),
    _row("", "Listening", "7.0", "65", "24", "185", "B", "", "", ""),
    _row("", "Reading", "7.0", "65", "24", "185", "B", "", "", ""),
    _row("", "Writing", "7.0", "65", "27", "185", "B", "", "", ""),
    _row("", "Speaking", "7.0", "65", "23", "185", "B", "", "", ""),

    _section("Superior (20 points)"),
    _row("", "Listening", "8.0", "79", "28", "200", "A", "", "", ""),
    _row("", "Reading", "8.0", "79", "29", "200", "A", "", "", ""),
    _row("", "Writing", "8.0", "79", "30", "200", "A", "", "", ""),
    _row("", "Speaking", "8.0", "79", "26", "200", "A", "", "", ""),
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