class UserProfile {
  final String email;
  final String fullName;
  final String gender;
  final int age;
  final String nickname;
  final DateTime registeredAt;
  final int totalQuizCompleted;

  UserProfile({
    required this.email,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.nickname,
    required this.registeredAt,
    this.totalQuizCompleted = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      nickname: json['nickname'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      totalQuizCompleted: json['totalQuizCompleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'nickname': nickname,
      'registeredAt': registeredAt.toIso8601String(),
      'totalQuizCompleted': totalQuizCompleted,
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? gender,
    int? age,
    String? nickname,
    DateTime? registeredAt,
    int? totalQuizCompleted,
  }) {
    return UserProfile(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      nickname: nickname ?? this.nickname,
      registeredAt: registeredAt ?? this.registeredAt,
      totalQuizCompleted: totalQuizCompleted ?? this.totalQuizCompleted,
    );
  }
}
