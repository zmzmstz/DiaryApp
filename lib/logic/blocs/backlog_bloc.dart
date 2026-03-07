import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/backlog_repository.dart';
import '../../models/backlog_item.dart';
import 'backlog_event_state.dart';

export 'backlog_event_state.dart';

class BacklogBloc extends Bloc<BacklogEvent, BacklogState> {
  final BacklogRepository _repository;

  BacklogBloc(this._repository) : super(BacklogLoading()) {
    on<LoadBacklogItems>(_onLoadBacklogItems);
    on<AddBacklogItem>(_onAddBacklogItem);
    on<UpdateBacklogItem>(_onUpdateBacklogItem);
    on<DeleteBacklogItem>(_onDeleteBacklogItem);
  }

  Future<void> _onLoadBacklogItems(LoadBacklogItems event, Emitter<BacklogState> emit) async {
    emit(BacklogLoading());
    try {
      final items = await _repository.getBacklogItems();
      emit(BacklogLoaded(items));
    } catch (e) {
      emit(BacklogError(e.toString()));
    }
  }

  bool isDuplicate(BacklogItem newItem) {
    final currentState = state;
    if (currentState is BacklogLoaded) {
      return currentState.items.any((existing) =>
          existing.title.toLowerCase().trim() ==
              newItem.title.toLowerCase().trim() &&
          existing.type == newItem.type);
    }
    return false;
  }

  Future<void> _onAddBacklogItem(AddBacklogItem event, Emitter<BacklogState> emit) async {
    final currentState = state;
    if (currentState is BacklogLoaded) {
      if (isDuplicate(event.item)) return;

      final currentList = currentState.items;
      final newList = List<BacklogItem>.from(currentList)..add(event.item);
      emit(BacklogLoaded(newList));

      try {
        await _repository.addBacklogItem(event.item);
      } catch (e) {
        emit(BacklogError("Failed to add item: $e"));
        emit(BacklogLoaded(currentList));
      }
    }
  }

  Future<void> _onUpdateBacklogItem(UpdateBacklogItem event, Emitter<BacklogState> emit) async {
    final currentState = state;
    if (currentState is BacklogLoaded) {
      final currentList = currentState.items;
      final updatedList = currentList.map((item) {
        return item.id == event.item.id ? event.item : item;
      }).toList();
      emit(BacklogLoaded(updatedList));

      try {
        await _repository.updateBacklogItem(event.item);
      } catch (e) {
        emit(BacklogError("Failed to update item: $e"));
        emit(BacklogLoaded(currentList));
      }
    }
  }

  Future<void> _onDeleteBacklogItem(DeleteBacklogItem event, Emitter<BacklogState> emit) async {
    final currentState = state;
    if (currentState is BacklogLoaded) {
      final currentList = currentState.items;
      final newList = currentList.where((item) => item.id != event.id).toList();
      emit(BacklogLoaded(newList));

      try {
        await _repository.deleteBacklogItem(event.id);
      } catch (e) {
        emit(BacklogError("Failed to delete item: $e"));
        emit(BacklogLoaded(currentList));
      }
    }
  }
}
