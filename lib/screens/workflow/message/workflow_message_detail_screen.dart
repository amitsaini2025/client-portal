import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../models/workflow_message_detail_response.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';

class WorkflowMessageDetailScreen extends StatefulWidget {
  final int messageId;

  const WorkflowMessageDetailScreen({super.key, required this.messageId});

  @override
  State<WorkflowMessageDetailScreen> createState() =>
      _WorkflowMessageDetailScreenState();
}

class _WorkflowMessageDetailScreenState
    extends State<WorkflowMessageDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Data? _message;

  @override
  void initState() {
    super.initState();
    _loadMessageDetail();
  }

  Future<void> _loadMessageDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getMessageDetail(widget.messageId);

      if (response['success'] == true) {
        setState(() {
          _message = Data.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load message details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Message info",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child:
              _isLoading
                  ? Center(child: AppLoader())
                  : _error != null
                  ? _buildErrorWidget()
                  : _message == null
                  ? _buildEmptyWidget()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppResponsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageBubble(),
          const SizedBox(height: 24),
          _buildStatusTile(
            icon: Icons.done_all,
            iconColor: Colors.blue,
            title: "Read",
            time:
                _message!.recipients.any((r) => r.isRead)
                    ? "Some recipients have read this message"
                    : "No one has read this message yet",
          ),
          /*const Divider(height: 32),
          _buildStatusTile(
            icon: Icons.done,
            iconColor: Colors.grey,
            title: "Delivered",
            time:
            "${_message!.recipientCount} recipients received this message",
          ),*/
        ],
      ),
    );
  }

  Widget _buildMessageBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_message!.attachments.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _message!.attachments.map((attachment) {
                      if (attachment.type == "image") {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            attachment.url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            headers: {
                              "Authorization":
                                  "Bearer ${AuthService.currentToken}",
                            },
                          ),
                        );
                      } else {
                        return Container(
                          width: 120,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            attachment.filename,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                    }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            if (_message!.message.isNotEmpty)
              Text(
                _message!.message,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(_message!.sentAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Icon(
                  _message!.recipients.any((r) => r.isRead)
                      ? Icons.done_all
                      : Icons.done,
                  size: 16,
                  color:
                      _message!.recipients.any((r) => r.isRead)
                          ? Colors.blue
                          : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        _error ?? "Error loading message",
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text(
        "No message details available",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
