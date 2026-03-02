import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';

class TemporaryGraduateVisaTRScreen extends StatelessWidget {
  const TemporaryGraduateVisaTRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "485 Temporary Graduate Visa (TR)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeConfig.white,
          ),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(
          color: ThemeConfig.white,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(
            "Acceptable minimum scores – Test taken on or after 7 August 2025",
          ),
          const SizedBox(height: 16),
          ..._after2025Data().map((e) => _scoreCard(e)).toList(),
          const SizedBox(height: 30),
          _sectionTitle(
            "Acceptable minimum scores – Test taken on or before 6 August 2025",
          ),
          const SizedBox(height: 16),
          ..._before2025Data().map((e) => _scoreCard(e)).toList(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _scoreCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["title"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ...data["scores"]
                .map<Widget>(
                  (score) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            score["label"],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(score["value"]),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _after2025Data() {
    return [
      {
        "title": "IELTS Academic / GT",
        "scores": [
          {"label": "Overall", "value": "6.5"},
          {"label": "Listening", "value": "5.5"},
          {"label": "Reading", "value": "5.5"},
          {"label": "Writing", "value": "5.5"},
          {"label": "Speaking", "value": "5.5"},
        ],
      },
      {
        "title": "PTE Academic",
        "scores": [
          {"label": "Overall", "value": "55"},
          {"label": "Listening", "value": "40"},
          {"label": "Reading", "value": "42"},
          {"label": "Writing", "value": "41"},
          {"label": "Speaking", "value": "39"},
        ],
      },
      {
        "title": "TOEFL iBT",
        "scores": [
          {"label": "Overall", "value": "81"},
          {"label": "Listening", "value": "12"},
          {"label": "Reading", "value": "12"},
          {"label": "Writing", "value": "14"},
          {"label": "Speaking", "value": "17"},
        ],
      },
      {
        "title": "CELPIP",
        "scores": [
          {"label": "Overall", "value": "8"},
          {"label": "Listening", "value": "6"},
          {"label": "Reading", "value": "6"},
          {"label": "Writing", "value": "6"},
          {"label": "Speaking", "value": "6"},
        ],
      },
      {
        "title": "OET",
        "scores": [
          {"label": "Overall", "value": "1310"},
          {"label": "Listening", "value": "260"},
          {"label": "Reading", "value": "280"},
          {"label": "Writing", "value": "260"},
          {"label": "Speaking", "value": "310"},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _before2025Data() {
    return [
      {
        "title": "IELTS",
        "scores": [
          {"label": "Overall", "value": "6.5"},
          {"label": "Listening", "value": "5.5"},
          {"label": "Reading", "value": "5.5"},
          {"label": "Writing", "value": "5.5"},
          {"label": "Speaking", "value": "5.5"},
        ],
      },
      {
        "title": "PTE",
        "scores": [
          {"label": "Overall", "value": "57"},
          {"label": "Listening", "value": "43"},
          {"label": "Reading", "value": "48"},
          {"label": "Writing", "value": "51"},
          {"label": "Speaking", "value": "42"},
        ],
      },
      {
        "title": "TOEFL",
        "scores": [
          {"label": "Overall", "value": "83"},
          {"label": "Listening", "value": "7"},
          {"label": "Reading", "value": "8"},
          {"label": "Writing", "value": "18"},
          {"label": "Speaking", "value": "16"},
        ],
      },
      {
        "title": "CAE / C1",
        "scores": [
          {"label": "Overall", "value": "176"},
          {"label": "Listening", "value": "162"},
          {"label": "Reading", "value": "162"},
          {"label": "Writing", "value": "162"},
          {"label": "Speaking", "value": "162"},
        ],
      },
      {
        "title": "OET",
        "scores": [
          {"label": "All Bands", "value": "B"},
        ],
      },
    ];
  }
}
