import 'package:flutter/material.dart';

import '../../../config/theme_config.dart';
import '../../../utils/responsive_utils.dart';
import '../../workflow/workflow_screen.dart';
import 'my_files_quick_action_card.dart';

class MyFilesScreen extends StatelessWidget {
  MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.white,
      appBar: AppBar(
        title: const Text(
          'My Files',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Padding(
            padding: AppResponsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyFilesQuickActionsCard(
                  onViewWorkflow: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WorkflowScreen(),
                      ),
                    );
                  },
                  onBilling: () {
                    showSnack(
                      context,
                      "This feature will be available in a future update.",
                    );
                  },
                  onDocumentStatus: () {
                    Navigator.pushNamed(context, '/documents');
                  },
                  onUpcomingDeadlines: () {
                    Navigator.pushNamed(context, '/tasks');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
