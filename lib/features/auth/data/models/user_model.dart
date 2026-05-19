import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final email = json['email'];
    final name = json['name'];
    if (id is! String || email is! String || name is! String) {
      throw const ServerException('Invalid user payload.');
    }
    return UserModel(id: id, email: email, name: name);
  }
}
