import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/auth_view_model.dart';
import '../viewModels/user_info_view_model.dart';
import '../models/user_model.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;

  String? _selectedGender;
  DateTime? _selectedBirthday;
  bool _isEditing = false;
  bool _isDataLoaded = false; // 新增標記來追蹤資料是否已載入

  final List<String> _genders = ['男', '女', '其他'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userInfoViewModel = Provider.of<UserInfoViewModel>(
        context,
        listen: false,
      );
      userInfoViewModel.loadUserInfo();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _loadUserData(UserModel user) {
    // 只在資料未載入或不在編輯模式時才更新控制器
    if (!_isDataLoaded || !_isEditing) {
      _usernameController.text = user.username;
      _phoneController.text = user.phone ?? '';
      _countryController.text = user.country ?? '';
      _selectedGender = user.gender;
      _selectedBirthday = user.birthday;
      _isDataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('個人資料'),
        backgroundColor: Colors.grey[850],
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // 取消編輯時重新載入原始資料
                      _isDataLoaded = false;
                    });
                  },
                  child: Text('取消', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: _saveUserInfo,
                  child: Text('保存', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
        ],
      ),
      body: Consumer2<UserInfoViewModel, AuthViewModel>(
        builder: (context, userInfoViewModel, authViewModel, child) {
          if (userInfoViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (userInfoViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    userInfoViewModel.error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userInfoViewModel.loadUserInfo(),
                    child: Text('重試'),
                  ),
                ],
              ),
            );
          }

          final user = userInfoViewModel.currentUser;
          if (user != null) {
            _loadUserData(user);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await userInfoViewModel.loadUserInfo();
              setState(() {
                _isDataLoaded = false; // 重新載入後重置標記
              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar section
                    _buildAvatarSection(user),
                    SizedBox(height: 32),

                    // User info form
                    _buildUserInfoForm(user),
                    SizedBox(height: 32),

                    // Action buttons
                    if (!_isEditing) _buildActionButtons(authViewModel),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(UserModel? user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[400],
          backgroundImage:
              user?.avatar != null ? NetworkImage(user!.avatar!) : null,
          child:
              user?.avatar == null
                  ? Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
        ),
        SizedBox(height: 16),
        Text(
          user?.username ?? 'Loading...',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          user?.email ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildUserInfoForm(UserModel? user) {
    return Column(
      children: [
        // Username field
        TextFormField(
          controller: _usernameController,
          enabled: _isEditing,
          decoration: InputDecoration(
            labelText: '使用者名稱',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入使用者名稱';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // Email field (read-only)
        TextFormField(
          initialValue: user?.email ?? '',
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 16),

        // Gender dropdown
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: '性別',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items:
              _genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
          onChanged:
              _isEditing
                  ? (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                  : null,
        ),
        SizedBox(height: 16),

        // Country field
        TextFormField(
          controller: _countryController,
          enabled: _isEditing,
          decoration: InputDecoration(
            labelText: '國家',
            prefixIcon: Icon(Icons.public),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 16),

        // Birthday field
        InkWell(
          onTap: _isEditing ? _selectBirthday : null,
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
                  : '未設定',
              style: TextStyle(
                color:
                    _selectedBirthday != null ? Colors.white : Colors.grey[400],
              ),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Phone field
        TextFormField(
          controller: _phoneController,
          enabled: _isEditing,
          decoration: InputDecoration(
            labelText: '電話',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      ],
    );
  }

  Widget _buildActionButtons(AuthViewModel authViewModel) {
    return Column(
      children: [
        // Logout button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(authViewModel),
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text(
              '登出',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Delete account button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showDeleteAccountDialog(authViewModel),
            icon: Icon(Icons.delete_forever),
            label: Text('刪除帳號'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
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

  void _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      final userInfoViewModel = Provider.of<UserInfoViewModel>(
        context,
        listen: false,
      );

      bool success = await userInfoViewModel.updateUserInfo(
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

      if (success) {
        setState(() {
          _isEditing = false;
          _isDataLoaded = true; // 保持資料已載入狀態
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('資料更新成功'), backgroundColor: Colors.green[800]),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失敗：${userInfoViewModel.error}'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  void _showLogoutDialog(AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('確認登出'),
            content: Text('您確定要登出嗎？'),
            backgroundColor: Colors.grey[850],
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  authViewModel.signOut();
                  Navigator.pop(context); // Return to previous page
                },
                child: Text('登出', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('確認刪除帳號'),
            content: Text('警告：此操作將永久刪除您的帳號和所有資料，且無法復原。您確定要繼續嗎？'),
            backgroundColor: Colors.grey[850],
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteAccount(authViewModel);
                },
                child: Text('刪除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount(AuthViewModel authViewModel) async {
    final userInfoViewModel = Provider.of<UserInfoViewModel>(
      context,
      listen: false,
    );

    bool success = await userInfoViewModel.deleteAccount();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('帳號已刪除'), backgroundColor: Colors.green[800]),
      );
      Navigator.pop(context); // Return to previous page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('刪除失敗：${userInfoViewModel.error}'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }
}
