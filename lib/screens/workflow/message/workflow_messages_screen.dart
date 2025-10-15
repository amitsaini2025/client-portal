import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme_config.dart';
import '../../../models/workflow_message.dart';
import '../../../models/workflow_send_message_response.dart' hide Message;
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class WorkflowMessagesScreen extends StatefulWidget {
  const WorkflowMessagesScreen({super.key});

  @override
  State<WorkflowMessagesScreen> createState() => _WorkflowMessagesScreenState();
}

class _WorkflowMessagesScreenState extends State<WorkflowMessagesScreen> {
  bool _isLoading = true;
  String? _error;
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

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
        clientMatterId: AuthService.selectedMatterId!,
        clientMatterStageId: AuthService.clientMatterStageId ?? 0,
      );

      if (response['success'] == true) {
        final parsed = WorkflowMessagesResponse.fromJson(response);
        setState(() {
          _messages = parsed.data.messages;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final base = _messages.isNotEmpty ? _messages.first : null;
      if (base == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No message context found."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final responseJson = await ApiService.sendChatMessage(
        clientMatterId: base.clientMatterId,
        message: text,
      );

      final response = SendMessageResponse.fromJson(responseJson);

      if (response.success && response.data?.message != null) {
        final sent = response.data?.message!;
        final newMessage = Message(
          id: sent!.id,
          message: sent.message,
          sender: sent.sender,
          senderId: sent.senderId,
          recipientIds: sent.recipientIds,
          sentAt: sent.sentAt,
          clientMatterId: sent.clientMatterId,
          recipientCount: sent.recipientCount,
          isSender: true,
          isRecipient: false,
          recipients: {},
          createdAt: sent.sentAt,
          updatedAt: sent.sentAt,
        );

        setState(() {
          _messages.add(newMessage);
        });

        _messageController.clear();
        _scrollToBottom();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Message sent successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send message"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('hh:mm a').format(dt);
      } else {
        return DateFormat('MMM d, hh:mm a').format(dt);
      }
    } catch (_) {
      return dateTimeStr;
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts.take(2).map((e) => e.substring(0, 1).toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? Center(
          child: CircularProgressIndicator(color: ThemeConfig.goldenYellow))
          : _error != null
          ? _buildErrorWidget(_error!)
          : _messages.isEmpty
          ? _buildEmptyWidget()
          : Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return RefreshIndicator(
      onRefresh: _loadWorkflowMessages,
      color: ThemeConfig.goldenYellow,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];

          final isSender = msg.isSender;
          final time = _formatDateTime(msg.sentAt);
          String avatarName =
          isSender ? msg.sender : msg.recipients.values.join(", ");

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/workflow-message-detail',
                arguments: {'messageId': msg.id},
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isSender)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        _getInitials(avatarName),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (!isSender) const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSender
                            ? ThemeConfig.navyBlue.withOpacity(0.9)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isSender ? 16 : 0),
                          bottomRight: Radius.circular(isSender ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 3,
                            offset: const Offset(1, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.message,
                            style: TextStyle(
                                fontSize: 15,
                                color: isSender ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSender
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isSender) const SizedBox(width: 8),
                  if (isSender)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orangeAccent,
                      child: Text(
                        _getInitials(avatarName),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 22,
              backgroundColor: ThemeConfig.navyBlue,
              child: _isSending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
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
          Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWorkflowMessages,
            style: ElevatedButton.styleFrom(backgroundColor: ThemeConfig.goldenYellow),
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
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No messages available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
