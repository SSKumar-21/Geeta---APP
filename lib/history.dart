import 'package:flutter/material.dart';
import 'saving.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    final data = await ChatStorage.loadConversation();
    setState(() {
      history = data;
    });

    // Scroll to bottom after load
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 Background (History Image)
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              "assets/media/his.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔙 Back button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          /// 📜 Chat History Container
          Container(
            height: screenHeight * 0.88,
            width: screenWidth * 0.96,
            margin: EdgeInsets.only(
              left: screenWidth * 0.02,
              top: screenHeight * 0.08,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: history.isEmpty
                ? const Center(
              child: Text(
                "No history yet",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: history.length,
              itemBuilder: (context, index) {
                final msg = history[index];
                final role = msg['role'];
                final text = msg['text'];

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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
