import 'package:client/screens/dashboard/notification/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../models/notification/notification.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';
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
  bool isNavigating = false;
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
    if (!mounted) return;

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

      if (!mounted) return;
      setState(() {
        currentPage++;
        notifications.addAll(newNotifications);
        hasMore = currentPage <= data['data']['pagination']['last_page'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;

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
    final isDesktop = AppResponsive.isDesktop(context);

    return Scaffold(
      backgroundColor: ThemeConfig.backgroundLight,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow.withValues(alpha: 0.9),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsive.maxContentWidth,
            ),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: isLoading && notifications.isEmpty
                  ? const Center(child: AppLoader())
                  : notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: ThemeConfig.primaryColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  size: 40,
                                  color: ThemeConfig.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeConfig.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "You're all caught up",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ThemeConfig.textSecondaryLight
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: notifications.length + (hasMore ? 1 : 0),
                          padding: AppResponsive.horizontalPadding(
                            context,
                          ).copyWith(top: 10, bottom: 24),
                          itemBuilder: (context, index) {
                            if (index == notifications.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: AppLoader()),
                              );
                            }
                            return _buildNotificationItem(
                              notifications[index],
                              isDesktop,
                            );
                          },
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item, bool isDesktop) {
    final bool isUnread = !item.isRead;
    final double radius = isDesktop ? 16 : 12;

    final Color cardBg = isDesktop
        ? (isUnread ? const Color(0xFFEDF5F3) : ThemeConfig.backgroundLight)
        : (isUnread ? const Color(0xFFF0F7F5) : Colors.white);

    final Color avatarBg = isUnread
        ? ThemeConfig.primaryColor
        : (isDesktop ? ThemeConfig.borderLight : const Color(0xFFF1F5F9));
    final Color avatarTextColor =
        isUnread ? Colors.white : ThemeConfig.primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 4),
      child: Material(
        borderRadius: BorderRadius.circular(radius),
        elevation: isDesktop ? 2 : 1,
        shadowColor: Colors.black.withValues(
          alpha: isDesktop ? 0.08 : 0.05,
        ),
        color: cardBg,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: () async {
            await _handleNotificationTap(context, item);
            if (mounted) _refresh();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: isUnread
                        ? ThemeConfig.primaryColor
                        : Colors.transparent,
                  ),
                  Expanded(
                    child: Padding(
                      padding: isDesktop
                          ? const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            )
                          : const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: isDesktop ? 26 : 21,
                            backgroundColor: avatarBg,
                            child: Text(
                              item.senderName[0].toUpperCase(),
                              style: TextStyle(
                                color: avatarTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ),
                          SizedBox(width: isDesktop ? 16 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.message,
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: isDesktop ? 15.5 : 14.5,
                                    color: isUnread
                                        ? ThemeConfig.textPrimaryLight
                                        : ThemeConfig.textSecondaryLight,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 5 : 4),
                                Text(
                                  '${item.senderName} • ${_formatDate(item.createdAt)}',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 13 : 12,
                                    color: ThemeConfig.textSecondaryLight
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: isDesktop ? 12 : 8),
                          Icon(
                            isUnread
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: isUnread
                                ? ThemeConfig.primaryColor
                                : Colors.grey.shade400,
                            size: isDesktop ? 22 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    if (isNavigating) return;
    isNavigating = true;

    try {
      if (!item.isRead) {
        await ApiService.markNotificationAsRead(notificationId: item.id);
        item.isRead = true;
      }

      final Map<String, dynamic> matters = await ApiService.getMatters();
      final int matterId = item.clientMatterId;

      String? matterName;
      if (matters["data"]["matters"] != null) {
        for (var m in matters["data"]["matters"]) {
          if (m["matter_id"] == matterId) {
            matterName = m["matter_name"] ?? "";
            break;
          }
        }
      }
      matterName ??= "Unknown";

      await AuthService.selectMatter(
        matterId: matterId,
        matterName: matterName,
      );

      Widget? screen;

      final type = item.notificationType.trim();
      final url = item.url.trim();

      switch (type) {
        case "message":
          screen = WorkflowMessagesScreen(matterID: matterId);
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
          screen = WorkflowStagesScreen(matterID: matterId);
          break;

        case "detail_approved":
        case "detail_rejected":
          screen = PersonalInformationScreen();
          break;

        case "invoice_sent_to_client_app":
          screen = BillingListScreen(matterID: matterId);
          break;

        case "action_completed":
          if (url == "/activities") {
            screen = WorkflowStagesScreen(matterID: matterId);
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

      if (!mounted) return;

      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    } finally {
      isNavigating = false;
    }
  }
}
