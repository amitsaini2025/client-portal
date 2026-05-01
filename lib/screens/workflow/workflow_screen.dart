import 'package:client/screens/workflow/message/workflow_messages_screen.dart';
import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../config/theme_config.dart';
import '../../services/api_service.dart';
import '../../utils/responsive_utils.dart';
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
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await ApiService.getUnreadMessageCount(
        clientMatterId: AuthService.selectedMatterId!,
      );
      if (response['success'] == true) {
        setState(() {
          _unreadCount = response['data']['unread_count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch unread count: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
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
            /*Text(
              AuthService.selectedMatterId.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),*/
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.navyBlue,
          unselectedLabelColor: Colors.white,
          indicatorColor: ThemeConfig.navyBlue,
          tabs: [
            const Tab(text: 'Stages'),
            const Tab(text: 'Documents'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Chat'),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Container(
            color: ThemeConfig.navyBlue,
            child: TabBarView(
              controller: _tabController,
              children: [
                WorkflowStagesScreen(matterID: AuthService.selectedMatterId ?? 0),
                const WorkflowDocumentsScreen(),
                WorkflowMessagesScreen(matterID: AuthService.selectedMatterId ?? 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
