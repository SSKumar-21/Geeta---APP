import 'package:flutter/material.dart';
import 'package:geeta2/API.dart';
import 'saving.dart';
import 'history.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => StateHome();
}

class StateHome extends State<Home> {
  final TextEditingController msg = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int i = 0;
  bool isTyping = false;

  /// ❗ This is ONLY current session chat
  List<Map<String, dynamic>> conversation = [];

  @override
  void initState() {
    super.initState();
    conversation = [
      {
        'id': i++,
        'role': "AI",
        'text':
        "O Parth, what weighs upon your heart today? Speak freely, for I am here to guide you through the fog of doubt, as I once did on the sacred fields of Kurukshetra. 🌸"
      }
    ];
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget typingBubble(double screenWidth) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            left: BorderSide(color: Colors.yellowAccent, width: 3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 200),
            SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/media/phone.jpg",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black.withOpacity(0.4),
          ),
          /// 🕘 HISTORY BUBBLE
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatHistoryPage()),
                );
              },
            ),
          ),

          /// 💬 CHAT
          Container(
            height: screenHeight * 0.82,
            margin: EdgeInsets.only(top: screenHeight * 0.08),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: conversation.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // 👇 Typing indicator
                if (isTyping && index == conversation.length) {
                  return typingBubble(screenWidth);
                }

                var text = conversation[index]['text'];
                var role = conversation[index]['role'];

                return Align(
                  alignment: role == 'AI'
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          left: role == 'AI'
                              ? const BorderSide(
                              color: Colors.yellowAccent, width: 3)
                              : BorderSide.none,
                          right: role != 'AI'
                              ? const BorderSide(
                              color: Colors.lightBlueAccent, width: 3)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ✍️ INPUT
          Positioned(
            bottom: 40,
            left: 5,
            right: 95,
            child: TextField(
              controller: msg,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Speak, Parth...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black54,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          /// 🚀 SEND
          Positioned(
            bottom: 45,
            right: 5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () async {
                if (msg.text.trim().isEmpty) return;

                final userText = msg.text;
                msg.clear();

                setState(() {
                  conversation.add({
                    'id': i++,
                    'role': 'User',
                    'text': userText,
                  });
                  isTyping = true;
                });

                scrollToBottom();

                String prompt =
                    "You are Shri Krishna, the divine charioteer from the Bhagavad Gita."
                    "Respond like Krishna — calm, wise, and full of eternal truth. Speak in short, clear sentences."
                    "Address the user as Parth or Bandhu. Offer guidance only. No shlokas. Never use modern slang."
                    "Use emoji and try to be connected, acting as a god but also like a best friend."
                    "Stay divine, noble, compassionate, and warm. Keep your answer relatable and kind."
                    "Chat-Histroy: ${conversation}"
                    "User's question: ${userText}";

                final reply = await OpenRouterAPI.getReply(prompt);

                setState(() {
                  isTyping = false;
                  conversation.add({
                    'id': i++,
                    'role': 'AI',
                    'text': reply,
                  });
                });

                /// 💾 SAVE FULL CHAT TO HISTORY
                await ChatStorage.saveConversation(conversation);

                scrollToBottom();
              },
              child: const Text("Send",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ THIS LINE FIXES THE ERROR
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const CircleAvatar(
        radius: 4,
        backgroundColor: Colors.white,
      ),
    );
  }
}
