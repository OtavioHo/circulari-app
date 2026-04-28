import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/items/domain/entities/ai_analysis_result.dart';
import 'package:app/features/items/domain/entities/category.dart';
import 'package:app/features/items/domain/entities/item.dart';
import 'package:app/features/lists/domain/entities/item_list.dart';
import 'package:app/features/lists/domain/entities/list_color.dart';
import 'package:app/features/lists/domain/entities/list_icon.dart';
import 'package:app/features/lists/domain/entities/list_picture.dart';

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

const tCategory = Category(id: 'cat-1', name: 'Books');

Item tItem({
  String id = 'item-1',
  String listId = 'list-1',
  String name = 'Test Item',
  int quantity = 1,
  double? userDefinedValue = 10.0,
}) =>
    Item(
      id: id,
      listId: listId,
      name: name,
      quantity: quantity,
      userDefinedValue: userDefinedValue,
      images: const [],
      createdAt: DateTime(2024, 1, 1),
    );

const tAiResult = AiAnalysisResult(
  name: 'Detected Item',
  description: 'AI description',
  category: 'Books',
  categoryId: 'cat-1',
  priceMin: 12.0,
  priceMax: 30.0,
);

const tListColor = ListColor(hexCode: '#FF0000', name: 'Red', order: 0);
const tListIcon = ListIcon(slug: 'home', name: 'Home', order: 0);
const tListPicture = ListPicture(slug: 'nature', order: 0);

ItemList tItemList({
  String id = 'list-1',
  String name = 'Books',
  int itemCount = 0,
  double totalValue = 0.0,
}) =>
    ItemList(
      id: id,
      name: name,
      color: tListColor,
      icon: tListIcon,
      picture: tListPicture,
      itemCount: itemCount,
      totalValue: totalValue,
      createdAt: DateTime(2024, 1, 1),
    );
