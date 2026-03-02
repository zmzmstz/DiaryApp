import 'package:equatable/equatable.dart';
import '../../models/backlog_item.dart';

abstract class BacklogEvent extends Equatable {
  const BacklogEvent();

  @override
  List<Object> get props => [];
}

class LoadBacklogItems extends BacklogEvent {}

class AddBacklogItem extends BacklogEvent {
  final BacklogItem item;

  const AddBacklogItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateBacklogItem extends BacklogEvent {
  final BacklogItem item;

  const UpdateBacklogItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteBacklogItem extends BacklogEvent {
  final String id;

  const DeleteBacklogItem(this.id);

  @override
  List<Object> get props => [id];
}

abstract class BacklogState extends Equatable {
  const BacklogState();
  
  @override
  List<Object> get props => [];
}

class BacklogLoading extends BacklogState {}

class BacklogLoaded extends BacklogState {
  final List<BacklogItem> items;
  final DateTime timestamp;

  BacklogLoaded(this.items) : timestamp = DateTime.now();

  @override
  List<Object> get props => [items, timestamp];
}

class BacklogError extends BacklogState {
  final String message;

  const BacklogError(this.message);

  @override
  List<Object> get props => [message];
}
