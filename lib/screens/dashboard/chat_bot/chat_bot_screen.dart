import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../config/chat_bot_service.dart';
import '../../../config/theme_config.dart';

/*class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference _chatRef = FirebaseFirestore.instance.collection(
    'chat_messages',
  );

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    await _chatRef.add({
      'text': text,
      'isUser': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 500), () async {
      await _chatRef.add({
        'text': "Bot: You said '$text'",
        'isUser': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chatbot',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ThemeConfig.goldenYellow,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _chatRef.orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final text = data['text'] ?? '';
                    final isUser = data['isUser'] ?? false;

                    return Container(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/

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
    _chatbotService = ChatbotService('hummr-d17f7', 'assets/hummr-d17f7-3e476ccd9405.json');
    _chatbotService.initialize().then((_) {
      _sendMessage('Hello');
    });
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
        _messages.insert(0, ChatMessage(text: 'Error: Could not connect to the chatbot.' + e.toString(), sender: 'bot'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: const Text(
          "Chatbot",
          style: TextStyle(color: Colors.white),
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
                onSubmitted: _sendMessage,
                decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              crossAxisAlignment: sender == 'user' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(sender == 'user' ? 'You' : 'Chatbot', style: Theme.of(context).textTheme.titleMedium),
                Container(margin: const EdgeInsets.only(top: 5.0), child: Text(text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
