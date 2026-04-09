import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;
    return UserModel(
      id: (userData?['id']?.toString()) ?? '',
      email: userData?['email'] ?? '',
      name: userData?['role'] ?? '',
      token: json['access_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'token': token,
  };
}
