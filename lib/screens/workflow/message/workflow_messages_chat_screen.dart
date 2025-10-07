import 'package:client/config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/workflow_message.dart';
import '../../../models/workflow_send_message_response.dart' hide Message;
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
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();

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
        final data = response['data'];
        final message = Message.fromJson(data);

        setState(() {
          _messages = [message];
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final responseJson = await ApiService.sendChatMessage(
        recipientId: _messages.first.recipientId,
        clientMatterId: _messages.first.clientMatterId,
        clientMatterStageId: _messages.first.clientMatterStageId,
        message: text,
        subject: "Reply to ${_messages.first.subject}",
      );

      final response = SendMessageResponse.fromJson(responseJson);

      if (response.success) {
        final sentMessage = response.data!.message;

        final newMessage = Message(
          id: sentMessage!.id,
          subject: _messages.first.subject,
          message: sentMessage.message,
          sender: sentMessage.sender,
          recipient: _messages.first.recipient,
          senderId: sentMessage.senderId,
          recipientId: sentMessage.recipientId ?? 0,
          isSender: true,
          isRecipient: false,
          sentAt: sentMessage.sentAt,
          readAt: null,
          isRead: sentMessage.isRead ? 1 : 0,
          messageType: 'text',
          clientMatterId: _messages.first.clientMatterId,
          clientMatterStageId: _messages.first.clientMatterStageId,
          attachments: [],
          metadata: Metadata.fromJson({}),
          createdAt: sentMessage.sentAt,
          updatedAt: sentMessage.sentAt,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _messages.isNotEmpty ? _messages.first.recipient : 'Chat',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? Center(
        child:
        CircularProgressIndicator(color: ThemeConfig.goldenYellow),
      )
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
      onRefresh: _loadMessageDetail,
      color: ThemeConfig.goldenYellow,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          final time =
          DateFormat('hh:mm a').format(DateTime.parse(msg.sentAt).toLocal());

          return Align(
            alignment:
            msg.isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                msg.isSender ? ThemeConfig.navyBlue.withOpacity(0.9) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(msg.isSender ? 12 : 0),
                  bottomRight: Radius.circular(msg.isSender ? 0 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.08),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (index == 0)
                    Center(
                      child: Text(
                        msg.subject,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.navyBlue,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: msg.isSender ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: msg.isSender
                          ? Colors.white70
                          : Colors.grey.shade600,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                icon: const Icon(Icons.send,
                    color: Colors.white, size: 20),
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
          Text(error,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadMessageDetail,
            style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.goldenYellow),
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No message details available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
