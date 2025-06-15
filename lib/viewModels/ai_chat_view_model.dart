import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/crypto_currency.dart';
import '../services/ai_chat_service.dart';

class AiChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AiChatService? _aiChatServiceInstance;
  bool _aiServiceInitializationFailed = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initializeChat() {
    if (_isInitialized) return;

    try {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              '## 🤖 AI 投資顧問\n\n您好！我是您的虛擬貨幣投資顧問助手。\n\n### 💡 我可以協助您：\n- 分析市場趨勢\n- 解答投資問題\n- 提供即時的加密貨幣資訊\n- 風險評估建議\n\n請問有什麼我可以協助您的嗎？',
          type: MessageType.ai,
          timestamp: DateTime.now(),
        ),
      );
      _isInitialized = true;
      // _tryInitializeAiService(); // Attempt to initialize the AI service
      notifyListeners();
    } catch (e) {
      print('Error initializing chat: $e');
      _error = '初始化聊天室時發生錯誤：$e';
      notifyListeners();
    }
  }

  // void _tryInitializeAiService() {
  //   if (_aiChatServiceInstance != null || _aiServiceInitializationFailed) {
  //     return;
  //   }
  //   try {
  //     _aiChatServiceInstance = AiChatService();
  //     print("AiChatViewModel: AI Service initialized successfully.");
  //   } catch (e) {
  //     print(
  //       "AiChatViewModel: Failed to initialize AI Service in constructor: $e",
  //     );
  //     _aiServiceInitializationFailed = true;
  //     // Optionally set an error message to be displayed in the UI if needed
  //     // _error = "AI 功能初始化失敗: $e";
  //     // notifyListeners(); // Already called by initializeChat
  //   }
  // }

  Future<void> sendMessage(
    String message,
    List<CryptoCurrency> cryptoData,
  ) async {
    if (message.trim().isEmpty) return;

    ChatMessage? loadingMessage;

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
      loadingMessage = ChatMessage(
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

      String response;

      // Lazy initialize AI service when needed
      if (_aiChatServiceInstance == null && !_aiServiceInitializationFailed) {
        try {
          _aiChatServiceInstance = AiChatService();
          print("AiChatViewModel: AI Service initialized successfully.");
        } catch (e) {
          print("AiChatViewModel: Failed to initialize AI Service: $e");
          _aiServiceInitializationFailed = true;
        }
      }

      if (_aiServiceInitializationFailed || _aiChatServiceInstance == null) {
        print(
          'AiChatViewModel: AI Service not available or initialization failed. Using fallback.',
        );
        response = _generateFallbackResponse(
          message,
          cryptoData,
          "AI 服務未初始化或初始化失敗",
        );
      } else {
        try {
          response = await _aiChatServiceInstance!.sendMessage(
            message,
            cryptoData,
          );
        } catch (serviceError) {
          print(
            'AiChatViewModel: Error calling AI Service sendMessage: $serviceError',
          );
          response = _generateFallbackResponse(
            message,
            cryptoData,
            serviceError,
          );
        }
      }

      // Remove loading message
      _messages.removeWhere((msg) => msg.id == loadingMessage?.id);

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
    } catch (e) {
      print('AiChatViewModel: General error in sendMessage: $e');

      // Remove loading message if it exists
      if (loadingMessage != null) {
        _messages.removeWhere((msg) => msg.id == loadingMessage!.id);
      }

      // Generate a helpful error response
      final errorResponse = _generateErrorResponse(message, e);
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: errorResponse,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateFallbackResponse(
    String userMessage,
    List<CryptoCurrency> cryptoData,
    dynamic error,
  ) {
    // Generate a helpful response even when AI service fails
    final messageLower = userMessage.toLowerCase();

    if (messageLower.contains('bitcoin') || messageLower.contains('btc')) {
      final bitcoin =
          cryptoData
              .where((crypto) => crypto.symbol.toLowerCase() == 'btc')
              .firstOrNull;
      if (bitcoin != null) {
        return '''## ₿ 比特幣 (BTC) 資訊

### 📊 即時數據
- **當前價格：** `\$${bitcoin.currentPrice.toStringAsFixed(2)}`
- **市值排名：** `#${bitcoin.marketCapRank ?? 'N/A'}`
- **24小時漲跌：** `${bitcoin.priceChangePercentage24h?.toStringAsFixed(2) ?? '0.00'}%`

> ⚠️ **注意：** AI 服務暫時不可用，以上為即時市場資料。''';
      }
    } else if (messageLower.contains('ethereum') ||
        messageLower.contains('eth')) {
      final ethereum =
          cryptoData
              .where((crypto) => crypto.symbol.toLowerCase() == 'eth')
              .firstOrNull;
      if (ethereum != null) {
        return '''## 🔷 以太坊 (ETH) 資訊

### 📊 即時數據
- **當前價格：** `\$${ethereum.currentPrice.toStringAsFixed(2)}`
- **市值排名：** `#${ethereum.marketCapRank ?? 'N/A'}`
- **24小時漲跌：** `${ethereum.priceChangePercentage24h?.toStringAsFixed(2) ?? '0.00'}%`

> ⚠️ **注意：** AI 服務暫時不可用，以上為即時市場資料。''';
      }
    } else if (messageLower.contains('market') || messageLower.contains('市場')) {
      return '''## 📈 市場概況

### 🏆 前五大加密貨幣
${cryptoData.take(5).map((crypto) => '- **${crypto.name} (${crypto.symbol.toUpperCase()}):** `\$${crypto.currentPrice.toStringAsFixed(2)}` ${crypto.priceChangePercentage24h != null ? (crypto.priceChangePercentage24h! >= 0 ? '📈' : '📉') : ''}').join('\n')}

> ⚠️ **注意：** AI 分析功能暫時不可用，以上為即時市場資料。''';
    }

    return '''## ⚠️ 服務暫時不可用

AI 分析功能目前無法使用，但我仍可以為您提供：

### 📊 即時市場資料
目前追蹤 **${cryptoData.length}** 種加密貨幣的即時價格

### 💡 建議
- 請稍後再試 AI 分析功能
- 您可以先查看即時價格資訊
- 如問題持續，請檢查網路連線

> 🔧 **技術資訊：** ${error.toString()}''';
  }

  String _generateErrorResponse(String userMessage, dynamic error) {
    return '''## ❌ 處理訊息時發生錯誤

### 🔍 您的問題
$userMessage

### 💡 建議解決方案
1. **檢查網路連線** - 確保裝置已連接網路
2. **稍後重試** - 系統可能暫時繁忙
3. **重新啟動** - 嘗試重新開啟聊天室

### 🆘 如需協助
如果問題持續發生，請聯繫技術支援。

> 🔧 **錯誤資訊：** ${error.toString()}''';
  }

  void clearChat() {
    _messages.clear();
    _isInitialized = false;
    _error = null;
    // Reset AI service state as well
    _aiChatServiceInstance = null;
    _aiServiceInitializationFailed = false;
    initializeChat();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
