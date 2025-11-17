import 'dart:convert';
import 'dart:developer';

import 'package:client/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../config/theme_config.dart';
import '../../../models/workflow_message.dart';
import '../../../models/workflow_send_message_response.dart' hide Recipient;
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class PusherService {
  PusherService._();

  static PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  static Function(MessageDetail)? onMessageReceived;

  static void init_() async {
    try {
      /*var key = "0410ad08e960563173b5";
      var cluster = "ap2";
      var channelName = "private-user.${AuthService.currentUserId}";

      await pusher.init(
        apiKey: key,
        cluster: cluster,
        onAuthorizer: onAuthorizer,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
      );

      await pusher.subscribe(channelName: channelName);
      await pusher.connect();*/
    } catch (e) {
      log("ERROR: $e");
    }
  }

  static Future<void> onEvent(PusherEvent event) async {
    log("onEvent: $event");
    if (event.data != null && event.data.isNotEmpty) {
      try {
        final json = jsonDecode(event.data);
        if (json['data']?['message'] != null) {
          final message = MessageDetail.fromJson(json['data']['message']);
          onMessageReceived?.call(message);
        }
      } catch (e) {
        log("Failed to parse Pusher event: $e");
      }
    }
  }

  static void onConnectionStateChange(
      dynamic currentState,
      dynamic previousState,
      ) {
    log("Connection: $currentState");
  }

  static void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  static void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
  }

  static void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  static dynamic onAuthorizer(channel, socketId, _) async {
    var token = AuthService.currentToken;
    var baseUrl = AppConfig.apiBaseUrl;
    var authUrl = "$baseUrl/broadcasting/auth";
    var result = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: 'socket_id=$socketId&channel_name=$channel',
    );
    return jsonDecode(result.body);
  }
}

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

    // Initialize Pusher
    PusherService.onMessageReceived = _handleIncomingMessage;
    PusherService.init_();
  }

  void _handleIncomingMessage(MessageDetail msgDetail) {
    final newMessage = Message(
      id: msgDetail.id,
      message: msgDetail.message,
      sender: msgDetail.sender,
      senderId: msgDetail.senderId,
      recipientIds:
      msgDetail.recipientIds
          .map(
            (r) => Recipient(
          recipientId: r.recipientId,
          recipient: r.recipient,
          recipientShortname: r.recipientShortname,
        ),
      )
          .toList(),
      sentAt: msgDetail.sentAt.toIso8601String(),
      clientMatterId: msgDetail.clientMatterId,
      recipientCount: msgDetail.recipientCount,
      isSender: true,
      isRecipient: false,
      createdAt: msgDetail.sentAt.toIso8601String(),
      updatedAt: msgDetail.sentAt.toIso8601String(),
      senderShortname: msgDetail.senderShortname,
    );

    setState(() {
      _messages.add(newMessage);
    });
    _scrollToBottom();
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

      if (response.success && response.data.message != null) {
        _handleIncomingMessage(response.data.message);
        _messageController.clear();
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
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
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
        child: CircularProgressIndicator(
          color: ThemeConfig.goldenYellow,
        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 16.0), // Move up by increasing bottom padding
        child: FloatingActionButton(
          onPressed: _loadWorkflowMessages,
          backgroundColor: ThemeConfig.goldenYellow,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
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
          String avatarName = isSender
              ? msg.sender
              : msg.recipientIds.map((r) => r.recipient).join(", ");

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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!isSender) const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.message,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSender ? Colors.white : Colors.black87,
                            ),
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
                          fontWeight: FontWeight.bold,
                        ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
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
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
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
          Text(
            error,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWorkflowMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.goldenYellow,
            ),
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
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages available',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
