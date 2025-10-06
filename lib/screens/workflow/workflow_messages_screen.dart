import 'package:flutter/material.dart';
import '../../models/workflow_message.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

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
    final messages = _messagesResponse?.data?.messages ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : _error != null
          ? _buildErrorWidget(_error!)
          : messages.isEmpty
          ? _buildEmptyWidget()
          : RefreshIndicator(
        onRefresh: _loadWorkflowMessages,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final message = messages[index];
            final isRead = message.isRead == 1;
            final timeFormatted = _formatDateTime(message.sentAt);

            return ListTile(
              onTap: () => _showMessageDetail(message),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor:
                isRead ? Colors.green : Colors.redAccent,
                child: Text(
                  message.recipient.isNotEmpty
                      ? message.recipient[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18),
                ),
              ),
              title: Text(
                message.recipient,
                style: TextStyle(
                  fontWeight: isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                message.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.grey.shade700, fontSize: 14),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeFormatted,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        return DateFormat.Hm().format(dt); // only time if today
      } else {
        return DateFormat('MMM d, H:mm').format(dt); // else date + time
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
          Text(error,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWorkflowMessages,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Retry'),
          )
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
            Text('No messages found',
                style:
                TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  void _showMessageDetail(Message message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.subject,
                  style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("From: ${message.sender} → To: ${message.recipient}"),
              const SizedBox(height: 8),
              Text("Sent: ${message.sentAt}", style: const TextStyle(color: Colors.grey)),
              const Divider(height: 20),
              Text(message.message,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 20),
              Text("Source: ${message.metadata.sentFrom}",
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
