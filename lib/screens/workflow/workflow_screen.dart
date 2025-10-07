import 'package:client/screens/workflow/message/workflow_messages_screen.dart';
import 'package:client/screens/workflow/workflow_recipients_screen.dart';
import 'package:flutter/material.dart';

import 'workflow_documents_screen.dart';
import 'workflow_stages_screen.dart';

class WorkflowScreen extends StatefulWidget {
  final int clientMatterId;
  final String matterName;

  const WorkflowScreen({
    super.key,
    required this.clientMatterId,
    required this.matterName,
  });

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Workflow', style: TextStyle(fontSize: 18)),
            Text(
              widget.matterName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stages'),
            Tab(text: 'Documents'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WorkflowStagesScreen(clientMatterId: widget.clientMatterId),
          WorkflowDocumentsScreen(clientMatterId: widget.clientMatterId),
          WorkflowMessagesScreen(
            clientMatterId: widget.clientMatterId,
            clientMatterStageId: 1,
          ),
        ],
      ),
    );
  }
}
