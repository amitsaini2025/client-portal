import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/responsive_utils.dart';

class WorkflowRecipientsScreen extends StatefulWidget {
  final int clientMatterId;
  final String matterName;

  const WorkflowRecipientsScreen({
    super.key,
    required this.clientMatterId,
    required this.matterName,
  });

  @override
  State<WorkflowRecipientsScreen> createState() => _WorkflowRecipientsScreenState();
}

class _WorkflowRecipientsScreenState extends State<WorkflowRecipientsScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _recipients = [];

  @override
  void initState() {
    super.initState();
    _loadChatRecipients();
  }

  Future<void> _loadChatRecipients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getChatRecipients();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data']['recipients'] ?? [];
        setState(() {
          _recipients = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load recipients';
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget(_error!, _loadChatRecipients)
          : RefreshIndicator(
        onRefresh: _loadChatRecipients,
        child: _recipients.isEmpty
            ? _buildEmptyWidget()
            : ListView.builder(
          padding: AppResponsive.pagePadding(context),
          itemCount: _recipients.length,
          itemBuilder: (context, index) {
            final recipient = _recipients[index];
            return _buildRecipientCard(recipient);
          },
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildRecipientCard(dynamic recipient) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              recipientName: recipient['name'],
              recipientEmail: recipient['email'],
              clientId: recipient['client_id'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipient['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipient['email'] ?? 'No email provided',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Client ID: ${recipient['client_id'] ?? '-'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
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
            Icon(Icons.chat_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No chat_bot recipients available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat Detail Screen
class ChatDetailScreen extends StatelessWidget {
  final String? recipientName;
  final String? recipientEmail;
  final String? clientId;

  const ChatDetailScreen({
    super.key,
    this.recipientName,
    this.recipientEmail,
    this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipientName ?? 'Chat'),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'Chat screen for:\n\n${recipientName ?? '-'}\n${recipientEmail ?? '-'}\nClient ID: ${clientId ?? '-'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
