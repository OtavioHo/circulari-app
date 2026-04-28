import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';

const tUser = User(
  id: 'user-1',
  email: 'jane@example.com',
  name: 'Jane Doe',
);

const tUserModel = UserModel(
  id: 'user-1',
  email: 'jane@example.com',
  name: 'Jane Doe',
);

const tUserJson = {
  'id': 'user-1',
  'email': 'jane@example.com',
  'name': 'Jane Doe',
};

const tAccessToken = 'access-token-xyz';
const tRefreshToken = 'refresh-token-xyz';
