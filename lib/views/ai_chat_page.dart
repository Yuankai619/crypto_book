import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../viewModels/ai_chat_view_model.dart';
import '../viewModels/crypto_view_model.dart';
import '../models/chat_message.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize chat after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiChatViewModel>(context, listen: false).initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI 投資顧問'),
          ],
        ),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AiChatViewModel>(context, listen: false).clearChat();
            },
            tooltip: '清空對話',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<AiChatViewModel>(
              builder: (context, chatViewModel, child) {
                // Handle initialization error
                if (chatViewModel.error != null &&
                    chatViewModel.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '初始化聊天室時發生錯誤',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          chatViewModel.error!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            chatViewModel.clearError();
                            chatViewModel.initializeChat();
                          },
                          child: Text('重試'),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: chatViewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatViewModel.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == MessageType.user;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 16,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[700] : Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  message.isLoading
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            message.content,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                      : isUser
                      ? Text(
                        message.content,
                        style: TextStyle(color: Colors.white),
                      )
                      : MarkdownBody(
                        data: message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(color: Colors.white, fontSize: 14),
                          h1: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          strong: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          em: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                          code: TextStyle(
                            color: Colors.orange[300],
                            backgroundColor: Colors.grey[700],
                            fontFamily: 'monospace',
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquote: TextStyle(
                            color: Colors.grey[300],
                            fontStyle: FontStyle.italic,
                          ),
                          listBullet: TextStyle(color: Colors.white),
                          tableHead: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          tableBody: TextStyle(color: Colors.white),
                          tableBorder: TableBorder.all(
                            color: Colors.grey[600]!,
                            width: 1,
                          ),
                        ),
                        selectable: true,
                      ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Consumer2<AiChatViewModel, CryptoViewModel>(
        builder: (context, chatViewModel, cryptoViewModel, child) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '輸入您的問題...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted:
                      (value) => _sendMessage(chatViewModel, cryptoViewModel),
                ),
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                onPressed:
                    chatViewModel.isLoading
                        ? null
                        : () => _sendMessage(chatViewModel, cryptoViewModel),
                mini: true,
                backgroundColor: Colors.blue[700],
                child:
                    chatViewModel.isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.send, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sendMessage(
    AiChatViewModel chatViewModel,
    CryptoViewModel cryptoViewModel,
  ) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      chatViewModel.sendMessage(message, cryptoViewModel.coins);
    }
  }
}
