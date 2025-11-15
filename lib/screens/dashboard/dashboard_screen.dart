import 'package:client/config/theme_config.dart';
import 'package:client/screens/billing/billing_screen.dart';
import 'package:client/screens/dashboard/personal_info/personal_information_upload_screen.dart';
import 'package:client/screens/workflow/workflow_screen.dart';
import 'package:flutter/material.dart';

import '../../models/case.dart';
import '../../models/case_summary.dart';
import '../../models/dashboard_summary.dart';
import '../../models/deadline.dart';
import '../../models/document.dart';
import '../../models/document_status_summary.dart';
import '../../models/recent_activity.dart';
import '../../models/task.dart';
import '../../models/upcoming_deadline_summary.dart';
import '../../models/workflow_stage.dart';
import '../../services/api_service.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dashboard/case_summary_card.dart';
import '../../widgets/dashboard/document_status_card.dart';
import '../../widgets/dashboard/quick_actions_card.dart';
import '../../widgets/dashboard/upcoming_deadlines_card.dart';
import '../../widgets/dashboard/workflow_progress_card.dart';
import '../appointments/book_appointment_screen.dart';
import '../documents/upload_document_screen.dart';
import '../messages/send_message_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String matterId;

  const DashboardScreen({super.key, required this.matterId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  DashboardSummary? _dashboardSummary;
  CaseSummary? _caseSummary;
  List<Case> _cases = [];
  DocumentStatusSummary? _documentStatusSummary;
  List<Document> _documents = [];
  UpcomingDeadlineSummary? _upcomingDeadlineSummary;
  List<Deadline> _deadlines = [];
  List<Task> _tasks = [];
  List<RecentActivity> _recentActivity = [];

  WorkflowStagesResponse? _workflowResponse;
  bool _isLoadingWorkflow = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadWorkflowData();
  }

  Future<void> _loadWorkflowData() async {
    setState(() {
      _isLoadingWorkflow = true;
    });

    try {
      final response = await ApiService.getWorkflowStages(
        clientMatterId: int.tryParse(widget.matterId),
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _workflowResponse = WorkflowStagesResponse.fromJson(response['data']);
          _isLoadingWorkflow = false;
        });
      } else {
        setState(() {
          _isLoadingWorkflow = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingWorkflow = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getDashboard(
        selMatterId: widget.matterId,
      );

      if (result['success'] == true) {
        final data = result['data'];

        CaseSummary? caseSummary;
        if (data['case_summary'] != null) {
          caseSummary = CaseSummary.fromJson(data['case_summary']);
        }

        DashboardSummary dashboardSummary = DashboardSummary(
          activeCases: data['active_cases'] ?? 0,
          totalDocuments: data['total_documents'] ?? 0,
          totalAppointments: data['total_appointments'] ?? 0,
        );

        List<Case> cases = [];
        if (data['recent_cases'] != null && data['recent_cases'] is List) {
          cases =
              (data['recent_cases'] as List)
                  .map((e) => Case.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
        }

        List<Document> documents = [];
        if (data['document_status']?['recent_documents'] != null &&
            data['document_status']['recent_documents'] is List) {
          documents =
              (data['document_status']['recent_documents'] as List)
                  .map((e) => Document.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
        }

        DocumentStatusSummary? documentStatusSummary;
        if (data['document_status']?['summary'] != null) {
          documentStatusSummary = DocumentStatusSummary.fromJson(
            data['document_status']['summary'],
          );
        }

        UpcomingDeadlineSummary? upcomingDeadlineSummary;
        if (data['upcoming_deadlines']?['summary'] != null) {
          upcomingDeadlineSummary = UpcomingDeadlineSummary(
            dueThisWeekCount:
                data['upcoming_deadlines']['summary']['due_this_week_count'] ??
                0,
            appointmentsCount:
                data['upcoming_deadlines']['summary']['appointments_count'] ??
                0,
            overdueCount:
                data['upcoming_deadlines']['summary']['overdue_count'] ?? 0,
          );
        }

        List<Deadline> deadlines = [];
        if (data['upcoming_deadlines']?['due_this_week_list'] != null &&
            data['upcoming_deadlines']['due_this_week_list'] is List) {
          deadlines =
              (data['upcoming_deadlines']['due_this_week_list'] as List)
                  .map((e) => Deadline.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
        }

        List<Task> tasks = [];
        if (data['tasks'] != null && data['tasks'] is List) {
          tasks =
              (data['tasks'] as List)
                  .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
        }

        List<RecentActivity> recentActivity = [];
        if (data['recent_activity'] != null &&
            data['recent_activity'] is List) {
          recentActivity =
              (data['recent_activity'] as List)
                  .map(
                    (e) =>
                        RecentActivity.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList();
        }

        setState(() {
          _dashboardSummary = dashboardSummary;
          _caseSummary = caseSummary;
          _cases = cases;
          _documentStatusSummary = documentStatusSummary;
          _documents = documents;
          _upcomingDeadlineSummary = upcomingDeadlineSummary;
          _deadlines = deadlines;
          _tasks = tasks;
          _recentActivity = recentActivity;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Failed to load dashboard';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.navyBlue,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Feature not implemented yet"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingWidget(message: 'Loading dashboard...')
              : _errorMessage != null
              ? CustomErrorWidget(
                message: _errorMessage!,
                onRetry: _loadDashboardData,
              )
              : RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    _loadDashboardData(),
                    _loadWorkflowData(),
                  ]);
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      WorkflowProgressCard(
                        workflowResponse: _workflowResponse,
                        isLoading: _isLoadingWorkflow,
                        onTap: () {
                          Navigator.pushNamed(context, '/workflow');
                        },
                      ),
                      const SizedBox(height: 24),
                      QuickActionsCard(
                        onUploadDocument: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Feature not completed yet"),
                            ),
                          );
                          /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const UploadDocumentScreen(),
                            ),
                          );*/
                        },
                        onBookAppointment: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Feature not completed yet"),
                            ),
                          );
                          /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const BookAppointmentScreen(),
                            ),
                          );*/
                        },
                        onSendMessage: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Feature not completed yet"),
                            ),
                          );
                          /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SendMessageScreen(),
                            ),
                          );*/
                        },
                        onViewWorkflow: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const WorkflowScreen(),
                            ),
                          );
                        },
                        onBilling: (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Feature not completed yet"),
                            ),
                          );
                          /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const BillingScreen(),
                            ),
                          );*/
                        },
                        onPersonalInformationUpload: (){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Feature not completed yet"),
                            ),
                          );
                          /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const PersonalInformationUploadScreen(),
                            ),
                          );*/
                        },
                      ),
                      const SizedBox(height: 24),
                      CaseSummaryCard(caseSummary: _caseSummary, cases: _cases),
                      const SizedBox(height: 24),
                      DocumentStatusCard(
                        documentStatusSummary: _documentStatusSummary,
                        documents: _documents,
                      ),
                      const SizedBox(height: 24),
                      UpcomingDeadlinesCard(
                        upcomingDeadlineSummary: _upcomingDeadlineSummary,
                        tasks: _tasks,
                        deadlines: _deadlines,
                      ),
                      const SizedBox(height: 24),
                      _buildRecentActivitySection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildWelcomeSection() {
    if (_dashboardSummary == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Here\'s what\'s happening with your cases',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.folder_open,
                label: 'Active Cases',
                value: _dashboardSummary!.activeCases.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.description,
                label: 'Documents',
                value: _dashboardSummary!.totalDocuments.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.schedule,
                label: 'Deadlines',
                value: _dashboardSummary!.totalAppointments.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    const cardBackground = Color(0xFF2A1F70); // lighter navy
    const goldenYellow = Color(0xFFF9B000);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldenYellow.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/recent-activity');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: goldenYellow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentActivity.map((activity) {
            return _buildActivityItem(
              icon: Icons.task,
              title: activity.title,
              subtitle: activity.description
                  .replaceAll('\n', ' ')
                  .replaceAll('\t', ' ')
                  .replaceAll(RegExp(r'\s+'), ' ')
                  .trim(),
              time: activity.timeAgo,
              color: goldenYellow,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
