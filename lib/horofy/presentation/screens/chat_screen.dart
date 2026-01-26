import 'package:flutter/material.dart';
import 'package:horofy/horofy/presentation/widgets/message_bubble.dart.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {"text": "أهلاً! عامل إيه؟ 👋", "isMe": true},
    {"text": "تمام الحمد لله، وانت؟ 😊", "isMe": false},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Image.asset('assets/images/chat.jpg', fit: BoxFit.cover),
          ),

          // main content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                    //reverse: true,
                    
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return MessageBubble(
                        text: msg["text"],
                        isMe: msg["isMe"],
                      );
                    },
                  ),
                ),

                // input bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: const TextStyle(color: Colors.grey),
                            hintText: 'ﺇسأل شلبى',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: _controller.text.trim().isEmpty
                              ? null
                              : () {
                                  // UI-only: append message locally as a preview
                                  setState(() {
                                    _messages.add({
                                      "text": _controller.text.trim(),
                                      "isMe": true,
                                    });
                                    _controller.clear();
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
