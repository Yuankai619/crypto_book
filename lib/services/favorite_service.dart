import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite.dart';
import '../models/crypto_currency.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<bool> addToFavorites(CryptoCurrency coin) async {
    if (_currentUserId == null) return false;

    try {
      final favoriteId = '${_currentUserId}_${coin.id}';
      final favorite = Favorite(
        id: favoriteId,
        userId: _currentUserId!,
        coinId: coin.id,
        coinName: coin.name,
        coinSymbol: coin.symbol,
        imageUrl: coin.imageUrl,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('favorites')
          .doc(favoriteId)
          .set(favorite.toMap());

      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String coinId) async {
    if (_currentUserId == null) return false;

    try {
      final favoriteId = '${_currentUserId}_$coinId';
      await _firestore.collection('favorites').doc(favoriteId).delete();
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String coinId) async {
    if (_currentUserId == null) return false;

    try {
      final favoriteId = '${_currentUserId}_$coinId';
      final doc =
          await _firestore.collection('favorites').doc(favoriteId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Stream<List<Favorite>> getFavorites() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    // 移除 orderBy 來避免索引問題，改為在客戶端排序
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          final favorites =
              snapshot.docs.map((doc) => Favorite.fromMap(doc.data())).toList();

          // 在客戶端按創建時間排序
          favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return favorites;
        });
  }
}
