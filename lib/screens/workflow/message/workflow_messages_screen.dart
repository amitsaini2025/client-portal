import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../config/theme_config.dart';
import '../../../models/workflow_message.dart' as wf;
import '../../../models/workflow_message.dart' hide Attachment;
import '../../../models/workflow_send_message_response.dart' hide Recipient;
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_loader.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/revert_socket_service.dart';
import '../../../widgets/common_app_bar.dart';

class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class PusherService {
  PusherService._();

  static PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  static Function(MessageDetail)? onMessageReceived;

  static void init_() async {
    try {
      /* Initialization commented for now */
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
}

class ReverbService {
  static final PusherChannelsFlutter pusher =
      PusherChannelsFlutter.getInstance();

  static Function(MessageDetail message)? onMessageReceived;

  static Future<void> init({
    required String userId,
    required String token,
  }) async {
    try {
      log("🔹 Initializing Reverb for user: $userId");

      onMessageReceived ??= (message) {
        log("📩 Received message: $message");
      };

      await pusher.init(
        apiKey: "145cd98cfea9f69732ae6755ac889bcc",
        cluster: "ap2",
        useTLS: true,
        authEndpoint: "https://revapi.bansalcrm.com/broadcasting/auth",
        authParams: {
          "headers": {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        },
        onConnectionStateChange: (current, previous) {
          log("🔄 Connection state: $previous → $current");
        },
        onError: (message, code, error) {
          log("❌ Pusher error: $message | Code: $code | Error: $error");
        },
        onSubscriptionSucceeded: (channelName, data) {
          log("✅ Subscribed successfully to $channelName | Data: $data");
        },
        onSubscriptionError: (message, error) {
          log("❌ Subscription error: $message | Error: $error");
        },
        onEvent: (event) {
          log("📩 Event received: ${event.eventName} | Raw: ${event.data}");
          try {
            if (event.data != null) {
              final jsonData =
                  event.data is String ? jsonDecode(event.data) : event.data;
              if (jsonData['data']?['message_sent'] != null) {
                final message = MessageDetail.fromJson(
                  jsonData['data']['message_sent'],
                );
                onMessageReceived?.call(message);
              }
            }
          } catch (e) {
            log("⚠️ Event parse error: $e");
          }
        },
      );

      await pusher.connect();
      await pusher.subscribe(channelName: "private-user.$userId");

      log("✅ Reverb initialized and connected");
    } catch (e, stack) {
      log("❌ Reverb init error: $e");
      log(stack.toString());
    }
  }

  static Future<void> disconnect() async {
    try {
      await pusher.disconnect();
      log("🛑 Reverb disconnected");
    } catch (e) {
      log("❌ Disconnect error: $e");
    }
  }
}

class WorkflowMessagesScreen extends StatefulWidget {
  final int? matterID;

  const WorkflowMessagesScreen({super.key, required this.matterID});

  @override
  State<WorkflowMessagesScreen> createState() => _WorkflowMessagesScreenState();
}

class _WorkflowMessagesScreenState extends State<WorkflowMessagesScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  List<({Uint8List bytes, String name})> _attachmentBytes = [];

  @override
  void initState() {
    super.initState();
    _loadWorkflowMessages();

    ReverbSocketService.onMessageReceived = (message) {
      _handleIncomingMessage(message);
    };
    ReverbSocketService.connect(
      userId: AuthService.currentUserId.toString(),
      token: AuthService.currentToken.toString(),
    );

    // ── FIX: Load older messages when user scrolls to the TOP
    // (in a reversed ListView, maxScrollExtent is the top of the list)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    ReverbSocketService.disconnect();
    super.dispose();
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
      isSender: msgDetail.isSender,
      isRecipient: msgDetail.isRecipient,
      createdAt: msgDetail.sentAt.toIso8601String(),
      updatedAt: msgDetail.sentAt.toIso8601String(),
      senderShortname: msgDetail.senderShortname,
      isRead: msgDetail.isRead ?? false,
      readAt: msgDetail.readAt,
      attachments:
          msgDetail.attachments
              .map(
                (file) => wf.Attachment(
                  id: file.id,
                  filename: file.filename,
                  size: file.size,
                  type: file.type,
                  url: file.url,
                ),
              )
              .toList(),
    );

    setState(() {
      _messages.insert(0, newMessage);
    });

    if (!(newMessage.isRead ?? false)) {
      _markMessageAsRead(newMessage.id);
    }

    _scrollToBottom();
  }

  Future<void> _markMessageAsRead(int messageId) async {
    try {
      final response = await ApiService.markMessageAsRead(messageId: messageId);
      if (response['success'] == true) {
        setState(() {
          final msgIndex = _messages.indexWhere((m) => m.id == messageId);
          if (msgIndex != -1) {
            _messages[msgIndex].isRead = true;
            _messages[msgIndex].readAt = DateTime.now().toIso8601String();
          }
        });
      }
    } catch (e) {
      log('Failed to mark message $messageId as read: $e');
    }
  }

  Future<void> _loadWorkflowMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final response = await ApiService.getWorkflowMessages(
        clientMatterId: widget.matterID ?? 0,
        page: _currentPage,
        limit: _limit,
      );

      if (response['success'] == true) {
        final parsed = WorkflowMessagesResponse.fromJson(response);

        // ── FIX: API returns newest-first (page 1 = latest messages).
        // The reversed ListView shows index 0 at the BOTTOM, so we keep
        // the list in newest-first order (index 0 = newest = bottom).
        final msgs = parsed.data.messages;

        setState(() {
          _messages = msgs;
          _isLoading = false;
          _hasMore = msgs.length == _limit;
        });

        for (final msg in _messages) {
          if (!(msg.isRead ?? false) && !msg.isSender) {
            await _markMessageAsRead(msg.id);
          }
        }

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

  Future<void> _loadMoreMessages() async {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final response = await ApiService.getWorkflowMessages(
        clientMatterId: AuthService.selectedMatterId!,
        page: _currentPage,
        limit: _limit,
      );

      if (response['success'] == true) {
        final parsed = WorkflowMessagesResponse.fromJson(response);
        final newMessages = parsed.data.messages;

        setState(() {
          _messages.addAll(newMessages);
          _hasMore = newMessages.length == _limit;
          _isLoadingMore = false;
        });

        for (final msg in newMessages) {
          if (!(msg.isRead ?? false) && !msg.isSender) {
            await _markMessageAsRead(msg.id);
          }
        }
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _attachmentBytes.isEmpty) || _isSending) return;

    setState(() => _isSending = true);

    try {
      final clientMatterId = AuthService.selectedMatterId;
      if (clientMatterId == null) return;

      final responseJson = await ApiService.sendChatMessageWithAttachments(
        clientMatterId: clientMatterId,
        message: text,
        attachmentBytes: _attachmentBytes,
      );

      final response = SendMessageResponse.fromJson(responseJson);
      if (response.success && response.data.message != null) {
        MessageDetail message = response.data.message;
        message.attachments =
            message.attachments.map((file) {
              return Attachment(
                id: file.id,
                filename: file.filename,
                size: file.size,
                type: file.filename,
                url: file.url,
              );
            }).toList();
        message.isSender = true;
        message.isRecipient = false;
        _handleIncomingMessage(response.data.message);
        _messageController.clear();
        _attachmentBytes.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachmentBytes =
              result.files
                  .where((f) => f.bytes != null)
                  .map((f) => (bytes: f.bytes!, name: f.name))
                  .toList();
        });
      }
    } catch (e) {
      log("Error picking attachments: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
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
    return ScrollConfiguration(
      behavior: _WebScrollBehavior(),
      child: Scaffold(
        appBar: CommonAppBar(
          titleName: 'Messages',
          matterID: AuthService.selectedMatterId,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child:
              _isLoading
                  ? Center(child: AppLoader())
                  : _error != null
                  ? _buildErrorWidget(_error!)
                  : Column(
                    children: [
                      Expanded(
                        child:
                            _messages.isEmpty
                                ? _buildEmptyWidget()
                                : _buildMessageList(),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppResponsive.maxContentWidth,
                          ),
                          child: _buildMessageInput(),
                        ),
                      ),
                    ],
                  ),
        ),
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
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _pickAttachments,
            ),
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
                child: Column(
                  children: [
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                    if (_attachmentBytes.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _attachmentBytes.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6, top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _attachmentBytes[index].name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _attachmentBytes.removeAt(index);
                                      });
                                    },
                                    child: const Icon(Icons.close, size: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 22,
              backgroundColor: ThemeConfig.navyBlue,
              child:
                  _isSending
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: AppLoader(size: 20),
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

  Widget _buildMessageList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sidePadding =
            constraints.maxWidth > AppResponsive.maxContentWidth
                ? (constraints.maxWidth - AppResponsive.maxContentWidth) / 2
                : 0.0;

        return ListView.builder(
          controller: _scrollController,
          primary: false,
          physics: const ClampingScrollPhysics(),
          reverse: true,
          padding: EdgeInsets.fromLTRB(
            sidePadding + 12,
            12,
            sidePadding + 12,
            12,
          ),
          itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isLoadingMore && index == _messages.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: AppLoader(size: 20)),
              );
            }

            final msg = _messages[index];
            final isSender = msg.isSender;
            String avatarName =
                isSender
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
                      isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
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
                          color:
                              isSender
                                  ? ThemeConfig.navyBlue.withValues(alpha: 0.9)
                                  : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isSender ? 16 : 0),
                            bottomRight: Radius.circular(isSender ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
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
                            if (msg.attachments != null &&
                                msg.attachments!.isNotEmpty)
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: msg.attachments!.length,
                                  itemBuilder: (context, index) {
                                    final attachment = msg.attachments![index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          attachment.url,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          headers: {
                                            "Authorization":
                                                "Bearer ${AuthService.currentToken}",
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDateTime(msg.sentAt),
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isSender
                                        ? Colors.white70
                                        : Colors.grey.shade600,
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
        );
      },
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
