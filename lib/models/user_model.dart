class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? gender;
  final String? country;
  final DateTime? birthday;
  final String? phone;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.gender,
    this.country,
    this.birthday,
    this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      gender: map['gender'],
      country: map['country'],
      birthday:
          map['birthday'] != null ? DateTime.parse(map['birthday']) : null,
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'gender': gender,
      'country': country,
      'birthday': birthday?.toIso8601String(),
      'phone': phone,
    };
  }
}
