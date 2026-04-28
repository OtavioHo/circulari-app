import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/items/domain/repositories/items_repository.dart';
import 'package:app/features/items/domain/usecases/upload_item_image_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late UploadItemImageUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = UploadItemImageUsecase(repository);
  });

  test('forwards itemId and imagePath, returns updated item', () async {
    final item = tItem();
    when(() => repository.uploadItemImage(any(), any()))
        .thenAnswer((_) async => item);

    final result = await usecase('item-1', '/tmp/x.jpg');

    expect(result, item);
    verify(() => repository.uploadItemImage('item-1', '/tmp/x.jpg')).called(1);
  });
}
