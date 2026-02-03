import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../models/notification/notification.dart';

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
        await ApiService.markNotificationAsRead(notificationId: widget.notificationId);
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ThemeConfig.goldenYellow),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black87),
                  ),
                ],
              ),
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
        backgroundColor: ThemeConfig.goldenYellow.withOpacity(0.9),
        title: const Text(
          "Notification Detail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          shadowColor: Colors.black12,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: notification!.isRead
                  ? null
                  : LinearGradient(
                colors: [
                  const Color(0xFFF5F7FA),
                  const Color(0xFFE8EEF5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Type
                Center(
                  child: Text(
                    notification?.notificationType ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  notification?.message ?? '',
                  style: const TextStyle(
                      fontSize: 17, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Info Rows
                _buildInfoRow(Icons.person, 'From',
                    notification?.senderName ?? 'Unknown'),
                _buildInfoRow(Icons.access_time, 'Created at',
                    _formatDate(notification!.createdAt)),
                _buildInfoRow(Icons.update, 'Updated at',
                    _formatDate(notification!.updatedAt)),
                _buildInfoRow(Icons.link, 'URL',
                    notification?.url ?? 'N/A'),
                _buildInfoRow(Icons.mark_email_read, 'Read',
                    notification!.isRead ? 'Yes' : 'No'),
                _buildInfoRow(Icons.visibility, 'Seen',
                    notification!.seen ? 'Yes' : 'No'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
