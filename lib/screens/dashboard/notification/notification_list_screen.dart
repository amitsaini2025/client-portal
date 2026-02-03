import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../models/notification/notification.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 20;
  List<NotificationModel> notifications = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

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
      setState(() {
        isLoading = false;
      });
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
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: notifications.length + (hasMore ? 1 : 0),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final item = notifications[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                borderRadius: BorderRadius.circular(14),
                elevation: 3,
                shadowColor: Colors.black26,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Open: ${item.url}')));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: item.isRead
                          ? null
                          : LinearGradient(
                        colors: [
                          Colors.yellow.shade50,
                          Colors.yellow.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                          item.isRead ? Colors.green : Colors.redAccent,
                          child: Text(
                            item.senderName[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.message,
                                style: TextStyle(
                                  fontWeight: item.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.senderName} • ${_formatDate(item.createdAt)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
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
                          color: item.isRead ? Colors.green : Colors.redAccent,
                          size: 22,
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
}