import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/lists/data/models/list_color_model.dart';
import 'package:circulari/features/lists/data/models/list_icon_model.dart';
import 'package:circulari/features/lists/data/models/list_picture_model.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/domain/entities/list_color.dart';
import 'package:circulari/features/lists/domain/entities/list_icon.dart';
import 'package:circulari/features/lists/domain/entities/list_picture.dart';
import 'package:circulari/features/lists/domain/usecases/create_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/delete_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_colors_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_icons_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_pictures_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/update_list_usecase.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_cubit.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_state.dart';

import '../../../../helpers/fixtures.dart';

class MockGetColors extends Mock implements GetListColorsUsecase {}

class MockGetIcons extends Mock implements GetListIconsUsecase {}

class MockGetPictures extends Mock implements GetListPicturesUsecase {}

class MockCreateList extends Mock implements CreateListUsecase {}

class MockUpdateList extends Mock implements UpdateListUsecase {}

class MockDeleteList extends Mock implements DeleteListUsecase {}

void main() {
  late MockGetColors getColors;
  late MockGetIcons getIcons;
  late MockGetPictures getPictures;
  late MockCreateList createList;
  late MockUpdateList updateList;
  late MockDeleteList deleteList;

  setUp(() {
    getColors = MockGetColors();
    getIcons = MockGetIcons();
    getPictures = MockGetPictures();
    createList = MockCreateList();
    updateList = MockUpdateList();
    deleteList = MockDeleteList();
  });

  CreateListCubit buildCubit({ItemList? initial}) => CreateListCubit(
        getColors: getColors,
        getIcons: getIcons,
        getPictures: getPictures,
        createList: createList,
        updateList: updateList,
        deleteList: deleteList,
        initial: initial,
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
      'handles model-typed (covariant) lists from the data layer',
      build: buildCubit,
      setUp: () {
        // The real remote sources return List<ListColorModel> etc. — the
        // subtype-parameterised runtime type used to make firstWhere reject
        // the entity-typed orElse closure and strand the state in Loading.
        when(() => getColors()).thenAnswer(
          (_) async => <ListColorModel>[
            ListColorModel(
              hexCode: tListColor.hexCode,
              name: tListColor.name,
              order: tListColor.order,
            ),
          ],
        );
        when(() => getIcons()).thenAnswer(
          (_) async => <ListIconModel>[
            ListIconModel(
              slug: tListIcon.slug,
              name: tListIcon.name,
              order: tListIcon.order,
            ),
          ],
        );
        when(() => getPictures()).thenAnswer(
          (_) async => <ListPictureModel>[
            ListPictureModel(
              slug: tListPicture.slug,
              order: tListPicture.order,
            ),
          ],
        );
      },
      act: (c) => c.loadOptions(),
      expect: () => [
        isA<CreateListLoading>(),
        isA<CreateListReady>()
            .having((s) => s.selectedColor.hexCode, 'selectedColor.hexCode',
                tListColor.hexCode),
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
      'emits QuotaExceeded then restores the form on PlanLimitException',
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
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', false),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'emits QuotaExceeded then restores the form on TierRequiredException',
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
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', false),
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

  group('edit mode', () {
    const colorB = ListColor(hexCode: '#00FF00', name: 'Green', order: 1);
    const iconB = ListIcon(slug: 'car', name: 'Car', order: 1);
    const pictureB = ListPicture(slug: 'city', order: 1);

    final tEditing = ItemList(
      id: 'list-9',
      name: 'Old Name',
      location: 'Old Place',
      color: colorB,
      icon: iconB,
      picture: pictureB,
      itemCount: 3,
      totalValue: 120,
      createdAt: DateTime(2024),
    );

    final ready = CreateListReady(
      colors: [tListColor, colorB],
      icons: [tListIcon, iconB],
      pictures: [tListPicture, pictureB],
      selectedColor: colorB,
      selectedIcon: iconB,
      selectedPicture: pictureB,
    );

    void stubUpdateOk() {
      when(() => updateList(
            any(),
            name: any(named: 'name'),
            location: any(named: 'location'),
            colorId: any(named: 'colorId'),
            iconId: any(named: 'iconId'),
            pictureId: any(named: 'pictureId'),
          )).thenAnswer((_) async {});
    }

    blocTest<CreateListCubit, CreateListState>(
      'loadOptions pre-selects the edited list color/icon/picture',
      build: () => buildCubit(initial: tEditing),
      setUp: () {
        when(() => getColors())
            .thenAnswer((_) async => [tListColor, colorB]);
        when(() => getIcons()).thenAnswer((_) async => [tListIcon, iconB]);
        when(() => getPictures())
            .thenAnswer((_) async => [tListPicture, pictureB]);
      },
      act: (c) => c.loadOptions(),
      expect: () => [
        isA<CreateListLoading>(),
        isA<CreateListReady>()
            .having((s) => s.selectedColor, 'selectedColor', colorB)
            .having((s) => s.selectedIcon, 'selectedIcon', iconB)
            .having((s) => s.selectedPicture, 'selectedPicture', pictureB),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'submit PATCHes via updateList and emits Success with updated entity',
      build: () => buildCubit(initial: tEditing),
      seed: () => ready,
      setUp: stubUpdateOk,
      act: (c) => c.submit(name: 'New Name', location: 'New Place'),
      expect: () => [
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', true),
        isA<CreateListSuccess>()
            .having((s) => s.list.id, 'id', 'list-9')
            .having((s) => s.list.name, 'name', 'New Name')
            .having((s) => s.list.location, 'location', 'New Place')
            .having((s) => s.list.itemCount, 'itemCount', 3),
      ],
      verify: (_) {
        verify(() => updateList(
              'list-9',
              name: 'New Name',
              location: 'New Place',
              colorId: colorB.hexCode,
              iconId: iconB.slug,
              pictureId: pictureB.slug,
            )).called(1);
        verifyNever(() => createList(
              name: any(named: 'name'),
              location: any(named: 'location'),
              colorId: any(named: 'colorId'),
              iconId: any(named: 'iconId'),
              pictureId: any(named: 'pictureId'),
            ));
      },
    );

    blocTest<CreateListCubit, CreateListState>(
      'delete emits Deleted on success',
      build: () => buildCubit(initial: tEditing),
      seed: () => ready,
      setUp: () => when(() => deleteList(any())).thenAnswer((_) async {}),
      act: (c) => c.delete(),
      expect: () => [
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', true),
        isA<CreateListDeleted>(),
      ],
      verify: (_) => verify(() => deleteList('list-9')).called(1),
    );

    blocTest<CreateListCubit, CreateListState>(
      'delete returns to Ready with errorMessage on AppException',
      build: () => buildCubit(initial: tEditing),
      seed: () => ready,
      setUp: () => when(() => deleteList(any()))
          .thenThrow(const ServerException('boom')),
      act: (c) => c.delete(),
      expect: () => [
        isA<CreateListReady>().having((s) => s.submitting, 'submitting', true),
        isA<CreateListReady>()
            .having((s) => s.submitting, 'submitting', false)
            .having((s) => s.errorMessage, 'errorMessage', 'boom'),
      ],
    );

    blocTest<CreateListCubit, CreateListState>(
      'delete is a no-op in create mode',
      build: buildCubit,
      seed: () => ready,
      act: (c) => c.delete(),
      expect: () => const <CreateListState>[],
      verify: (_) => verifyNever(() => deleteList(any())),
    );
  });
}
