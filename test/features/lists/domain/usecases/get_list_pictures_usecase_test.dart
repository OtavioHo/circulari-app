import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_pictures_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late GetListPicturesUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = GetListPicturesUsecase(repository);
  });

  test('returns pictures from repository', () async {
    when(() => repository.getPictures())
        .thenAnswer((_) async => const [tListPicture]);

    final result = await usecase();

    expect(result, const [tListPicture]);
    verify(() => repository.getPictures()).called(1);
  });
}
