import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
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

  Future<void> _downloadFile(String url, String filename) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download started...')));

      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        headers: {"Authorization": "Bearer ${AuthService.currentToken}"},
        onProgress: (fileName, progress) {
          debugPrint('$fileName: $progress% downloaded');
        },
        onDownloadCompleted: (filePath) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Saved: $filePath')));
          }
        },
        onDownloadError: (errorMessage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download failed: $errorMessage')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Message Info",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
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
            title: "Read Status",
            time:
                _message!.recipients.any((r) => r.isRead)
                    ? "Some recipients have read this message"
                    : "No one has read this message yet",
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_message!.attachments.isNotEmpty) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    _message!.attachments.map((attachment) {
                      if (attachment.type == "image") {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                attachment.url,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                                headers: {
                                  "Authorization":
                                      "Bearer ${AuthService.currentToken}",
                                },
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _downloadFile(
                                      attachment.url,
                                      attachment.filename,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container(
                          width: 130,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.insert_drive_file_rounded,
                                size: 34,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                attachment.filename,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _downloadFile(
                                    attachment.url,
                                    attachment.filename,
                                  );
                                },
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text(
                                  "Download",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
              ),
              const SizedBox(height: 14),
            ],
            if (_message!.message.isNotEmpty)
              Text(
                _message!.message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 10),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          _error ?? "Error loading message",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text(
        "No message details available",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}
