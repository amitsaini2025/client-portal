import 'package:client/screens/workflow/message/workflow_messages_screen.dart';
import 'package:client/screens/workflow/workflow_recipients_screen.dart';
import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../config/theme_config.dart';
import 'workflow_documents_screen.dart';
import 'workflow_stages_screen.dart';

class WorkflowScreen extends StatefulWidget {
  const WorkflowScreen({super.key});

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color navyBlue = Color(0xFF1E1464);
  static const Color goldenYellow = Color(0xFFF9B000);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: goldenYellow,
        iconTheme: const IconThemeData(color: ThemeConfig.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workflow',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AuthService.selectedMatterId.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: navyBlue,
          unselectedLabelColor: Colors.white,
          indicatorColor: navyBlue,
          tabs: const [
            Tab(text: 'Stages'),
            Tab(text: 'Documents'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WorkflowStagesScreen(),
          WorkflowDocumentsScreen(),
          WorkflowMessagesScreen(),
        ],
      ),
    );
  }
}
