import 'package:client/screens/dashboard/english_requirement/student_visa_english_requirement_screen.dart';
import 'package:client/screens/dashboard/english_requirement/temporary_graduate_visa_tr_screen.dart';
import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import '../../../widgets/webview/universal_webview.dart';
import 'english_requirement_specified_test_scores_screen.dart';

class EnglishRequirementScreen extends StatelessWidget {
  const EnglishRequirementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final links = [
      _LinkItem(
        index: 0,
        title: "English Requirement for Specified Test Scores",
        color: Colors.blue,
      ),
      _LinkItem(
        index: 1,
        title: "English Requirement for 485 Temporary Graduate Visa (TR)",
        color: Colors.green,
      ),
      _LinkItem(
        index: 2,
        title: "English Requirement for Student Visa",
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "English Requirements",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: links
              .map(
                (link) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _linkTile(context, link),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _linkTile(BuildContext context, _LinkItem link) {
    return InkWell(
      onTap: () {
        if (link.index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EnglishRequirementSpecifiedTestScoresScreen(),
            ),
          );
        } else if (link.index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TemporaryGraduateVisaTRScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentVisaEnglishRequirementScreen(),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: link.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: link.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.link, color: link.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                link.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: link.color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: link.color),
          ],
        ),
      ),
    );
  }
}

class _LinkItem {
  final int index;
  final String title;
  final Color color;

  const _LinkItem({
    required this.index,
    required this.title,
    required this.color,
  });
}