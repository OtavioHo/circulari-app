import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/lists/domain/entities/list_color.dart';
import 'package:circulari/features/lists/domain/usecases/create_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_colors_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_icons_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_pictures_usecase.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_cubit.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_state.dart';

import '../../../../helpers/fixtures.dart';

class MockGetColors extends Mock implements GetListColorsUsecase {}

class MockGetIcons extends Mock implements GetListIconsUsecase {}

class MockGetPictures extends Mock implements GetListPicturesUsecase {}

class MockCreateList extends Mock implements CreateListUsecase {}

void main() {
  late MockGetColors getColors;
  late MockGetIcons getIcons;
  late MockGetPictures getPictures;
  late MockCreateList createList;

  setUp(() {
    getColors = MockGetColors();
    getIcons = MockGetIcons();
    getPictures = MockGetPictures();
    createList = MockCreateList();
  });

  CreateListCubit buildCubit() => CreateListCubit(
        getColors: getColors,
        getIcons: getIcons,
        getPictures: getPictures,
        createList: createList,
      );

  void stubOptionsHappyPath() {
    when(() => getColors()).thenAnswer((_) async => [tListColor]);
    when(() => getIcons()).thenAnswer((_) async => [tListIcon]);
    when(() => getPictures()).thenAnswer((_) async => [tListPicture]);
  }

  void stubCreateOk() {
    when(() => createList(
          name: any(named: 'name'),
          location: any(named: 'location'),
          colorId: any(named: 'colorId'),
          iconId: any(named: 'iconId'),
          pictureId: any(named: 'pictureId'),
        )).thenAnswer((_) async => 'list-1');
  }

  test('initial state is CreateListInitial', () {
    expect(buildCubit().state, isA<CreateListInitial>());
  });

  group('loadOptions', () {
    blocTest<CreateListCubit, CreateListState>(
      'emits [Loading, Ready] with first option pre-selected',
      build: buildCubit,
      setUp: stubOptionsHappyPath,
      act: (c) => c.loadOptions(),
      expect: () => [
        isA<CreateListLoading>(),
        isA<CreateListReady>()
            .having((s) => s.colors, 'colors', [tListColor])
            .having((s) => s.selectedColor, 'selectedColor', tListColor)
            .having((s) => s.selectedIcon, 'selectedIcon', tListIcon)
            .having((s) => s.selectedPicture, 'selectedPicture', tListPicture)
            .having((s) => s.submitting, 'submitting', false),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'emits OptionsFailure when any list comes back empty',
      build: buildCubit,
      setUp: () {
        when(() => getColors()).thenAnswer((_) async => [tListColor]);
        when(() => getIcons()).thenAnswer((_) async => []);
        when(() => getPictures()).thenAnswer((_) async => [tListPicture]);
      },
      act: (c) => c.loadOptions(),
      expect: () => [
        isA<CreateListLoading>(),
        isA<CreateListOptionsFailure>(),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'emits OptionsFailure on AppException',
      build: buildCubit,
      setUp: () {
        when(() => getColors()).thenThrow(const NetworkException());
        when(() => getIcons()).thenAnswer((_) async => [tListIcon]);
        when(() => getPictures()).thenAnswer((_) async => [tListPicture]);
      },
      act: (c) => c.loadOptions(),
      expect: () => [
        isA<CreateListLoading>(),
        isA<CreateListOptionsFailure>().having(
          (s) => s.message,
          'message',
          'No internet connection.',
        ),
      ],
    );
  });

  group('selectors', () {
    final colorB = const ListColor(hexCode: '#00FF00', name: 'Green', order: 1);

    blocTest<CreateListCubit, CreateListState>(
      'selectColor updates selected color and clears any previous error',
      build: buildCubit,
      seed: () => CreateListReady(
        colors: [tListColor, colorB],
        icons: [tListIcon],
        pictures: [tListPicture],
        selectedColor: tListColor,
        selectedIcon: tListIcon,
        selectedPicture: tListPicture,
        errorMessage: 'old error',
      ),
      act: (c) => c.selectColor(colorB),
      expect: () => [
        isA<CreateListReady>()
            .having((s) => s.selectedColor, 'selectedColor', colorB)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'selectColor is a no-op outside Ready state',
      build: buildCubit,
      seed: () => const CreateListInitial(),
      act: (c) => c.selectColor(tListColor),
      expect: () => const <CreateListState>[],
    );
  });

  group('submit', () {
    final ready = CreateListReady(
      colors: [tListColor],
      icons: [tListIcon],
      pictures: [tListPicture],
      selectedColor: tListColor,
      selectedIcon: tListIcon,
      selectedPicture: tListPicture,
    );

    blocTest<CreateListCubit, CreateListState>(
      'forwards selections to createList and emits Success',
      build: buildCubit,
      seed: () => ready,
      setUp: stubCreateOk,
      act: (c) => c.submit(name: 'My List', location: 'Garage'),
      expect: () => [
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', true),
        isA<CreateListSuccess>(),
      ],
      verify: (_) => verify(() => createList(
            name: 'My List',
            location: 'Garage',
            colorId: tListColor.hexCode,
            iconId: tListIcon.slug,
            pictureId: tListPicture.slug,
          )).called(1),
    );

    blocTest<CreateListCubit, CreateListState>(
      'normalises empty/whitespace location to null',
      build: buildCubit,
      seed: () => ready,
      setUp: stubCreateOk,
      act: (c) => c.submit(name: 'X', location: '   '),
      verify: (_) => verify(() => createList(
            name: 'X',
            location: null,
            colorId: any(named: 'colorId'),
            iconId: any(named: 'iconId'),
            pictureId: any(named: 'pictureId'),
          )).called(1),
    );

    blocTest<CreateListCubit, CreateListState>(
      'emits QuotaExceeded on PlanLimitException',
      build: buildCubit,
      seed: () => ready,
      setUp: () => when(() => createList(
            name: any(named: 'name'),
            location: any(named: 'location'),
            colorId: any(named: 'colorId'),
            iconId: any(named: 'iconId'),
            pictureId: any(named: 'pictureId'),
          )).thenThrow(const PlanLimitException()),
      act: (c) => c.submit(name: 'X'),
      expect: () => [
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', true),
        isA<CreateListQuotaExceeded>(),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'emits QuotaExceeded on TierRequiredException',
      build: buildCubit,
      seed: () => ready,
      setUp: () => when(() => createList(
            name: any(named: 'name'),
            location: any(named: 'location'),
            colorId: any(named: 'colorId'),
            iconId: any(named: 'iconId'),
            pictureId: any(named: 'pictureId'),
          )).thenThrow(const TierRequiredException()),
      act: (c) => c.submit(name: 'X'),
      expect: () => [
        isA<CreateListReady>(),
        isA<CreateListQuotaExceeded>(),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'returns to Ready with errorMessage on generic AppException',
      build: buildCubit,
      seed: () => ready,
      setUp: () => when(() => createList(
            name: any(named: 'name'),
            location: any(named: 'location'),
            colorId: any(named: 'colorId'),
            iconId: any(named: 'iconId'),
            pictureId: any(named: 'pictureId'),
          )).thenThrow(const ServerException('boom')),
      act: (c) => c.submit(name: 'X'),
      expect: () => [
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', true),
        isA<CreateListReady>()
            .having((s) => s.submitting, 'submitting', false)
            .having((s) => s.errorMessage, 'errorMessage', 'boom'),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'is a no-op outside Ready state',
      build: buildCubit,
      seed: () => const CreateListInitial(),
      act: (c) => c.submit(name: 'X'),
      expect: () => const <CreateListState>[],
      verify: (_) => verifyNever(() => createList(
            name: any(named: 'name'),
            location: any(named: 'location'),
            colorId: any(named: 'colorId'),
            iconId: any(named: 'iconId'),
            pictureId: any(named: 'pictureId'),
          )),
    );
  });
}
