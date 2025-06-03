import 'package:flutter/material.dart';
import 'dart:async';
import '../models/favorite.dart';
import '../models/crypto_currency.dart';
import '../services/favorite_service.dart';

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  StreamSubscription<List<Favorite>>? _favoritesSubscription;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FavoriteViewModel() {
    // 移除自動初始化，改為手動初始化
  }

  void initializeFavorites() {
    if (_initialized) return;
    _initialized = true;
    _loadFavorites();
  }

  void _loadFavorites() {
    print('Loading favorites...');
    // 取消之前的訂閱
    _favoritesSubscription?.cancel();

    _favoritesSubscription = _favoriteService.getFavorites().listen(
      (favorites) {
        print('Received ${favorites.length} favorites');
        _favorites = favorites;
        _error = null; // 清除錯誤狀態
        if (_initialized) {
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error loading favorites: $error');
        _error = '載入收藏失敗，請檢查網路連線';
        if (_initialized) {
          notifyListeners();
        }
      },
    );
  }

  Future<bool> addToFavorites(CryptoCurrency coin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _favoriteService.addToFavorites(coin);
      if (success) {
        print('Successfully added ${coin.name} to favorites');
        // 不需要手動刷新，Stream 會自動更新
      }
      return success;
    } catch (e) {
      print('Error adding to favorites: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromFavorites(String coinId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _favoriteService.removeFromFavorites(coinId);
      if (success) {
        print('Successfully removed $coinId from favorites');
        // 不需要手動刷新，Stream 會自動更新
      }
      return success;
    } catch (e) {
      print('Error removing from favorites: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String coinId) async {
    try {
      return await _favoriteService.isFavorite(coinId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  void refreshFavorites() {
    if (_initialized) {
      _loadFavorites();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
