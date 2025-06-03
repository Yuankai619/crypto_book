import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserInfoViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserInfo() async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );
        print('User info loaded: ${_currentUser!.username}');
      }
    } catch (e) {
      print('Error loading user info: $e');
      _error = '載入使用者資料失敗';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserInfo({
    required String username,
    String? gender,
    String? country,
    DateTime? birthday,
    String? phone,
  }) async {
    if (_auth.currentUser == null || _currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        username: username,
        gender: gender,
        country: country,
        birthday: birthday,
        phone: phone,
        avatar: _currentUser!.avatar,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updatedUser.toMap());

      _currentUser = updatedUser;
      print('User info updated successfully');
      return true;
    } catch (e) {
      print('Error updating user info: $e');
      _error = '更新使用者資料失敗';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    if (_auth.currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser!.uid;

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete all user's favorites
      final favoritesQuery =
          await _firestore
              .collection('favorites')
              .where('userId', isEqualTo: userId)
              .get();

      for (var doc in favoritesQuery.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth account
      await _auth.currentUser!.delete();

      _currentUser = null;
      print('Account deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      _error = '刪除帳號失敗，請重新登入後再試';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
