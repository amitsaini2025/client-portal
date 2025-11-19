import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme_config.dart';
import '../../../models/workflow_message_detail_response.dart';
import '../../../services/api_service.dart';

class WorkflowMessageDetailScreen extends StatefulWidget {
  final int messageId;

  const WorkflowMessageDetailScreen({
    super.key,
    required this.messageId,
  });

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
        final parsedMessage = Data.fromJson(response['data']);

        setState(() {
          _message = parsedMessage;
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

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('hh:mm a').format(dt);
      } else {
        return DateFormat('MMM d, yyyy hh:mm a').format(dt);
      }
    } catch (_) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Message Detail',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: ThemeConfig.goldenYellow),
      )
          : _error != null
          ? _buildErrorWidget(_error!)
          : _message == null
          ? _buildEmptyWidget()
          : _buildMessageDetail(),
    );
  }

  Widget _buildMessageDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSenderInfo(),
          const SizedBox(height: 16),
          _buildRecipientsInfo(),
          const SizedBox(height: 16),
          _buildSentAtInfo(),
          const SizedBox(height: 24),
          _buildMessageCard(),
          const SizedBox(height: 24),
          _buildAdditionalDetails(),
        ],
      ),
    );
  }

  Widget _buildSenderInfo() {
    return Row(
      children: [
        const Icon(Icons.person, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'From: ${_message!.sender}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientsInfo() {
    return Row(
      children: [
        const Icon(Icons.group, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'To: ${_message!.recipients.map((r) => r.recipientName).join(', ')}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildSentAtInfo() {
    return Row(
      children: [
        const Icon(Icons.access_time, color: Colors.orangeAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Sent: ${_formatDateTime(_message!.sentAt)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Text(
        _message!.message,
        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*_buildDetailRow('Message ID', _message!.id.toString(), icon: Icons.tag),
        _buildDetailRow('Client Matter ID', _message!.clientMatterId.toString(),
            icon: Icons.folder),
        _buildDetailRow(
            'Recipient Count', _message!.recipientCount.toString(),
            icon: Icons.group),*/
        _buildDetailRow('Created At', _formatDateTime(_message!.createdAt),
            icon: Icons.calendar_today),
        _buildDetailRow('Updated At', _formatDateTime(_message!.updatedAt),
            icon: Icons.update),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 18, color: Colors.grey.shade700),
          if (icon != null) const SizedBox(width: 6),
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
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
            onPressed: _loadMessageDetail,
            style:
            ElevatedButton.styleFrom(backgroundColor: ThemeConfig.goldenYellow),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No message details available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
