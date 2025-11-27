class User {
  final int id;
  final String loginId;
  final String realName;
  final String nickname;
  final String? email;
  final int? birthYear;
  final String? gender;
  final String status;
  final bool isVerified;

  const User({
    required this.id,
    required this.loginId,
    required this.realName,
    required this.nickname,
    this.email,
    this.birthYear,
    this.gender,
    required this.status,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      loginId: json['login_id'] as String,
      realName: json['real_name'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String?,
      birthYear: json['birth_year'] as int?,
      gender: json['gender'] as String?,
      status: json['status'] as String? ?? 'active',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login_id': loginId,
      'real_name': realName,
      'nickname': nickname,
      'email': email,
      'birth_year': birthYear,
      'gender': gender,
      'status': status,
      'is_verified': isVerified,
    };
  }
}
