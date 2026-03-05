import 'package:flutter/material.dart';

import '../../workflow/workflow_stages_screen.dart';
import '../my_files/my_files_quick_action_card.dart';

class MyFilesTabScreen extends StatelessWidget {
  const MyFilesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MyFilesQuickActionsCard(
            onViewWorkflow: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                  const WorkflowStagesScreen(),
                ),
              );
            },
            onBilling: () {
              Navigator.pushNamed(context, '/billing-list');
            },
            onDocumentStatus: () {
              Navigator.pushNamed(context, '/documents');
            },
            onUpcomingDeadlines: () {
              Navigator.pushNamed(context, '/tasks');
            },
            onRecentActivity: () {
              Navigator.pushNamed(
                context,
                '/recent-activity',
              );
            },
            onMessage: () {
              Navigator.pushNamed(
                context,
                '/workflow-message',
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
