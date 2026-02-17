import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../utils/constants.dart';
import '../../../widgets/webview/universal_webview.dart';

class ImportantLinksScreen extends StatelessWidget {
  const ImportantLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final links = [
      _LinkItem(
        title: "Visa Processing",
        url: UrlConstants.importantLinks.visaProcessing,
        color: Colors.blue,
      ),
      _LinkItem(
        title: "VEVO Check",
        url: UrlConstants.importantLinks.vevoCheck,
        color: Colors.green,
      ),
      _LinkItem(
        title: "Invitation Rounds",
        url: UrlConstants.importantLinks.invitationRounds,
        color: Colors.orange,
      ),
      _LinkItem(
        title: "Departmental Forms",
        url: UrlConstants.importantLinks.departmentalForms,
        color: Colors.purple,
      ),
      _LinkItem(
        title: "Course Check (CRICOS)",
        url: UrlConstants.importantLinks.courseCheck,
        color: Colors.teal,
      ),
      _LinkItem(
        title: "Consumer Guide",
        url: UrlConstants.importantLinks.consumerGuide,
        color: Colors.red,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Important Links",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              links
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => UniversalWebView(
                  url: link.url,
                  viewId: link.title,
                  title: link.title,
                ),
          ),
        );
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
  final String title;
  final String url;
  final Color color;

  const _LinkItem({
    required this.title,
    required this.url,
    required this.color,
  });
}
