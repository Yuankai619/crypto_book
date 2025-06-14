import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/crypto_currency.dart';
import '../services/ai_chat_service.dart';

class AiChatViewModel extends ChangeNotifier {
  AiChatService? _aiChatService;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AiChatService get _service {
    _aiChatService ??= AiChatService();
    return _aiChatService!;
  }

  void initializeChat() {
    if (_isInitialized) return;

    try {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              '您好！我是您的虛擬貨幣投資顧問助手。我可以幫您分析市場趨勢、解答投資問題，並提供即時的加密貨幣資訊。請問有什麼我可以協助您的嗎？',
          type: MessageType.ai,
          timestamp: DateTime.now(),
        ),
      );
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing chat: $e');
      _error = '初始化聊天室時發生錯誤：$e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String message,
    List<CryptoCurrency> cryptoData,
  ) async {
    if (message.trim().isEmpty) return;

    try {
      // Add user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message.trim(),
        type: MessageType.user,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);

      // Add loading AI message
      final loadingMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_loading',
        content: '正在思考中...',
        type: MessageType.ai,
        timestamp: DateTime.now(),
        isLoading: true,
      );
      _messages.add(loadingMessage);

      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _service.sendMessage(message, cryptoData);

      // Remove loading message
      _messages.removeWhere((msg) => msg.id == loadingMessage.id);

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
    } catch (e) {
      // Remove loading message if it exists
      _messages.removeWhere((msg) => msg.id.contains('_loading'));

      _error = e.toString();
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '抱歉，發生錯誤：$e',
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _isInitialized = false;
    initializeChat();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _aiChatService = null;
    super.dispose();
  }
}
