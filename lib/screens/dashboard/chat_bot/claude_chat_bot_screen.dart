import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme_config.dart';
import '../../../services/api_service.dart';
import '../../../utils/responsive_utils.dart';

class ClaudeChatBotScreen extends StatefulWidget {
  const ClaudeChatBotScreen({super.key});

  @override
  State<ClaudeChatBotScreen> createState() => _ClaudeChatBotScreenState();
}

class _ClaudeChatBotScreenState extends State<ClaudeChatBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! 👋 I'm your Bansal Immigration assistant. Send links, emails or phone numbers 😉",
    );
  }

  void _addBotMessage(String text) {
    _messages.insert(0, _Message(text: text, isUser: false));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, _Message(text: text, isUser: true));
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await ApiService.sendChatBotMessage(text);

      String reply;

      if (response['success'] == true) {
        reply =
            response['data']?['content']?[0]?['text'] ??
                'No response received.';
      } else {
        reply = response['message'] ?? 'Something went wrong.';
      }

      setState(() {
        _isLoading = false;
        _messages.insert(0, _Message(text: reply, isUser: false));
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.insert(
          0,
          const _Message(
            text: 'Network error. Please try again.',
            isUser: false,
          ),
        );
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _sendMessage,
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: ThemeConfig.goldenYellow,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed:
              _isLoading ? null : () => _sendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text("Assistant is typing...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
        title: const Text("Chatbot"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: _messages.length,
                  itemBuilder: (_, index) => _messages[index],
                ),
              ),
              if (_isLoading) _buildTypingIndicator(),
              const Divider(height: 1),
              _buildTextComposer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final bool isUser;

  const _Message({required this.text, required this.isUser});

  Future<void> _handleTap(String value) async {
    Uri uri;

    if (value.startsWith("http")) {
      uri = Uri.parse(value);
    } else if (value.contains("@")) {
      uri = Uri.parse("mailto:$value");
    } else {
      uri = Uri.parse("tel:$value");
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildRichText() {
    final RegExp regExp = RegExp(
      r'((https?:\/\/[^\s]+)|(\+?\d{7,})|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))',
    );

    final matches = regExp.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      );
    }

    List<TextSpan> spans = [];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
            ),
          ),
        );
      }

      final matchText = match.group(0)!;

      spans.add(
        TextSpan(
          text: matchText,
          style: TextStyle(
            color: isUser ? Colors.white70 : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer:
          TapGestureRecognizer()
            ..onTap = () => _handleTap(matchText),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(16);

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Copied")),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                  isUser
                      ? ThemeConfig.goldenYellow
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomLeft: isUser ? radius : Radius.zero,
                    bottomRight: isUser ? Radius.zero : radius,
                  ),
                ),
                child: _buildRichText(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}