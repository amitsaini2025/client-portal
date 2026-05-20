import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/common_app_bar.dart';

class EnglishRequirementFor485TemporaryGraduateVisaTRScreen
    extends StatefulWidget {
  const EnglishRequirementFor485TemporaryGraduateVisaTRScreen({super.key});

  @override
  State<EnglishRequirementFor485TemporaryGraduateVisaTRScreen> createState() =>
      _EnglishRequirementFor485TemporaryGraduateVisaTRScreenState();
}

class _EnglishRequirementFor485TemporaryGraduateVisaTRScreenState
    extends State<EnglishRequirementFor485TemporaryGraduateVisaTRScreen> {
  int selectedTab = 0;

  final tabs = ["After 7 Aug 2025", "Before 6 Aug 2025"];

  final tests = [
    "CELPIP",
    "IELTS Academic",
    "IELTS General Training",
    "PTE Academic",
    "TOEFL iBT",
    "OET",
    "LanguageCert",
    "MET",
    "C1 Advanced",
  ];

  String selectedTest = "CELPIP";

  @override
  Widget build(BuildContext context) {
    final data = selectedTab == 0 ? _afterAug2025Data() : _beforeAug2025Data();
    final filtered = _filterByTest(data, selectedTest);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      /*appBar: AppBar(
        title: const Text(
          "English Requirement for 485 Temporary Graduate Visa (TR)",
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
        titleName: "English Requirement for 485 Temporary Graduate Visa (TR)",
        matterID: AuthService.selectedMatterId,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsive.maxContentWidth,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                const SizedBox(height: 12),

                _buildTabs(),

                const SizedBox(height: 10),

                _buildTestFilter(),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    padding: AppResponsive.horizontalPadding(context),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildCard(filtered[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: List.generate(tabs.length, (index) {
          return ChoiceChip(
            label: Text(tabs[index]),
            selected: selectedTab == index,
            selectedColor: Colors.indigo.shade100,
            backgroundColor: Colors.grey.shade100,
            labelStyle: TextStyle(
              color: selectedTab == index ? Colors.indigo : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.indigo.shade100),
            ),
            onSelected: (_) => setState(() => selectedTab = index),
          );
        }),
      ),
    );
  }

  Widget _buildTestFilter() {
    return Padding(
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
          children: List.generate(tests.length, (index) {
            final test = tests[index];
            return ChoiceChip(
              label: Text(test),
              selected: selectedTest == test,
              selectedColor: Colors.indigo,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedTest == test ? Colors.white : Colors.indigo,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.indigo.shade200),
              ),
              onSelected: (_) => setState(() => selectedTest = test),
            );
          }),
        ),
      ),
    );
  }

  /*Widget _buildTestFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.indigo.shade200),
        ),
        child: SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tests.length,
            itemBuilder: (_, i) {
              final test = tests[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(test),
                  selected: selectedTest == test,
                  selectedColor: Colors.indigo,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedTest == test ? Colors.white : Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                  onSelected: (_) => setState(() => selectedTest = test),
                ),
              );
            },
          ),
        ),
      ),
    );
  }*/

  Widget _buildCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                item["skill"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                item["value"]!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _filterByTest(
    List<Map<String, dynamic>> data,
    String test,
  ) {
    return data
        .map(
          (row) => {
            "skill": row["skill"].toString(),
            "value": (row[test] ?? "-").toString(),
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _afterAug2025Data() {
    return [
      {
        "skill": "Overall",
        "IELTS Academic": "6.5",
        "IELTS General Training": "6.5",
        "PTE Academic": "55",
        "TOEFL iBT": "81",
        "OET": "1310",
        "CELPIP": "8",
        "LanguageCert": "67",
        "MET": "58",
        "C1 Advanced": "Not accepted",
      },
      {
        "skill": "Listening",
        "IELTS Academic": "5.5",
        "IELTS General Training": "5.5",
        "PTE Academic": "40",
        "TOEFL iBT": "12",
        "OET": "260",
        "CELPIP": "6",
        "LanguageCert": "49",
        "MET": "53",
        "C1 Advanced": "Not accepted",
      },
      {
        "skill": "Reading",
        "IELTS Academic": "5.5",
        "IELTS General Training": "5.5",
        "PTE Academic": "42",
        "TOEFL iBT": "12",
        "OET": "280",
        "CELPIP": "6",
        "LanguageCert": "54",
        "MET": "51",
        "C1 Advanced": "Not accepted",
      },
      {
        "skill": "Writing",
        "IELTS Academic": "5.5",
        "IELTS General Training": "5.5",
        "PTE Academic": "41",
        "TOEFL iBT": "14",
        "OET": "260",
        "CELPIP": "6",
        "LanguageCert": "56",
        "MET": "51",
        "C1 Advanced": "Not accepted",
      },
      {
        "skill": "Speaking",
        "IELTS Academic": "5.5",
        "IELTS General Training": "5.5",
        "PTE Academic": "39",
        "TOEFL iBT": "17",
        "OET": "310",
        "CELPIP": "6",
        "LanguageCert": "62",
        "MET": "43",
        "C1 Advanced": "Not accepted",
      },
    ];
  }

  List<Map<String, dynamic>> _beforeAug2025Data() {
    return [
      {
        "skill": "Overall",
        "IELTS Academic": "6.5",
        "PTE Academic": "57",
        "TOEFL iBT": "83",
        "OET": "B",
        "C1 Advanced": "176",
      },
      {
        "skill": "Listening",
        "IELTS Academic": "5.5",
        "PTE Academic": "43",
        "TOEFL iBT": "7",
        "OET": "B",
        "C1 Advanced": "162",
      },
      {
        "skill": "Reading",
        "IELTS Academic": "5.5",
        "PTE Academic": "48",
        "TOEFL iBT": "8",
        "OET": "B",
        "C1 Advanced": "162",
      },
      {
        "skill": "Writing",
        "IELTS Academic": "5.5",
        "PTE Academic": "51",
        "TOEFL iBT": "18",
        "OET": "B",
        "C1 Advanced": "162",
      },
      {
        "skill": "Speaking",
        "IELTS Academic": "5.5",
        "PTE Academic": "42",
        "TOEFL iBT": "16",
        "OET": "B",
        "C1 Advanced": "162",
      },
    ];
  }
}
