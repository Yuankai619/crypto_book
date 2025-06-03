import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewModels/auth_view_model.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登入'), backgroundColor: Colors.grey[850]),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 32),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入 Email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return '請輸入正確的 Email 格式';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密碼',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入密碼';
                      }
                      if (value.length < 6) {
                        return '密碼長度必須大於 6 位';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Error message
                  if (authViewModel.error != null)
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authViewModel.error!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          authViewModel.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('登入', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('或'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Google login button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: authViewModel.isLoading ? null : _googleLogin,
                      icon: Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: Colors.white,
                      ),

                      label: Text('使用 Google 登入'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Facebook login button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed:
                          authViewModel.isLoading ? null : _facebookLogin,
                      icon: Icon(
                        Icons.facebook,
                        color: Color(0xFF1877F2),
                        size: 24,
                      ),
                      label: Text('使用 Facebook 登入'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF1877F2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Register link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text('還沒有帳號？註冊新帳號'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      bool success = await authViewModel.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  void _googleLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // 清除之前的錯誤
    authViewModel.clearError();

    Map<String, dynamic>? result = await authViewModel.signInWithGoogle();

    if (result != null) {
      if (result['isNewUser']) {
        // 新用戶，導向註冊頁面
        final registerResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RegisterPage(
                  isGoogleSignUp: true,
                  googleUserData: result['googleUserData'],
                  userCredential: result['userCredential'],
                ),
          ),
        );

        // 如果註冊成功，關閉登入頁面
        if (registerResult == true) {
          Navigator.pop(context);
        }
      } else {
        // 已存在用戶，直接登入
        Navigator.pop(context);
      }
    } else {
      // 顯示錯誤訊息
      if (authViewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.error!),
            backgroundColor: Colors.red[800],
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _facebookLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // 清除之前的錯誤
    authViewModel.clearError();

    Map<String, dynamic>? result = await authViewModel.signInWithFacebook();

    if (result != null) {
      if (result['isNewUser']) {
        // 新用戶，導向註冊頁面
        final registerResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RegisterPage(
                  isFacebookSignUp: true,
                  facebookUserData: result['facebookUserData'],
                  userCredential: result['userCredential'],
                ),
          ),
        );

        // 如果註冊成功，關閉登入頁面
        if (registerResult == true) {
          Navigator.pop(context);
        }
      } else {
        // 已存在用戶，直接登入
        Navigator.pop(context);
      }
    } else {
      // 顯示錯誤訊息
      if (authViewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.error!),
            backgroundColor: Colors.red[800],
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
