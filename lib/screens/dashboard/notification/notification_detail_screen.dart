import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../models/notification/notification.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

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
          Icon(icon, size: 20, color: ThemeConfig.goldenYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        elevation: 0,
        title: const Text(
          "Notification Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: isLoading
          ? const Center(child: AppLoader())
          : error != null
          ? Center(
        child: Text(
          error!,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: AppResponsive.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Text(
              notification!.notificationType,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            /// MESSAGE
            Text(
              notification!.message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            /// DETAILS SECTION
            const SizedBox(height: 12),
            const Text(
              "Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.person,
              "From",
              notification!.senderName ?? "System",
            ),

            _buildInfoRow(
              Icons.access_time,
              "Created",
              _formatDate(notification!.createdAt),
            ),

            _buildInfoRow(
              Icons.update,
              "Updated",
              _formatDate(notification!.updatedAt),
            ),

            if (notification!.url.isNotEmpty)
              _buildInfoRow(
                Icons.link,
                "Action URL",
                notification!.url,
              ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
