import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme_config.dart';

const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
const String _claudeApiUrl = 'https://api.anthropic.com/v1/messages';
const String _claudeModel = 'claude-sonnet-4-6';

const String _systemPrompt = '''
You are a helpful and professional assistant for Bansal Immigration.

When a user asks about booking an appointment, scheduling a consultation, 
meeting a consultant, talking to someone, getting help with their visa, 
or anything related to appointments or consultations, always include 
this booking link in your response:
https://www.bansalimmigration.com.au/book-an-appointment

Example: "You can book a consultation directly here: 
https://www.bansalimmigration.com.au/book-an-appointment — 
our team will be happy to assist you!"

Be friendly, concise, and focused on immigration services.
''';

class ClaudeChatBotScreen extends StatefulWidget {
  const ClaudeChatBotScreen({super.key});

  @override
  State<ClaudeChatBotScreen> createState() => _ClaudeChatBotScreenState();
}

class _ClaudeChatBotScreenState extends State<ClaudeChatBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<_ClaudeMessage> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m your Bansal Immigration assistant. How can I help you today?',
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, _ClaudeMessage(text: text, isUser: false));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, _ClaudeMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _textController.clear();

    _conversationHistory.add({'role': 'user', 'content': text});

    try {
      final response = await http.post(
        Uri.parse(_claudeApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey.toString(),
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _claudeModel,
          'max_tokens': 1024,
          'system': _systemPrompt,
          'messages': _conversationHistory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['content'][0]['text'] as String;
        _conversationHistory.add({'role': 'assistant', 'content': reply});
        setState(() {
          _isLoading = false;
          _messages.insert(0, _ClaudeMessage(text: reply, isUser: false));
        });
      } else {
        final error = jsonDecode(response.body);
        final errorMsg =
            error['error']?['message'] ?? 'Unknown error occurred.';
        setState(() {
          _isLoading = false;
          _messages.insert(
            0,
            _ClaudeMessage(text: 'Error: $errorMsg', isUser: false),
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.insert(
          0,
          _ClaudeMessage(
            text: 'Error: Could not connect to Claude. $e',
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: ThemeConfig.goldenYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Assistant',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ThemeConfig.goldenYellow,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Claude is thinking...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).hintColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _isLoading ? null : _sendMessage,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask Claude anything...',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed:
                _isLoading ? null : () => _sendMessage(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaudeMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ClaudeMessage({required this.text, required this.isUser});

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final match = urlRegex.firstMatch(text);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: const CircleAvatar(
                backgroundColor: ThemeConfig.goldenYellow,
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Claude',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child:
                  match != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text.replaceAll(match.group(0)!, '')),
                      GestureDetector(
                        onTap: () => _openLink(match.group(0)!),
                        child: Text(
                          match.group(0)!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                      : Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}