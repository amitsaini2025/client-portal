import 'dart:ui';

import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../models/notification/notification.dart';
import '../../../services/api_service.dart';
import '../../../widgets/dialog/login_required_dialog.dart';
import '../../workflow/message/workflow_messages_screen.dart';
import '../../workflow/workflow_stages_screen.dart';
import '../billing_list/billing_list_screen.dart';
import '../my_files/my_files_quick_action_card.dart';
import '../notification/notification_detail_screen.dart';
import '../personal_info/personal_information_screen.dart';

class MyFilesTabScreen extends StatefulWidget {
  const MyFilesTabScreen({super.key});

  @override
  State<MyFilesTabScreen> createState() => _MyFilesTabScreenState();
}

class _MyFilesTabScreenState extends State<MyFilesTabScreen>
    with RouteAware, WidgetsBindingObserver {
  bool _isBlocked = false;
  bool _isLoading = true;

  List<NotificationModel> notifications = [];
  bool isFetchingNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUserStatus();
    _fetchNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when coming back to this screen from another route
  @override
  void didPopNext() {
    _checkUserStatus();
    _fetchNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    final bool isLoggedIn = await AuthService.isAuthenticated;
    if (!isLoggedIn || !mounted || isFetchingNotifications) return;

    setState(() => isFetchingNotifications = true);

    try {
      final data = await ApiService.getRecentUnreadNotifications();

      final newNotifications =
          (data['data']['notifications'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList();

      if (!mounted) return;

      setState(() {
        notifications = newNotifications;
        isFetchingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isFetchingNotifications = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load notifications: $e")),
      );
    }
  }

  Future<void> _checkUserStatus() async {
    try {
      final bool isLoggedIn = await AuthService.isAuthenticated;
      if (!isLoggedIn) {
        setState(() => _isLoading = false);

        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.4),
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: LoginRequiredDialog(
                parentContext: context,
                onCancel: () {
                  DefaultTabController.of(this.context).animateTo(0);
                },
              ),
            );
          },
        );

        return;
      }

      final bool matterSelected = AuthService.isMatterSelected;
      if (isLoggedIn && matterSelected) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _isLoading = true);
      final result = await ApiService.checkUserAuthentication();

      if (result['success'] == true) {
        int status = result['data']['cp_status'];

        if (status == 1) {
          _showMatterSelect();
        } else if (status == 2) {
          setState(() {
            _isBlocked = true;
          });

          Future.delayed(Duration.zero, () {
            _showBlockedDialog();
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking user status: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Access Restricted"),
            content: const Text(
              "Your account approval is pending. Please contact support.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  DefaultTabController.of(this.context).animateTo(0);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMatterSelect() {
    if (!AuthService.isMatterSelected) {
      final parentContext = context;

      showDialog(
        context: parentContext,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Select Matter"),
              content: const Text("Please select a matter to continue."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    DefaultTabController.of(parentContext)?.animateTo(0);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(parentContext, '/matters');
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isBlocked,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                notifications.isEmpty && !isFetchingNotifications
                    ? Center(
                      child: Text(
                        'No notifications available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Material(
                              borderRadius: BorderRadius.circular(14),
                              elevation: 1.5,
                              shadowColor: Colors.black12,
                              color: Colors.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap:
                                    () => _handleNotificationTap(context, item),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient:
                                        item.isRead
                                            ? null
                                            : const LinearGradient(
                                              colors: [
                                                Color(0xFFF5F7FA),
                                                Color(0xFFE8EEF5),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor:
                                            item.isRead
                                                ? const Color(0xFFE6F4F1)
                                                : const Color(0xFFE8EEF5),
                                        child: Text(
                                          item.senderName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF374151),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.message,
                                              style: TextStyle(
                                                fontWeight:
                                                    item.isRead
                                                        ? FontWeight.w400
                                                        : FontWeight.w600,
                                                fontSize: 15.5,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.senderName} • ${_formatDate(item.createdAt)}',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        item.isRead
                                            ? Icons.mark_email_read
                                            : Icons.mark_email_unread,
                                        color:
                                            item.isRead
                                                ? Colors.blueGrey.shade400
                                                : Colors.blueGrey.shade600,
                                        size: 20,
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
                MyFilesQuickActionsCard(
                  onViewWorkflow: () {
                    Navigator.pushNamed(
                      context,
                      '/workflow-stages',
                      arguments: {"matter_id": AuthService.selectedMatterId},
                    );
                  },
                  onBilling: () {
                    Navigator.pushNamed(
                      context,
                      '/billing-list',
                      arguments: {"matter_id": AuthService.selectedMatterId},
                    );
                  },
                  onDocumentStatus: () {
                    Navigator.pushNamed(
                      context,
                      '/documents',
                      arguments: {"matter_id": AuthService.selectedMatterId},
                    );
                  },
                  onUpcomingDeadlines: () {
                    Navigator.pushNamed(
                      context,
                      '/tasks',
                      arguments: {"matter_id": AuthService.selectedMatterId},
                    );
                  },
                  onMessage: () {
                    Navigator.pushNamed(
                      context,
                      '/workflow-message',
                      arguments: {"matter_id": AuthService.selectedMatterId},
                    );
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

  Future<void> _handleNotificationTap(
    BuildContext context,
    NotificationModel item,
  ) async {
    if (!item.isRead) {
      await ApiService.markNotificationAsRead(notificationId: item.id);
      item.isRead = true;
    }

    Widget? screen;

    final type = item.notificationType.trim();
    final url = item.url.trim();

    switch (type) {
      case "message":
        screen = WorkflowMessagesScreen(matterID: item.clientMatterId);
        break;

      case "stage_change":
      case "matter_discontinued":
      case "matter_reopened":
      case "checklist":
      case "checklist_added":
      case "document_approved":
      case "document_rejected":
      case "document_deleted":
      case "document_downloaded":
        screen = WorkflowStagesScreen(matterID: item.clientMatterId);
        break;

      case "detail_approved":
      case "detail_rejected":
        screen = PersonalInformationScreen();
        break;

      case "invoice_sent_to_client_app":
        screen = BillingListScreen(matterID: item.clientMatterId);
        break;

      case "action_completed":
        if (url == "/activities") {
          screen = WorkflowStagesScreen(matterID: item.clientMatterId);
        } else {
          screen = NotificationDetailScreen(notificationId: item.id);
        }
        break;

      case "lead_converted_to_client":
        screen = NotificationDetailScreen(notificationId: item.id);
        break;

      default:
        screen = NotificationDetailScreen(notificationId: item.id);
        break;
    }

    if (screen != null && mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }
}
