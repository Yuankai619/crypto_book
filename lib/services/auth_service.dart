import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("result.user: ${result.user}");
      // Get user data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      if (userDoc.exists) {
        UserModel userModel = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );
        print('User logged in: ${userModel.username} (${userModel.email})');
        print('Gender: ${userModel.gender}');
        print('Country: ${userModel.country}');
        print('Birthday: ${userModel.birthday}');
        print('Phone: ${userModel.phone}');
      }

      return result;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String username,
    String? gender,
    String? country,
    DateTime? birthday,
    String? phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      UserModel userModel = UserModel(
        uid: result.user!.uid,
        email: email,
        username: username,
        gender: gender,
        country: country,
        birthday: birthday,
        phone: phone,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userModel.toMap());
      print("result.user: ${result.user}");
      print('User registered: ${userModel.username} (${userModel.email})');
      return result;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
