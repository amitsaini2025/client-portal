import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../widgets/common_app_bar.dart';

class EnglishRequirementForStudentVisaScreen extends StatefulWidget {
  const EnglishRequirementForStudentVisaScreen({super.key});

  @override
  State<EnglishRequirementForStudentVisaScreen> createState() =>
      _EnglishRequirementForStudentVisaScreenState();
}

class _EnglishRequirementForStudentVisaScreenState
    extends State<EnglishRequirementForStudentVisaScreen> {
  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'C1',
    'CELPIP',
    'IELTS',
    'LANGUAGECERT',
    'MET',
    'OET',
    'PTE',
    'TOEFL',
  ];

  final List<Map<String, dynamic>> data = const [
    {
      "item": "1",
      "testName": "C1 Advanced",
      "col2": "Overall band score of 161",
      "col3":
          "Not accepted for purposes of subclause 500.213(1) of Schedule 2 to the Regulations.",
      "col4":
          "Not accepted for purposes of subclause 500.213(1) of Schedule 2 to the Regulations.",
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
      "testName": "LANGUAGECERT Academic",
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

  @override
  Widget build(BuildContext context) {
    final filteredData =
        selectedFilter == 'All'
            ? data
            : data
                .where(
                  (e) => e['testName'].toString().toUpperCase().contains(
                    selectedFilter,
                  ),
                )
                .toList();

    return Scaffold(
      /*appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "English Requirement For Student Visa",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),*/
      appBar: CommonAppBar(
        titleName: "English Requirement For Student Visa",
        matterID: AuthService.selectedMatterId,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

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
                children: List.generate(filters.length, (index) {
                  final isSelected = selectedFilter == filters[index];

                  return ChoiceChip(
                    label: Text(filters[index]),
                    selected: isSelected,
                    selectedColor: Colors.indigo,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.indigo,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.indigo.shade200),
                    ),
                    onSelected: (_) {
                      setState(() => selectedFilter = filters[index]);
                    },
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                return _buildCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data["item"]}. ${data["testName"]}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _row("Minimum Score", data["col2"]),
            const Divider(),
            _row("Condition 1", data["col3"]),
            const Divider(),
            _row("Condition 2", data["col4"]),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
