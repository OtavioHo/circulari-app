import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/item_list.dart';
import '../../domain/usecases/create_list_usecase.dart';
import '../../domain/usecases/delete_list_usecase.dart';
import '../../domain/usecases/get_lists_usecase.dart';
import '../../domain/usecases/rename_list_usecase.dart';
import 'lists_event.dart';
import 'lists_state.dart';

class ListsBloc extends Bloc<ListsEvent, ListsState> {
  final GetListsUsecase _getLists;
  final CreateListUsecase _createList;
  final RenameListUsecase _renameList;
  final DeleteListUsecase _deleteList;

  ListsBloc({
    required GetListsUsecase getLists,
    required CreateListUsecase createList,
    required RenameListUsecase renameList,
    required DeleteListUsecase deleteList,
  })  : _getLists = getLists,
        _createList = createList,
        _renameList = renameList,
        _deleteList = deleteList,
        super(const ListsInitial()) {
    on<ListsLoadRequested>(_onLoad);
    on<ListsCreateRequested>(_onCreate);
    on<ListsRenameRequested>(_onRename);
    on<ListsDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ListsLoadRequested event,
    Emitter<ListsState> emit,
  ) async {
    emit(const ListsLoading());
    try {
      final lists = await _getLists();
      emit(ListsSuccess(lists));
    } on AppException catch (e) {
      emit(ListsFailure(e.message));
    }
  }

  Future<void> _onCreate(
    ListsCreateRequested event,
    Emitter<ListsState> emit,
  ) async {
    final previous = _currentLists();
    try {
      final created = await _createList(event.name);
      emit(ListsSuccess([...previous, created]));
    } on AppException catch (e) {
      emit(ListsActionFailure(previous, e.message));
    }
  }

  Future<void> _onRename(
    ListsRenameRequested event,
    Emitter<ListsState> emit,
  ) async {
    final previous = _currentLists();
    try {
      final updated = await _renameList(event.id, event.name);
      emit(ListsSuccess(
        previous.map((l) => l.id == event.id ? updated : l).toList(),
      ));
    } on AppException catch (e) {
      emit(ListsActionFailure(previous, e.message));
    }
  }

  Future<void> _onDelete(
    ListsDeleteRequested event,
    Emitter<ListsState> emit,
  ) async {
    final previous = _currentLists();
    try {
      await _deleteList(event.id);
      emit(ListsSuccess(previous.where((l) => l.id != event.id).toList()));
    } on AppException catch (e) {
      emit(ListsActionFailure(previous, e.message));
    }
  }

  List<ItemList> _currentLists() =>
      switch (state) {
        ListsSuccess(:final lists) => lists,
        ListsActionFailure(:final lists) => lists,
        _ => const [],
      };
}
