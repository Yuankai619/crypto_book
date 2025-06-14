import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_currency.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final String _apiKey = dotenv.env['LLM_API_KEY']!;
  Future<String> sendMessage(
    String message,
    List<CryptoCurrency> cryptoData,
  ) async {
    try {
      // Check if API key is set
      if (_apiKey.isEmpty) {
        return '請先設定 Google Gemini API 金鑰。請在 ai_chat_service.dart 檔案中將 YOUR_GEMINI_API_KEY 替換為您的實際 API 金鑰。';
      }

      // Prepare crypto context for AI
      String cryptoContext = _prepareCryptoContext(cryptoData);

      // Enhanced prompt with crypto context
      String enhancedPrompt = '''
你是一個專業的虛擬貨幣投資顧問助手。請根據以下即時加密貨幣資料來回答用戶問題：

$cryptoContext

用戶問題：$message

請用繁體中文回答，並使用 Markdown 格式來組織回應內容：
- 使用標題 (##, ###) 來組織主要段落
- 使用列表 (-, *) 來列出要點
- 使用 **粗體** 來強調重要資訊
- 使用 `程式碼格式` 來顯示價格或數據
- 使用 > 引用格式來顯示重要提醒

提供專業、準確的投資建議和市場分析。如果問題涉及特定貨幣價格，請使用上述即時資料。
注意：投資有風險，請謹慎評估。
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': enhancedPrompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return '抱歉，我無法處理您的請求。請稍後再試。';
        }
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return 'AI 服務暫時不可用。錯誤代碼：${response.statusCode}';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return '抱歉，發生網路錯誤。請檢查網路連線並稍後再試。';
    }
  }

  String _prepareCryptoContext(List<CryptoCurrency> cryptoData) {
    if (cryptoData.isEmpty) {
      return '目前沒有可用的加密貨幣資料。';
    }

    StringBuffer context = StringBuffer();
    context.writeln('【即時加密貨幣資料】');
    context.writeln('時間：${DateTime.now().toString()}');
    context.writeln('');

    // 取前20個加密貨幣資料
    final topCryptos = cryptoData.take(20).toList();

    for (var crypto in topCryptos) {
      context.writeln('${crypto.name} (${crypto.symbol.toUpperCase()}):');
      context.writeln('  - 當前價格: \$${crypto.currentPrice.toStringAsFixed(2)}');
      context.writeln('  - 市值: \$${_formatNumber(crypto.marketCap)}');
      if (crypto.marketCapRank != null) {
        context.writeln('  - 市值排名: #${crypto.marketCapRank}');
      }
      if (crypto.priceChangePercentage24h != null) {
        context.writeln(
          '  - 24小時漲跌: ${crypto.priceChangePercentage24h!.toStringAsFixed(2)}%',
        );
      }
      context.writeln('');
    }

    return context.toString();
  }

  String _formatNumber(double number) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(2)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toString();
    }
  }
}
