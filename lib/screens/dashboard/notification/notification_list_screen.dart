import 'package:client/screens/dashboard/notification/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../models/notification/notification.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../workflow/message/workflow_messages_screen.dart';
import '../../workflow/workflow_stages_screen.dart';
import '../billing_list/billing_list_screen.dart';
import '../personal_info/personal_information_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with WidgetsBindingObserver {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 20;
  List<NotificationModel> notifications = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.getNotifications(
        clientMatterId: AuthService.selectedMatterId ?? 0,
        page: currentPage,
        limit: limit,
      );

      final newNotifications =
          (data['data']['notifications'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList();

      setState(() {
        currentPage++;
        notifications.addAll(newNotifications);
        hasMore = currentPage <= data['data']['pagination']['last_page'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _refresh() async {
    setState(() {
      currentPage = 1;
      notifications.clear();
      hasMore = true;
    });
    await fetchNotifications();
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow.withOpacity(0.9),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child:
            isLoading && notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
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
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: notifications.length + (hasMore ? 1 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    if (index == notifications.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final item = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(14),
                        elevation: 1.5,
                        shadowColor: Colors.black12,
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            // Navigate to detail screen and refresh on return
                            /*await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => NotificationDetailScreen(
                                      notificationId: item.id,
                                    ),
                              ),
                            );*/
                            _handleNotificationTap(context, item);
                            // Refresh list after returning
                            _refresh();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient:
                                  item.isRead
                                      ? null
                                      : LinearGradient(
                                        colors: const [
                                          Color(0xFFF5F7FA),
                                          Color(0xFFE8EEF5),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel item,
  ) async {
    Widget? screen;
    switch (item.notificationType) {
      case 'message':
        screen = WorkflowMessagesScreen();
        break;
      case 'stage_change':
      case 'matter_discontinued':
      case 'matter_reopened':
      case 'checklist':
      case 'checklist_added':
        screen = WorkflowStagesScreen();
        break;
      case 'document_approved':
      case 'document_rejected':
      case 'document_deleted':
      case 'document_downloaded':
        screen = WorkflowStagesScreen();
        break;
      case 'detail_approved':
      case 'detail_rejected':
        screen = PersonalInformationScreen();
        break;
      case 'invoice_sent_to_client_app':
        screen = BillingListScreen();
        break;
      case 'action_completed':
      case 'lead_converted_to_client':
        screen = NotificationDetailScreen(notificationId: item.id);
        break;
      default:
        screen = NotificationDetailScreen(notificationId: item.id);
        break;
    }
    if (screen != null) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
      _refresh();
    }
  }
}
