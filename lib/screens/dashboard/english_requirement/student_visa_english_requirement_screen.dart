import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class StudentVisaEnglishRequirementScreen extends StatelessWidget {
  const StudentVisaEnglishRequirementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("English Requirement for Student Visa"),
        backgroundColor: ThemeConfig.goldenYellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Schedule 1—Required English language test scores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade400),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          _headerRow(["Item", "Test name", "Column 2", "Column 3", "Column 4"]),
          _dataRow([
            "1",
            "C1 Advanced",
            "Overall band score of 161",
            "Not accepted",
            "Not accepted"
          ]),
          _dataRow([
            "2",
            "CELPIP General",
            "Overall band score of 7",
            "Overall band score of 6",
            "Overall band score of 5"
          ]),
          _dataRow([
            "3",
            "IELTS Academic",
            "Average band score of 6.0",
            "Average band score of 5.5",
            "Average band score of 5.0"
          ]),
          _dataRow([
            "4",
            "IELTS General Training",
            "Average band score of 6.0",
            "Average band score of 5.5",
            "Average band score of 5.0"
          ]),
          _dataRow([
            "5",
            "LanguageCert Academic",
            "Overall band score of 61",
            "Overall band score of 54",
            "Overall band score of 46"
          ]),
          _dataRow([
            "6",
            "MET",
            "Overall band score of 53",
            "Overall band score of 49",
            "Overall band score of 44"
          ]),
          _dataRow([
            "7",
            "OET",
            "Overall band score of 1210",
            "Overall band score of 1090",
            "Overall band score of 1020"
          ]),
          _dataRow([
            "8",
            "PTE Academic",
            "Overall band score of 47",
            "Overall band score of 39",
            "Overall band score of 31"
          ]),
          _dataRow([
            "9",
            "TOEFL iBT",
            "Total band score of 67",
            "Total band score of 51",
            "Total band score of 37"
          ]),
        ],
      ),
    );
  }

  TableRow _headerRow(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: cells
          .map(
            (e) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            e,
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      )
          .toList(),
    );
  }

  TableRow _dataRow(List<String> cells) {
    return TableRow(
      children: cells
          .map(
            (e) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text(e),
        ),
      )
          .toList(),
    );
  }
}