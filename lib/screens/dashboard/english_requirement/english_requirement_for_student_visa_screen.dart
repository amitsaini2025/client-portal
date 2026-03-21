import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class EnglishRequirementForStudentVisaScreen extends StatelessWidget {
  const EnglishRequirementForStudentVisaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "English Requirement for Student Visa",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            "Required English language test scores",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          /// IELTS Academic
          _card(
            title: "IELTS Academic",
            min: "Minimum Score: 6.0",
            elicos10: "With 10 weeks ELICOS / Pathway: 5.5",
            elicos20: "With 20 weeks ELICOS: 5.0",
          ),

          /// IELTS General
          _card(
            title: "IELTS General Training",
            min: "Minimum Score: 6.0",
            elicos10: "With 10 weeks ELICOS / Pathway: 5.5",
            elicos20: "With 20 weeks ELICOS: 5.0",
          ),

          /// PTE Academic
          _card(
            title: "PTE Academic",
            min: "Minimum Score: 47",
            elicos10: "With 10 weeks ELICOS / Pathway: 39",
            elicos20: "With 20 weeks ELICOS: 31",
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String min,
    required String elicos10,
    required String elicos20,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeConfig.goldenYellow, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _row("Minimum", min),
            const Divider(),

            _row("10 Weeks ELICOS / Pathway", elicos10),
            const Divider(),

            _row("20 Weeks ELICOS", elicos20),
          ],
        ),
      ),
    );
  }

  Widget _row(String heading, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}



/*import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

class EnglishRequirementForStudentVisaScreen extends StatelessWidget {
  const EnglishRequirementForStudentVisaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "English Requirement for Student Visa",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            "Schedule 1—Required English language test scores",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _card("1. C1 Advanced",
              "Minimum Score: Overall band score of 161.",
              "With 10 weeks ELICOS / Foundation / Pathway: Not accepted.",
              "With 20 weeks ELICOS: Not accepted."),

          _card("2. CELPIP General",
              "Minimum Score: Overall band score of 7.",
              "With 10 weeks ELICOS / Foundation / Pathway: 6.",
              "With 20 weeks ELICOS: 5."),

          _card("3. IELTS Academic",
              "Minimum Score: Average band score of 6.0.",
              "With 10 weeks ELICOS / Foundation / Pathway: 5.5.",
              "With 20 weeks ELICOS: 5.0."),

          _card("4. IELTS General Training",
              "Minimum Score: Average band score of 6.0.",
              "With 10 weeks ELICOS / Foundation / Pathway: 5.5.",
              "With 20 weeks ELICOS: 5.0."),

          _card("5. LANGUAGECERT Academic",
              "Minimum Score: Overall band score of 61.",
              "With 10 weeks ELICOS / Foundation / Pathway: 54.",
              "With 20 weeks ELICOS: 46."),

          _card("6. MET",
              "Minimum Score: Overall band score of 53.",
              "With 10 weeks ELICOS / Foundation / Pathway: 49.",
              "With 20 weeks ELICOS: 44."),

          _card("7. OET",
              "Minimum Score: Overall band score of 1210.",
              "With 10 weeks ELICOS / Foundation / Pathway: 1090.",
              "With 20 weeks ELICOS: 1020."),

          _card("8. PTE Academic",
              "Minimum Score: Overall band score of 47.",
              "With 10 weeks ELICOS / Foundation / Pathway: 39.",
              "With 20 weeks ELICOS: 31."),

          _card("9. TOEFL iBT",
              "Minimum Score: Total band score of 67.",
              "With 10 weeks ELICOS / Foundation / Pathway: 51.",
              "With 20 weeks ELICOS: 37."),

          *//*_card("1. C1 Advanced",
              "Minimum Score: Overall band score of 161.",
              "With 10 weeks ELICOS / Foundation / Pathway: Not accepted.",
              "With 20 weeks ELICOS: Not accepted."),

          _card("2. CELPIP General",
              "Minimum Score: Overall band score of 7.",
              "With 10 weeks ELICOS / Foundation / Pathway: 6.",
              "With 20 weeks ELICOS: 5."),

          _card("3. IELTS Academic",
              "Minimum Score: Average band score of 6.0.",
              "With 10 weeks ELICOS / Foundation / Pathway: 5.5.",
              "With 20 weeks ELICOS: 5.0."),

          _card("4. IELTS General Training",
              "Minimum Score: Average band score of 6.0.",
              "With 10 weeks ELICOS / Foundation / Pathway: 5.5.",
              "With 20 weeks ELICOS: 5.0."),

          _card("5. LANGUAGECERT Academic",
              "Minimum Score: Overall band score of 61.",
              "With 10 weeks ELICOS / Foundation / Pathway: 54.",
              "With 20 weeks ELICOS: 46."),

          _card("6. MET",
              "Minimum Score: Overall band score of 53.",
              "With 10 weeks ELICOS / Foundation / Pathway: 49.",
              "With 20 weeks ELICOS: 44."),

          _card("7. OET",
              "Minimum Score: Overall band score of 1210.",
              "With 10 weeks ELICOS / Foundation / Pathway: 1090.",
              "With 20 weeks ELICOS: 1020."),

          _card("8. PTE Academic",
              "Minimum Score: Overall band score of 47.",
              "With 10 weeks ELICOS / Foundation / Pathway: 39.",
              "With 20 weeks ELICOS: 31."),

          _card("9. TOEFL iBT",
              "Minimum Score: Total band score of 67.",
              "With 10 weeks ELICOS / Foundation / Pathway: 51.",
              "With 20 weeks ELICOS: 37."),*//*
        ],
      ),
    );
  }

  Widget _card(
      String title, String col2, String col3, String col4) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            _row("Column 2", col2),
            const SizedBox(height: 6),

            _row("Column 3", col3),
            const SizedBox(height: 6),

            _row("Column 4", col4),
          ],
        ),
      ),
    );
  }

  Widget _row(String heading, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}*/



