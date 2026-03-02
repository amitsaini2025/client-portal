import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class EnglishRequirementSpecifiedTestScoresScreen extends StatelessWidget {
  const EnglishRequirementSpecifiedTestScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testData = _testData();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: testData.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: EnglishLanguageRequirementsWidget(),
            );
          }

          final data = testData[index - 1];
          return _buildCard(data);
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data["item"]}. ${data["testName"]}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
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

  @override
  Widget build(BuildContext context) {
    final data =
    selectedTab == 0 ? tableDataAfterAug2025 : tableDataBeforeAug2025;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "English Language Requirements Specified Test Scores",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),

        /// MOBILE FRIENDLY TAB SWITCH
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text("After 7 Aug 2025"),
              selected: selectedTab == 0,
              onSelected: (_) => setState(() => selectedTab = 0),
            ),
            ChoiceChip(
              label: const Text("Before 6 Aug 2025"),
              selected: selectedTab == 1,
              onSelected: (_) => setState(() => selectedTab = 1),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// ONLY HORIZONTAL SCROLL
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 14,
            dataRowMinHeight: 36,
            headingRowHeight: 40,
            border: TableBorder.all(color: Colors.grey.shade300),
            headingRowColor:
            MaterialStateProperty.all(Colors.grey.shade200),
            columns: const [
              DataColumn(label: Text("Level", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("Component", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("IELTS", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("PTE", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("TOEFL", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("C1", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("OET", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("CELPIP", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("LANG CERT", style: TextStyle(fontSize: 12))),
              DataColumn(label: Text("MET", style: TextStyle(fontSize: 12))),
            ],
            rows: data.map((row) {
              if (row["isSection"] == true) {
                return DataRow(
                  cells: List.generate(
                    10,
                        (index) => DataCell(
                      index == 0
                          ? Text(
                        row["level"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                          : const SizedBox(),
                    ),
                  ),
                );
              }

              return DataRow(
                cells: [
                  _cell(row["level"]),
                  _cell(row["component"]),
                  _cell(row["ielts"]),
                  _cell(row["pte"]),
                  _cell(row["toefl"]),
                  _cell(row["c1"]),
                  _cell(row["oet"]),
                  _cell(row["celpip"]),
                  _cell(row["languageCert"]),
                  _cell(row["met"]),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Department of Home Affairs - English language visa requirements",
          style: TextStyle(
            color: Colors.indigo,
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  DataCell _cell(dynamic value) {
    return DataCell(
      Text(
        value ?? "",
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  // ---------- FULL DATA (UNCHANGED) ----------

  List<Map<String, dynamic>> get tableDataAfterAug2025 => [
    _row("Functional", "", "Average band score at least 4.5", "Overall 24",
        "Total 26", "Excluded", "1020", "5", "38", "38"),
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
    _row("Functional", "", "Average band 4.5", "Overall 30", "32", "147", "", "", "", ""),
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