import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class StudentVisaEnglishRequirementScreen extends StatelessWidget {
  const StudentVisaEnglishRequirementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _testData().length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: const Text(
                "Schedule 1—Required English language test scores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }
          final data = _testData()[index - 1];
          return _buildCard(data);
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data["item"]}. ${data["testName"]}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
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
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 6,
            child: Text(value, style: const TextStyle(fontSize: 14)),
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