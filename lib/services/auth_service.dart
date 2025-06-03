import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 先檢查 Google Sign-In 是否可用
      if (!await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // 清除可能的舊狀態
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 登入已取消');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 檢查是否有必要的 token
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google 認證失敗，請重試');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      // 檢查是否為新用戶
      bool isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // 新用戶，返回需要註冊的資訊
        return {
          'isNewUser': true,
          'userCredential': result,
          'googleUserData': {
            'email': googleUser.email,
            'username': googleUser.displayName ?? '',
            'avatar': googleUser.photoUrl,
            'phone': null,
          },
        };
      } else {
        // 已存在用戶，獲取用戶資料
        try {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(result.user!.uid).get();

          if (userDoc.exists) {
            UserModel userModel = UserModel.fromMap(
              userDoc.data() as Map<String, dynamic>,
            );
            print(
              'Google user logged in: ${userModel.username} (${userModel.email})',
            );
            print('Avatar: ${userModel.avatar}');
          }
        } catch (e) {
          print('Error fetching user data: $e');
        }

        return {'isNewUser': false, 'userCredential': result};
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('此 Email 已使用其他方式註冊，請使用原本的登入方式');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Google 認證無效，請重試');
      } else {
        throw Exception('登入失敗：${e.message}');
      }
    } catch (e) {
      print('Google sign in error: $e');
      if (e.toString().contains('sign_in_failed')) {
        throw Exception('Google 登入設定錯誤，請檢查應用程式配置');
      } else if (e.toString().contains('network_error')) {
        throw Exception('網路連線錯誤，請檢查網路連線');
      } else {
        throw Exception('Google 登入失敗，請重試');
      }
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
    String? avatar,
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
        avatar: avatar,
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

  Future<UserCredential?> completeGoogleRegistration({
    required UserCredential userCredential,
    required String username,
    String? gender,
    String? country,
    DateTime? birthday,
    String? phone,
    String? avatar,
  }) async {
    try {
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        username: username,
        gender: gender,
        country: country,
        birthday: birthday,
        phone: phone,
        avatar: avatar,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      print(
        'Google user registration completed: ${userModel.username} (${userModel.email})',
      );
      return userCredential;
    } catch (e) {
      print('Google registration completion error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      print('User signed out');
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
