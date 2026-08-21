import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/domain/usecases/delete_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_lists_usecase.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_event.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_state.dart';

class ListsBloc extends Bloc<ListsEvent, ListsState> {
  final GetListsUsecase _getLists;
  final DeleteListUsecase _deleteList;

  ListsBloc({
    required GetListsUsecase getLists,
    required DeleteListUsecase deleteList,
  })  : _getLists = getLists,
        _deleteList = deleteList,
        super(const ListsInitial()) {
    on<ListsLoadRequested>(_onLoad);
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

  List<ItemList> _currentLists() => switch (state) {
        ListsSuccess(:final lists) => lists,
        ListsActionFailure(:final lists) => lists,
        _ => const [],
      };
}
