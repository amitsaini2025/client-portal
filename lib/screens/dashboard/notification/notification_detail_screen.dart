import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../models/notification/notification.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  NotificationModel? notification;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchNotificationDetail();
  }

  Future<void> fetchNotificationDetail() async {
    try {
      final data = await ApiService.getNotificationDetail(
        notificationId: widget.notificationId,
      );

      final notif = NotificationModel.fromJson(data['data']);

      if (!notif.isRead) {
        await ApiService.markNotificationAsRead(
          notificationId: widget.notificationId,
        );
        notif.isRead = true;
      }

      setState(() {
        notification = notif;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: ThemeConfig.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.textSecondaryLight,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: ThemeConfig.textPrimaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppResponsive.isDesktop(context);

    return Scaffold(
      backgroundColor: ThemeConfig.backgroundLight,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow.withValues(alpha: 0.9),
        elevation: 2,
        title: const Text(
          "Notification Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsive.maxContentWidth,
            ),
            child: isLoading
                ? const Center(child: AppLoader())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: ThemeConfig.errorColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load notification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ThemeConfig.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: ThemeConfig.errorColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: AppResponsive.pagePadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero card
                            Material(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 16 : 12,
                              ),
                              elevation: isDesktop ? 2 : 1,
                              shadowColor: Colors.black.withValues(
                                alpha: isDesktop ? 0.08 : 0.05,
                              ),
                              color: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 16 : 12,
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        width: 4,
                                        color: ThemeConfig.primaryColor,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            isDesktop ? 20 : 16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: isDesktop ? 26 : 22,
                                                    backgroundColor:
                                                        ThemeConfig.primaryColor,
                                                    child: Text(
                                                      (notification!.senderName
                                                                  .isNotEmpty
                                                              ? notification!
                                                                  .senderName[0]
                                                              : 'S')
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            isDesktop ? 16 : 14,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          notification!
                                                              .senderName,
                                                          style: TextStyle(
                                                            fontSize: isDesktop
                                                                ? 15
                                                                : 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: ThemeConfig
                                                                .textPrimaryLight,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          _formatDate(
                                                            notification!
                                                                .createdAt,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: ThemeConfig
                                                                .textSecondaryLight
                                                                .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: ThemeConfig
                                                          .primaryColor
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        20,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      notification!
                                                          .notificationType
                                                          .replaceAll('_', ' '),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: ThemeConfig
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                notification!.message,
                                                style: TextStyle(
                                                  fontSize: isDesktop ? 16 : 15,
                                                  color: ThemeConfig
                                                      .textPrimaryLight,
                                                  height: 1.55,
                                                ),
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

                            const SizedBox(height: 16),

                            // Details card
                            Material(
                              borderRadius: BorderRadius.circular(
                                isDesktop ? 16 : 12,
                              ),
                              elevation: isDesktop ? 2 : 1,
                              shadowColor: Colors.black.withValues(
                                alpha: isDesktop ? 0.08 : 0.05,
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Details",
                                      style: TextStyle(
                                        fontSize: isDesktop ? 16 : 15,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeConfig.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Divider(
                                      color: ThemeConfig.borderLight,
                                      height: 20,
                                    ),
                                    _buildInfoRow(
                                      Icons.person_outline_rounded,
                                      "FROM",
                                      notification!.senderName.isNotEmpty
                                          ? notification!.senderName
                                          : "System",
                                    ),
                                    Divider(
                                      color: ThemeConfig.borderLight,
                                      height: 1,
                                    ),
                                    _buildInfoRow(
                                      Icons.access_time_rounded,
                                      "RECEIVED",
                                      _formatDate(notification!.createdAt),
                                    ),
                                    Divider(
                                      color: ThemeConfig.borderLight,
                                      height: 1,
                                    ),
                                    _buildInfoRow(
                                      Icons.update_rounded,
                                      "UPDATED",
                                      _formatDate(notification!.updatedAt),
                                    ),
                                    if (notification!.url.isNotEmpty) ...[
                                      Divider(
                                        color: ThemeConfig.borderLight,
                                        height: 1,
                                      ),
                                      _buildInfoRow(
                                        Icons.link_rounded,
                                        "ACTION URL",
                                        notification!.url,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
