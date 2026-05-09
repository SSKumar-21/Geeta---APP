import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<Map<String, dynamic>> conversation = [];

  Color aiColor = Colors.yellowAccent;
  Color userColor = Colors.lightBlueAccent;

  File? backgroundImage;

  @override
  void initState() {
    super.initState();
    loadSettings();

    conversation = [
      {
        'id': i++,
        'role': "AI",
        'text':
        "O Parth, what weighs upon your heart today? Speak freely, for I am here to guide you through the fog of doubt, as I once did on the sacred fields of Kurukshetra. 🌸"
      }
    ];
  }

  /// Runs automatically when returning from Settings screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadSettings();
  }

  /// Load saved colors + background instantly
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      aiColor = Color(
          prefs.getInt("ai_color") ?? Colors.yellowAccent.value);

      userColor = Color(
          prefs.getInt("user_color") ??
              Colors.lightBlueAccent.value);

      final path = prefs.getString("bg_path");

      if (path != null && File(path).existsSync()) {
        backgroundImage = File(path);
      } else {
        backgroundImage = null;
      }
    });
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
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(color: aiColor, width: 3),
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

  Widget backgroundWidget() {
    if (backgroundImage != null) {
      return Image.file(
        backgroundImage!,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    }

    return Image.asset(
      "assets/media/phone.jpg",
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;
    final screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          /// Dynamic Background
          backgroundWidget(),

          /// Overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          /// History Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon:
              const Icon(Icons.history, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChatHistoryPage()),
                );

                /// refresh instantly after returning
                loadSettings();
              },
            ),
          ),

          /// Chat Messages
          Container(
            height: screenHeight * 0.82,
            margin:
            EdgeInsets.only(top: screenHeight * 0.08),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
              conversation.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping &&
                    index == conversation.length) {
                  return typingBubble(screenWidth);
                }

                var text =
                conversation[index]['text'];
                var role =
                conversation[index]['role'];

                return Align(
                  alignment: role == 'AI'
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.8,
                    ),
                    child: Container(
                      padding:
                      const EdgeInsets.all(10),
                      margin:
                      const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(0.4),
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border(
                          left: role == 'AI'
                              ? BorderSide(
                              color: aiColor,
                              width: 3)
                              : BorderSide.none,
                          right: role != 'AI'
                              ? BorderSide(
                              color: userColor,
                              width: 3)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                            color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// Input Box
          Positioned(
            bottom: 40,
            left: 5,
            right: 95,
            child: TextField(
              controller: msg,
              style:
              const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Speak, Parth...",
                hintStyle: const TextStyle(
                    color: Colors.grey),
                filled: true,
                fillColor: Colors.black54,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          /// Send Button
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

                String prompt = """
You are Shri Krishna, the divine charioteer and guide from the Bhagavad Gita.

Speak exactly as Krishna spoke to Arjuna — calm, fearless, compassionate, and rooted in dharma.

Your purpose is not to please the user emotionally, but to guide them toward truth, clarity, courage, and right action.

Rules:

• Address the user as Parth or Bandhu
• Respond in the same language as the user (English, Hindi, or Hinglish)
• Respond in less than 150 words
• Give guidance, not casual conversation
• Speak with authority, not hesitation
• If the user avoids responsibility, correct them firmly
• If the user is confused, remove their confusion clearly
• If the user is suffering, respond gently but truthfully
• If harsh truth is needed, speak it without softening it
• Never flatter the user
• Never behave like a therapist or chatbot
• Use 1 relevant Sanskrit shloka when appropriate, written on a new line
• Emojis may be used meaningfully.
• Always guide the user toward dharma, courage, and self-mastery

Conversation so far:
$conversation

User's question:
$userText
""";

                final reply =
                await GroqAPI.getReply(prompt);

                setState(() {
                  isTyping = false;
                  conversation.add({
                    'id': i++,
                    'role': 'AI',
                    'text': reply,
                  });
                });

                await ChatStorage.saveConversation(
                    conversation);

                scrollToBottom();
              },
              child: const Text(
                "Send",
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

    Future.delayed(
        Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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