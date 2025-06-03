import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewModels/auth_view_model.dart';

class RegisterPage extends StatefulWidget {
  final bool isGoogleSignUp;
  final bool isFacebookSignUp;
  final Map<String, dynamic>? googleUserData;
  final Map<String, dynamic>? facebookUserData;
  final UserCredential? userCredential;

  const RegisterPage({
    super.key,
    this.isGoogleSignUp = false,
    this.isFacebookSignUp = false,
    this.googleUserData,
    this.facebookUserData,
    this.userCredential,
  });

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender;
  DateTime? _selectedBirthday;

  final List<String> _genders = ['男', '女', '其他'];

  @override
  void initState() {
    super.initState();
    if (widget.isGoogleSignUp && widget.googleUserData != null) {
      _emailController.text = widget.googleUserData!['email'] ?? '';
      _usernameController.text = widget.googleUserData!['username'] ?? '';
      _phoneController.text = widget.googleUserData!['phone'] ?? '';
    } else if (widget.isFacebookSignUp && widget.facebookUserData != null) {
      _emailController.text = widget.facebookUserData!['email'] ?? '';
      _usernameController.text = widget.facebookUserData!['username'] ?? '';
      _phoneController.text = widget.facebookUserData!['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSocialSignUp =
        widget.isGoogleSignUp || widget.isFacebookSignUp;
    final Map<String, dynamic>? socialUserData =
        widget.isGoogleSignUp ? widget.googleUserData : widget.facebookUserData;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSocialSignUp ? '完成註冊' : '註冊'),
        backgroundColor: Colors.grey[850],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar display for social login users
                  if (isSocialSignUp && socialUserData?['avatar'] != null)
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            socialUserData!['avatar'],
                          ),
                          backgroundColor: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          widget.isGoogleSignUp ? 'Google 頭像' : 'Facebook 頭像',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 32),
                      ],
                    ),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '使用者名稱',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入使用者名稱';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email field (disabled for social sign up)
                  TextFormField(
                    controller: _emailController,
                    enabled: !isSocialSignUp,
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

                  // Password fields (only for email registration)
                  if (!isSocialSignUp) ...[
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
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: '確認密碼',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請確認密碼';
                        }
                        if (value != _passwordController.text) {
                          return '密碼不一致';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                  ],

                  // Gender dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: '性別',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        _genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Country field
                  TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: '國家',
                      prefixIcon: Icon(Icons.public),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Birthday field
                  InkWell(
                    onTap: _selectBirthday,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '生日',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _selectedBirthday != null
                            ? '${_selectedBirthday!.year}/${_selectedBirthday!.month}/${_selectedBirthday!.day}'
                            : '選擇生日',
                        style: TextStyle(
                          color:
                              _selectedBirthday != null
                                  ? Colors.white
                                  : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: '電話',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !RegExp(r'^\d{10}$').hasMatch(value)) {
                        return '請輸入正確的電話號碼';
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

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          authViewModel.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                isSocialSignUp ? '完成註冊' : '註冊',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      bool success;

      if (widget.isGoogleSignUp) {
        // Google 註冊完成
        success = await authViewModel.completeGoogleRegistration(
          userCredential: widget.userCredential!,
          username: _usernameController.text.trim(),
          gender: _selectedGender,
          country:
              _countryController.text.trim().isEmpty
                  ? null
                  : _countryController.text.trim(),
          birthday: _selectedBirthday,
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          avatar: widget.googleUserData?['avatar'],
        );
      } else if (widget.isFacebookSignUp) {
        // Facebook 註冊完成
        success = await authViewModel.completeFacebookRegistration(
          userCredential: widget.userCredential!,
          username: _usernameController.text.trim(),
          gender: _selectedGender,
          country:
              _countryController.text.trim().isEmpty
                  ? null
                  : _countryController.text.trim(),
          birthday: _selectedBirthday,
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          avatar: widget.facebookUserData?['avatar'],
        );
      } else {
        // 一般 Email 註冊
        success = await authViewModel.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          gender: _selectedGender,
          country:
              _countryController.text.trim().isEmpty
                  ? null
                  : _countryController.text.trim(),
          birthday: _selectedBirthday,
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
        );
      }

      if (success) {
        // 顯示成功訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('註冊成功！'), backgroundColor: Colors.green[800]),
        );

        // 修正導航邏輯
        if (widget.isGoogleSignUp || widget.isFacebookSignUp) {
          // Social login 註冊完成，直接回傳成功並關閉所有相關頁面
          Navigator.of(context).pop(true); // 返回到登入頁面
        } else {
          // Email 註冊完成，返回到登入頁面
          Navigator.pop(context);
        }
      }
    }
  }
}