/*
import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';

class EnglishRequirementForStudentVisaScreen extends StatelessWidget {
  const EnglishRequirementForStudentVisaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "English Requirement for Student Visa",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Schedule 1—Required English language test scores",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(180),
                    2: FixedColumnWidth(200),
                    3: FixedColumnWidth(300),
                    4: FixedColumnWidth(260),
                  },
                  children: [
                    // ✅ FIXED HEADER ROW (added missing "Item")
                    _row([
                      _highlight("Item"),
                      _highlight("Column 1\n\nTest name"),
                      _highlight("Column 2\n\nMinimum test score"),
                      _highlight(
                          "Column 3\n\nMinimum test score:\nif principal course is accompanied by at least 10 weeks of an ELICOS; or\nif a standard foundation program; or\nif an extended foundation program; or\nif an eligible pathway program."),
                      _highlight(
                          "Column 4\n\nMinimum test score:\nif principal course is accompanied by at least 20 weeks of an ELICOS."),
                    ]),

                    _row([
                      _highlight("1."),
                      _highlight("C1 Advanced"),
                      _highlight("Overall band score of 161."),
                      _highlight(
                          "Not accepted for purposes of subclause 500.213(1) of Schedule 2 to the Regulations."),
                      _highlight(
                          "Not accepted for purposes of subclause 500.213(1) of Schedule 2 to the Regulations."),
                    ]),

                    _row([
                      _highlight("2."),
                      _highlight("CELPIP General"),
                      _highlight("Overall band score of 7."),
                      _highlight("Overall band score of 6."),
                      _highlight("Overall band score of 5."),
                    ]),

                    _row([
                      _highlight("3."),
                      _highlight("IELTS Academic"),
                      _highlight("Average band score of 6.0."),
                      _highlight("Average band score of 5.5."),
                      _highlight("Average band score of 5.0."),
                    ]),

                    _row([
                      _highlight("4."),
                      _highlight("IELTS General Training"),
                      _highlight("Average band score of 6.0."),
                      _highlight("Average band score of 5.5."),
                      _highlight("Average band score of 5.0."),
                    ]),

                    _row([
                      _highlight("5."),
                      _highlight("LANGUAGECERT Academic"),
                      _highlight("Overall band score of 61."),
                      _highlight("Overall band score of 54."),
                      _highlight("Overall band score of 46."),
                    ]),

                    // ROW 6
                    _row([
                      _highlight("6."),
                      _highlight("MET"),
                      _highlight("Overall band score of 53."),
                      _highlight("Overall band score of 49."),
                      _highlight("Overall band score of 44."),
                    ]),

                    // ROW 7
                    _row([
                      _highlight("7."),
                      _highlight("OET"),
                      _highlight("Overall band score of 1210."),
                      _highlight("Overall band score of 1090."),
                      _highlight("Overall band score of 1020."),
                    ]),

                    // ROW 8
                    _row([
                      _highlight("8."),
                      _highlight("PTE Academic"),
                      _highlight("Overall band score of 47."),
                      _highlight("Overall band score of 39."),
                      _highlight("Overall band score of 31."),
                    ]),

                    // ROW 9
                    _row([
                      _highlight("9."),
                      _highlight("TOEFL iBT"),
                      _highlight("Total band score of 67."),
                      _highlight("Total band score of 51."),
                      _highlight("Total band score of 37."),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _row(List<Widget> children) {
    return TableRow(
      children: children
          .map((e) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: e,
      ))
          .toList(),
    );
  }

  Widget _highlight(String text) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}*/
