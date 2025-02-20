import 'package:equatable/equatable.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/models/category.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {}

class AddEvent extends EventEvent {
  final Event event;
  
  const AddEvent(this.event);
  
  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends EventEvent {
  final Event event;
  
  const UpdateEvent(this.event);
  
  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends EventEvent {
  final String eventId;
  
  const DeleteEvent(this.eventId);
  
  @override
  List<Object?> get props => [eventId];
}

class PinEvent extends EventEvent {
  final String eventId;
  
  const PinEvent(this.eventId);
  
  @override
  List<Object?> get props => [eventId];
}

class UnpinEvent extends EventEvent {
  final String eventId;
  
  const UnpinEvent(this.eventId);
  
  @override
  List<Object?> get props => [eventId];
}

class EventReordered extends EventEvent {
  final int oldIndex;
  final int newIndex;

  const EventReordered({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class RefreshEvents extends EventEvent {
  const RefreshEvents();
}

class UpdatePinnedDisplayMode extends EventEvent {
  final PinnedDisplayMode mode;
  const UpdatePinnedDisplayMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class UpdateSortConfig extends EventEvent {
  final SortType? sortType;
  final SortOrder? sortOrder;
  final String? selectedCategory;

  const UpdateSortConfig({
    this.sortType,
    this.sortOrder,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [sortType, sortOrder, selectedCategory];
}

class InitiateEventDelete extends EventEvent {
  final Event event;
  const InitiateEventDelete(this.event);
}

class CancelEventDelete extends EventEvent {
  const CancelEventDelete();
}

// 加载分类
class LoadCategories extends EventEvent {
  const LoadCategories();
}

// 添加分类
class AddCategory extends EventEvent {
  final Category category;
  const AddCategory(this.category);
}

// 更新分类
class UpdateCategory extends EventEvent {
  final Category category;
  final String oldName;

  const UpdateCategory({
    required this.category,
    required this.oldName,
  });

  @override
  List<Object?> get props => [category, oldName];
}

// 删除分类
class DeleteCategory extends EventEvent {
  final String name;
  const DeleteCategory(this.name);
}

