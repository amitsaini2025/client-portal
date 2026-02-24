import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class TemporaryGraduateVisaTRScreen extends StatelessWidget {
  const TemporaryGraduateVisaTRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("485 Temporary Graduate Visa (TR)"),
        backgroundColor: ThemeConfig.goldenYellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle(
                "Acceptable minimum scores – Test taken on or after 7 August 2025"),
            const SizedBox(height: 10),
            _buildAfter2025Table(),
            const SizedBox(height: 30),
            _sectionTitle(
                "Acceptable minimum scores – Test taken on or before 6 August 2025"),
            const SizedBox(height: 10),
            _buildBefore2025Table(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildAfter2025Table() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          _headerRow([
            "Test Sub-skill",
            "C1 Advanced",
            "CELPIP",
            "IELTS Academic",
            "IELTS GT",
            "LanguageCert",
            "MET",
            "OET",
            "PTE",
            "TOEFL"
          ]),
          _dataRow([
            "Overall",
            "Not accepted",
            "8",
            "6.5",
            "6.5",
            "67",
            "58",
            "1310",
            "55",
            "81"
          ]),
          _dataRow([
            "Listening",
            "Not accepted",
            "6",
            "5.5",
            "5.5",
            "49",
            "53",
            "260",
            "40",
            "12"
          ]),
          _dataRow([
            "Reading",
            "Not accepted",
            "6",
            "5.5",
            "5.5",
            "54",
            "51",
            "280",
            "42",
            "12"
          ]),
          _dataRow([
            "Writing",
            "Not accepted",
            "6",
            "5.5",
            "5.5",
            "56",
            "51",
            "260",
            "41",
            "14"
          ]),
          _dataRow([
            "Speaking",
            "Not accepted",
            "6",
            "5.5",
            "5.5",
            "62",
            "43",
            "310",
            "39",
            "17"
          ]),
        ],
      ),
    );
  }

  Widget _buildBefore2025Table() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          _headerRow([
            "Test Sub-skill",
            "CAE/C1",
            "IELTS",
            "OET",
            "PTE",
            "TOEFL"
          ]),
          _dataRow(["Overall", "176", "6.5", "B", "57", "83"]),
          _dataRow(["Listening", "162", "5.5", "B", "43", "7"]),
          _dataRow(["Reading", "162", "5.5", "B", "48", "8"]),
          _dataRow(["Writing", "162", "5.5", "B", "51", "18"]),
          _dataRow(["Speaking", "162", "5.5", "B", "42", "16"]),
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
          padding: const EdgeInsets.all(10),
          child: Text(
            e,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(10),
          child: Text(e),
        ),
      )
          .toList(),
    );
  }
}