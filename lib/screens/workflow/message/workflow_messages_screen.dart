import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/workflow_message.dart';
import '../../../services/api_service.dart';

class WorkflowMessagesScreen extends StatefulWidget {
  final int clientMatterId;
  final int clientMatterStageId;

  const WorkflowMessagesScreen({
    super.key,
    required this.clientMatterId,
    required this.clientMatterStageId,
  });

  @override
  State<WorkflowMessagesScreen> createState() => _WorkflowMessagesScreenState();
}

class _WorkflowMessagesScreenState extends State<WorkflowMessagesScreen> {
  static const Color navyBlue = Color(0xFF1E1464);
  static const Color goldenYellow = Color(0xFFF9B000);

  bool _isLoading = true;
  String? _error;
  WorkflowMessagesResponse? _messagesResponse;

  @override
  void initState() {
    super.initState();
    _loadWorkflowMessages();
  }

  Future<void> _loadWorkflowMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWorkflowMessages(
        clientMatterId: widget.clientMatterId,
        clientMatterStageId: widget.clientMatterStageId,
      );

      if (response['success'] == true) {
        final parsed = WorkflowMessagesResponse.fromJson(response);
        setState(() {
          _messagesResponse = parsed;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load messages';
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

  @override
  Widget build(BuildContext context) {
    final messages = _messagesResponse?.data.messages ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFF9B000)),
      )
          : _error != null
          ? _buildErrorWidget(_error!)
          : messages.isEmpty
          ? _buildEmptyWidget()
          : RefreshIndicator(
        onRefresh: _loadWorkflowMessages,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isRead = message.isRead == 1;
            final timeFormatted = _formatDateTime(message.sentAt);

            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/workflow-message-detail',
                  arguments: {'messageId': message.id},
                );
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                margin:
                const EdgeInsets.only(bottom: 4, top: 2), // spacing
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isRead
                          ? Colors.green.shade400
                          : navyBlue,
                      child: Text(
                        message.recipient.isNotEmpty
                            ? message.recipient[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  message.recipient,
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontSize: 16,
                                    color: navyBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                timeFormatted,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day) {
        return DateFormat.Hm().format(dt);
      } else {
        return DateFormat('MMM d').format(dt);
      }
    } catch (_) {
      return dateTimeStr;
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWorkflowMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: goldenYellow,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
