import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/chat_bot_service.dart';
import '../../../config/theme_config.dart';
import '../../../utils/responsive_utils.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late ChatbotService _chatbotService;
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _chatbotService = ChatbotService(
      'hummr-d17f7',
      'assets/hummr-d17f7-3e476ccd9405.json',
    );

    _chatbotService.initialize().then((_) {
      _sendMessage('Hello');
    });
  }

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, sender: 'user'));
    });

    _textController.clear();

    try {
      final response = await _chatbotService.detectIntent(text);
      final fulfillmentText = response.queryResult?.fulfillmentText;

      if (fulfillmentText != null && fulfillmentText.isNotEmpty) {
        setState(() {
          _messages.insert(0, ChatMessage(text: fulfillmentText, sender: 'bot'));
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: 'Error: Could not connect to the chatbot. $e',
            sender: 'bot',
          ),
        );
      });
    }
  }

  /*Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, sender: 'user'));
    });

    _textController.clear();

    try {
      final response = await _chatbotService.detectIntent(text);
      final fulfillmentText = response.queryResult?.fulfillmentText;

      if (fulfillmentText != null && fulfillmentText.isNotEmpty) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(text: fulfillmentText, sender: 'bot'),
          );
        });

        final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
        final match = urlRegex.firstMatch(fulfillmentText);

        if (match != null) {
          final url = match.group(0);
          if (url != null) {
            _openLink(url);
          }
        }
      }
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: 'Error: Could not connect to the chatbot. $e',
            sender: 'bot',
          ),
        );
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text("Chatbot", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppResponsive.maxContentWidth),
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
          ),
        ),
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
                onSubmitted: _sendMessage,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final String sender;

  const ChatMessage({super.key, required this.text, required this.sender});

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
            sender == 'user' ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (sender != 'user')
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: ThemeConfig.goldenYellow,
                child: Text(
                  sender[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  sender == 'user'
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Text(
                  sender == 'user' ? 'You' : 'Chatbot',
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
