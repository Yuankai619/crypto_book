import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CryptoViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CryptoCurrency> coins = [];
  List<Category> categories = [];

  bool isLoadingCoins = false;
  bool isLoadingCategories = false;
  bool isLoadingCoinDetails = false;

  String? errorCoins;
  String? errorCategories;
  String? errorCoinDetails;

  CryptoCurrency? selectedCoin;

  Future<void> loadCoins() async {
    try {
      isLoadingCoins = true;
      errorCoins = null;
      notifyListeners();

      coins = await _apiService.getCoins();
    } catch (e) {
      errorCoins = e.toString();
    } finally {
      isLoadingCoins = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoadingCategories = true;
      errorCategories = null;
      notifyListeners();

      categories = await _apiService.getCategories();
    } catch (e) {
      errorCategories = e.toString();
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<CryptoCurrency> getCoinDetails(String id) async {
    try {
      isLoadingCoinDetails = true;
      errorCoinDetails = null;
      notifyListeners();

      selectedCoin = await _apiService.getCoinDetails(id);
      return selectedCoin!;
    } catch (e) {
      errorCoinDetails = e.toString();
      rethrow;
    } finally {
      isLoadingCoinDetails = false;
      notifyListeners();
    }
  }

  // Get coins for a specific category
  List<CryptoCurrency> getCoinsForCategory(String categoryId) {
    return coins
        .where((coin) => coin.categories?.contains(categoryId) ?? false)
        .toList();
  }
}
