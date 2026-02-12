import 'dart:io';

import 'package:client/config/theme_config.dart';
import 'package:client/screens/dashboard/personal_info/personal_information_screen.dart';
import 'package:client/screens/workflow/workflow_stages_screen.dart';
import 'package:client/services/api_service_bansal_immigration.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../fcm_service.dart';
import '../../models/blog.dart';
import '../../models/case.dart';
import '../../models/case_summary.dart';
import '../../models/dashboard_summary.dart';
import '../../models/deadline.dart';
import '../../models/document.dart';
import '../../models/document_status_summary.dart';
import '../../models/recent_activity.dart';
import '../../models/task.dart';
import '../../models/upcoming_deadline_summary.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dashboard/quick_actions_card.dart';
import '../../widgets/dialog/login_required_dialog.dart';
import '../documents/upload_document_screen.dart';
import 'book_appointment/book_location_screen.dart';
import 'my_files/my_files_quick_action_card.dart';

class DashboardScreen extends StatefulWidget {
  final String? matterId;

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

  List<Blog> _blogs = [];
  bool _isLoadingBlogs = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadRecentBlogs();
    if (!Platform.isWindows) {
      _setupNotifications();
    }
  }

  Future<void> _setupNotifications() async {
    final fcmService = FCMService();

    // Set up message listeners
    fcmService.setupMessageListeners(
      onForegroundMessage: (RemoteMessage message) {
        if (!mounted) return;
        debugPrint('Got a message whilst in the foreground!');
        if (message.notification != null) {
          // Show in-app notification or update UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification!.body ?? 'New notification'),
              backgroundColor: Color(0xFF5E8B7E),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
      onBackgroundMessageTap: (RemoteMessage message) {
        debugPrint(
          'Notification tapped while app in background: ${message.messageId}',
        );
        // You can add navigation logic here based on the notification data
        // For example, navigate to a specific page based on the notification type
      },
    );

    // Get the FCM token and register it
    String? token = await fcmService.getToken();
    if (token != null) {
      await ApiService.registerFCMToken(token);
    }
  }

  Future<void> _loadRecentBlogs() async {
    setState(() => _isLoadingBlogs = true);

    try {
      final response = await ApiServiceBansalImmigration.getFeaturedBlogs(
        page: 1,
        perPage: 5,
      );
      if (response['success'] == true) {
        final List list = response['data'];
        _blogs = list.map((e) => Blog.fromJson(e)).toList();
      }
    } catch (_) {}

    setState(() => _isLoadingBlogs = false);
  }

  Future<void> _loadDashboardData() async {
    if (widget.matterId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getDashboard(
        selMatterId: widget.matterId!,
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
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              if (AuthService.isAuthenticated) {
                Navigator.pushNamed(context, '/notifications');
              }else{
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const LoginRequiredDialog(),
                );
              }
              /*showSnack(
                context,
                "This feature will be available in a future update.",
              );*/
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (AuthService.isAuthenticated) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PersonalInformationScreen(),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const LoginRequiredDialog(),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              if (AuthService.isAuthenticated) {
                Navigator.pushNamed(context, '/profile');
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const LoginRequiredDialog(),
                );
              }
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
                  await Future.wait([_loadDashboardData(), _loadRecentBlogs()]);
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRecentUpdatesSection(),
                      //_buildWelcomeSection(),
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            QuickActionsCard(
                              onBookAppointment: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const BookLocationScreen(),
                                  ),
                                );
                                /*showSnack(
                                  context,
                                  "This feature will be available in a future update.",
                                );*/
                              },
                              onHealthInsurance: () {
                                Navigator.pushNamed(
                                  context,
                                  '/health-insurance',
                                );
                              },
                              onUpcomingDeadlines: () {
                                Navigator.pushNamed(context, '/tasks');
                              },
                              onPRCalculator: () {
                                Navigator.pushNamed(context, '/pr-calculator');
                              },
                              onStudentFundCalculator: () {
                                Navigator.pushNamed(
                                  context,
                                  '/student-fund-calculator',
                                );
                              },
                              onOccupationSearch: () {
                                Navigator.pushNamed(
                                  context,
                                  '/occupation-search',
                                );
                              },
                              onPostCodeChecker: () {
                                Navigator.pushNamed(
                                  context,
                                  '/post-code-checker',
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            MyFilesQuickActionsCard(
                              onUploadDocument: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const UploadDocumentScreen(),
                                  ),
                                );
                              },
                              onSendMessage: () {
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
                                        (context) =>
                                            const WorkflowStagesScreen(),
                                  ),
                                );
                              },
                              onBilling: () {
                                /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BillingScreen(),
                            ),
                          );*/
                                showSnack(
                                  context,
                                  "This feature will be available in a future update.",
                                );
                              },
                              onCaseSummary: () {
                                Navigator.pushNamed(context, '/recent-cases');
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
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildRecentUpdatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Row(
            children: [
              const Text(
                "Recent updates",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/blogs'),
                child: const Text("View all"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child:
              _isLoadingBlogs
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _blogs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final blog = _blogs[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/blogs/detail',
                            arguments: {'blogId': blog.id},
                          );
                        },
                        child: Container(
                          width: 260,
                          margin: EdgeInsets.only(
                            right: index == _blogs.length - 1 ? 0 : 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            image: DecorationImage(
                              image: NetworkImage(blog.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    blog.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    blog.date,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    if (_dashboardSummary == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Here\'s what\'s happening with your cases',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.folder_open,
                label: 'Total Matters',
                value: _caseSummary!.totalMatters.toString(),
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.folder_open,
                label: 'Active Cases',
                value: _dashboardSummary!.activeCases.toString(),
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.description,
                label: 'Documents',
                value: _dashboardSummary!.totalDocuments.toString(),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    const cardBackground = Color(0xFF2A1F70);
    const goldenYellow = Color(0xFFF9B000);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: goldenYellow.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/recent-activity');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: goldenYellow, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity Items
          ..._recentActivity.map((activity) {
            return _buildActivityItem(
              icon: Icons.task,
              title: activity.title,
              subtitle:
                  activity.description
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
