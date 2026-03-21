import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';

class EnglishRequirementFor485TemporaryGraduateVisaTRScreen extends StatelessWidget {
  const EnglishRequirementFor485TemporaryGraduateVisaTRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "English Requirement for 485 Temporary Graduate Visa (TR)",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestBox(
              title: "IELTS",
              afterAugLabel: "IELTS Academic / IELTS General",
              afterAugScores: const {
                "Overall": "6.5",
                "Listening": "5.5",
                "Reading": "5.5",
                "Writing": "5.5",
                "Speaking": "5.5",
              },
              beforeAugLabel: "IELTS",
              beforeAugScores: const {
                "Overall": "6.5",
                "Listening": "5.5",
                "Reading": "5.5",
                "Writing": "5.5",
                "Speaking": "5.5",
              },
            ),
            const SizedBox(height: 20),
            _buildTestBox(
              title: "PTE Academic",
              afterAugLabel: "PTE",
              afterAugScores: const {
                "Overall": "55",
                "Listening": "40",
                "Reading": "42",
                "Writing": "41",
                "Speaking": "39",
              },
              beforeAugLabel: "PTE Academic",
              beforeAugScores: const {
                "Overall": "57",
                "Listening": "43",
                "Reading": "48",
                "Writing": "51",
                "Speaking": "42",
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestBox({
    required String title,
    required String afterAugLabel,
    required Map<String, String> afterAugScores,
    required String beforeAugLabel,
    required Map<String, String> beforeAugScores,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.goldenYellow,
            ),
          ),
          const SizedBox(height: 16),
          _buildDateSection(
            "Acceptable minimum scores – Test taken on or after 7 August 2025",
            afterAugLabel,
            afterAugScores,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          _buildDateSection(
            "Acceptable minimum scores – Test taken on or before 6 August 2025",
            beforeAugLabel,
            beforeAugScores,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
      String heading,
      String subTitle,
      Map<String, String> scores,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...scores.entries.map(
              (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text(
                  ": ",
                  style: TextStyle(fontSize: 14),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}