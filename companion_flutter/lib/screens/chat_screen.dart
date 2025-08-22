import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _messages.addAll(StorageService.loadMessages());
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _messages.add(Message(sender: 'user', text: text));
      _controller.clear();
      _busy = true;
    });
    try {
      final reply = await ApiService.chat(text);
      setState(() {
        _messages.add(Message(sender: 'ai', text: reply));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(sender: 'ai', text: 'Error: $e'));
      });
    } finally {
      setState(() => _busy = false);
      StorageService.cacheMessages(_messages.take(50).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Companion')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => MessageBubble(
                text: _messages[i].text,
                isUser: _messages[i].sender == 'user',
              ),
            ),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
