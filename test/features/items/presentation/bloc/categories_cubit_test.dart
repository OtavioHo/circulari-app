import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/usecases/get_categories_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/categories_cubit.dart';

import '../../../../helpers/fixtures.dart';

class MockGetCategoriesUsecase extends Mock implements GetCategoriesUsecase {}

void main() {
  late MockGetCategoriesUsecase getCategories;

  setUp(() => getCategories = MockGetCategoriesUsecase());

  CategoriesCubit buildCubit() => CategoriesCubit(getCategories);

  test('initial state is CategoriesInitial', () {
    expect(buildCubit().state, isA<CategoriesInitial>());
  });

  blocTest<CategoriesCubit, CategoriesState>(
    'emits [Loading, Success] with categories on load',
    build: buildCubit,
    setUp: () => when(() => getCategories())
        .thenAnswer((_) async => [tCategory]),
    act: (c) => c.load(),
    expect: () => [
      isA<CategoriesLoading>(),
      isA<CategoriesSuccess>()
          .having((s) => s.categories, 'categories', [tCategory]),
    ],
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'emits [Loading, Failure] on AppException',
    build: buildCubit,
    setUp: () => when(() => getCategories())
        .thenThrow(const NetworkException()),
    act: (c) => c.load(),
    expect: () => [
      isA<CategoriesLoading>(),
      isA<CategoriesFailure>().having(
        (s) => s.message,
        'message',
        'No internet connection.',
      ),
    ],
  );
}
