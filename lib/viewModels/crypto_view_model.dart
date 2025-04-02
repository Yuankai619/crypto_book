import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/crypto_currency.dart';

class CryptoViewModel {
  List<CryptoCurrency> mainstream = [];
  List<CryptoCurrency> stablecoins = [];
  List<CryptoCurrency> memecoins = [];
  bool isLoading = false;
  String? error;

  Future<void> loadData() async {
    try {
      isLoading = true;
      error = null;

      final String response = await rootBundle.loadString(
        'assets/data/crypto_data.json',
      );
      print(
        'JSON loaded: ${response.substring(0, min(100, response.length))}...',
      );

      final data = json.decode(response);

      if (data['mainstream'] == null) {
        throw Exception("Missing 'mainstream' key in JSON data");
      }
      if (data['stablecoins'] == null) {
        throw Exception("Missing 'stablecoins' key in JSON data");
      }
      if (data['memecoins'] == null) {
        throw Exception("Missing 'memecoins' key in JSON data");
      }

      mainstream =
          (data['mainstream'] as List)
              .map((i) => CryptoCurrency.fromJson(i))
              .toList();

      stablecoins =
          (data['stablecoins'] as List)
              .map((i) => CryptoCurrency.fromJson(i))
              .toList();

      memecoins =
          (data['memecoins'] as List)
              .map((i) => CryptoCurrency.fromJson(i))
              .toList();

      print('Data loaded successfully:');
      print('Mainstream coins: ${mainstream.length}');
      print('Stablecoins: ${stablecoins.length}');
      print('Memecoins: ${memecoins.length}');
    } catch (e) {
      error = e.toString();
      print('Error loading data: $error');
    } finally {
      isLoading = false;
    }
  }
}
