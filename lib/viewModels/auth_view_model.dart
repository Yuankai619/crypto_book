import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthViewModel() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = _authService.currentUser;

    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmail(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Map<String, dynamic> result = await _authService.signInWithGoogle();
      return result;
    } on Exception catch (e) {
      // 處理自定義異常
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } catch (e) {
      // 處理其他錯誤
      print('Unexpected error in signInWithGoogle: $e');
      _error = 'Google 登入發生未知錯誤，請重試';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    String? gender,
    String? country,
    DateTime? birthday,
    String? phone,
    String? avatar,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.registerWithEmail(
        email: email,
        password: password,
        username: username,
        gender: gender,
        country: country,
        birthday: birthday,
        phone: phone,
        avatar: avatar,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeGoogleRegistration({
    required UserCredential userCredential,
    required String username,
    String? gender,
    String? country,
    DateTime? birthday,
    String? phone,
    String? avatar,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.completeGoogleRegistration(
        userCredential: userCredential,
        username: username,
        gender: gender,
        country: country,
        birthday: birthday,
        phone: phone,
        avatar: avatar,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
