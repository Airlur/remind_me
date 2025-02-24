import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'dart:async';
import 'package:remind_me/repositories/event_repository.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class EventBloc extends HydratedBloc<EventEvent, EventState> {
  final EventRepository _repository;
  Timer? _midnightTimer;
  Timer? _deleteTimer;

  EventBloc({
    required EventRepository repository,
  }) : _repository = repository,
       super(const EventState()) {
    on<LoadEvents>(_onLoadEvents);
    on<AddEvent>(_onAddEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<PinEvent>(_onPinEvent);
    on<UnpinEvent>(_onUnpinEvent);
    on<EventReordered>(_onEventReordered);
    on<RefreshEvents>(_onRefreshEvents);
    on<UpdatePinnedDisplayMode>(_onUpdatePinnedDisplayMode);
    on<UpdateSortConfig>(_onUpdateSortConfig);
    on<InitiateEventDelete>(_onInitiateEventDelete);
    on<CancelEventDelete>(_onCancelEventDelete);
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    _scheduleMidnightUpdate();
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    try {
      emit(state.copyWith(status: EventStatus.loading));
      final events = await _repository.getAllEvents();
      // LoggerUtils.i('Bloc LoadEvents: ${events.length}', 'EventBloc');

      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
      ));
    } catch (e) {
      LoggerUtils.e('Bloc LoadEvents error: $e', 'EventBloc');
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAddEvent(AddEvent event, Emitter<EventState> emit) async {
    try {
      await _repository.saveEvent(event.event);
      final events = await _repository.getAllEvents();
      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
    LoggerUtils.i('''【EventBloc】更新事件前状态:
      事件ID: ${event.event.id}
      当前分类: ${state.selectedCategory ?? "全部"}
      排序类型: ${state.sortType}
      事件数量: ${state.events.length}
    ''', 'EventBloc');
    
    try {
      // 1. 更新数据库
      await _repository.updateEvent(event.event);
      
      // 2. 只更新当前事件，保持其他状态不变
      final events = List<Event>.from(state.events);
      final index = events.indexWhere((e) => e.id == event.event.id);
      if (index != -1) {
        events[index] = event.event;
      }
      
      // 3. 发出新状态前记录
      LoggerUtils.i('''【EventBloc】即将发出新状态:
        事件ID: ${event.event.id}
        当前分类: ${state.selectedCategory ?? "全部"}
        排序类型: ${state.sortType}
        事件数量: ${events.length}
      ''', 'EventBloc');
      
      // 4. 发出新状态
      final newState = state.copyWith(
        events: events,
        // 明确保持其他状态不变
        selectedCategory: state.selectedCategory,
        sortType: state.sortType,
        sortOrder: state.sortOrder,
      );
      
      // 5. 发出新状态后记录
      LoggerUtils.i('''【EventBloc】发出新状态后:
        事件ID: ${event.event.id}
        新状态分类: ${newState.selectedCategory ?? "全部"}
        新状态排序: ${newState.sortType}
        新状态事件数量: ${newState.events.length}
      ''', 'EventBloc');
      
      emit(newState);
    } catch (e) {
      LoggerUtils.e('【EventBloc】更新事件错误: $e', 'EventBloc');
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) async {
    try {
      await _repository.deleteEvent(event.eventId);
      final events = await _repository.getAllEvents();
      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPinEvent(PinEvent event, Emitter<EventState> emit) async {
    try {
      await _repository.pinEvent(event.eventId);
      final events = await _repository.getAllEvents();
      
      // 找到被置顶的事件
      final pinnedEvent = events.firstWhere((e) => e.id == event.eventId);
      
      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
        pinnedEvent: pinnedEvent, // 更新置顶事件
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUnpinEvent(UnpinEvent event, Emitter<EventState> emit) async {
    try {
      await _repository.unpinEvent(event.eventId);
      final events = await _repository.getAllEvents();
      
      // 如果当前置顶的是这个事件，则清除置顶
      final shouldClearPinned = state.pinnedEvent?.id == event.eventId;
      
      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
        pinnedEvent: shouldClearPinned ? null : state.pinnedEvent,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onEventReordered(EventReordered event, Emitter<EventState> emit) async {
    LoggerUtils.i('''【EventBloc】事件重新排序:
      当前分类: ${state.selectedCategory ?? "全部"}
      排序类型: ${state.sortType}
      移动位置: ${event.oldIndex} -> ${event.newIndex}
      当前顺序: ${state.sortedEvents.map((e) => "${e.title}(${e.order})").join(", ")}
    ''', 'EventBloc');
    
    final currentEvents = List<Event>.from(state.events); // 使用所有事件的副本
    final filteredEvents = state.sortedEvents.toList(); // 当前分类的事件
    final movedEvent = filteredEvents[event.oldIndex];
    
    // 在完整列表中找到并更新事件
    final indexInAll = currentEvents.indexWhere((e) => e.id == movedEvent.id);
    if (indexInAll != -1) {
      currentEvents[indexInAll] = movedEvent.copyWith(order: event.newIndex);
    }
    
    // 更新受影响的其他事件
    for (var i = 0; i < currentEvents.length; i++) {
      final e = currentEvents[i];
      if (e.category == state.selectedCategory && e.id != movedEvent.id) {
        if (e.order! >= event.newIndex && e.order! < event.oldIndex) {
          currentEvents[i] = e.copyWith(order: e.order! + 1);
        }
      }
    }
    
    LoggerUtils.i('''【EventBloc】更新后顺序:
      更新后: ${currentEvents.where((e) => e.category == state.selectedCategory).map((e) => "${e.title}(${e.order})").join(", ")}
    ''', 'EventBloc');

    emit(state.copyWith(
      events: currentEvents,
      sortType: SortType.custom,
      selectedCategory: state.selectedCategory,
    ));

    // 只更新发生变化的事件
    final updates = currentEvents.where((e) => 
      e.category == state.selectedCategory && 
      (e.id == movedEvent.id || (e.order! >= event.newIndex && e.order! < event.oldIndex))
    ).toList();
    
    await _repository.updateEvents(updates);
  }

  Future<void> _onRefreshEvents(RefreshEvents event, Emitter<EventState> emit) async {
    try {
      final events = await _repository.getAllEvents();
      // 保持当前的置顶状态
      final currentPinnedEvent = state.pinnedEvent;
      final pinnedStillExists = events.any((e) => e.id == currentPinnedEvent?.id && e.isPinned);
      
      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
        pinnedEvent: pinnedStillExists ? currentPinnedEvent : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onUpdatePinnedDisplayMode(
    UpdatePinnedDisplayMode event,
    Emitter<EventState> emit,
  ) {
    emit(state.copyWith(pinnedDisplayMode: event.mode));
  }

  void _onUpdateSortConfig(UpdateSortConfig event, Emitter<EventState> emit) {
    LoggerUtils.i('''【EventBloc】更新排序配置:
      当前排序类型: ${state.sortType} -> ${event.sortType ?? state.sortType}
      当前排序顺序: ${state.sortOrder} -> ${event.sortOrder ?? state.sortOrder}
      当前分类: ${state.selectedCategory ?? "全部"} -> ${event.selectedCategory ?? "全部"}
    ''', 'EventBloc');

    emit(state.copyWith(
      sortType: event.sortType ?? state.sortType,
      sortOrder: event.sortOrder ?? state.sortOrder,
      selectedCategory: event.selectedCategory ?? state.selectedCategory,
    ));
  }

  void _onInitiateEventDelete(InitiateEventDelete event, Emitter<EventState> emit) {
    _deleteTimer?.cancel();
    emit(state.copyWith(pendingDeleteEvent: event.event));
    
    _deleteTimer = Timer(const Duration(seconds: 5), () {
      add(DeleteEvent(event.event.id));
      add(const CancelEventDelete());
    });
  }

  void _onCancelEventDelete(CancelEventDelete event, Emitter<EventState> emit) {
    _deleteTimer?.cancel();
    emit(state.copyWith(pendingDeleteEvent: null));
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    _midnightTimer?.cancel();
    _midnightTimer = Timer(duration, () {
      add(const RefreshEvents());
      _scheduleMidnightUpdate(); // 重新调度下一天的更新
    });
  }

  @override
  Future<void> close() {
    _midnightTimer?.cancel();
    return super.close();
  }

  @override
  EventState? fromJson(Map<String, dynamic> json) {
    try {
      return EventState(
        status: EventStatus.initial,
        events: const [],
        pinnedDisplayMode: PinnedDisplayMode.values[json['pinnedDisplayMode'] ?? 0],
        sortType: SortType.values[json['sortType'] ?? 0],
        sortOrder: SortOrder.values[json['sortOrder'] ?? 0],
        selectedCategory: json['selectedCategory'],
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(EventState state) {
    return {
      'pinnedDisplayMode': state.pinnedDisplayMode.index,
      'sortType': state.sortType.index,
      'sortOrder': state.sortOrder.index,
      'selectedCategory': state.selectedCategory,
    };
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<EventState> emit) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<EventState> emit) async {
    try {
      await _repository.addCategory(event.category);
      final categories = await _repository.getCategories();
      emit(state.copyWith(
        categories: categories,
        error: null,
        status: EventStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        status: EventStatus.failure,
      ));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<EventState> emit) async {
    try {
      await _repository.updateCategory(event.category, oldName: event.oldName);
      final categories = await _repository.getCategories();
      emit(state.copyWith(
        categories: categories,
        error: null,
        status: EventStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        status: EventStatus.failure,
      ));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<EventState> emit) async {
    try {
      // 1. 更新所有使用该分类的事件
      final updatedEvents = <Event>[];
      for (final e in state.events) {
        if (e.category == event.name) {
          // 先创建新的事件对象，确保 category 为 null
          final updatedEvent = e.copyWith(category: null);
          // 再更新存储
          await _repository.updateEvent(updatedEvent);
          updatedEvents.add(updatedEvent);
        } else {
          updatedEvents.add(e);
        }
      }
      
      // 2. 删除分类
      await _repository.deleteCategory(event.name);
      
      // 3. 获取更新后的分类列表
      final categories = await _repository.getCategories();
      
      // 4. 发出新状态
      emit(state.copyWith(
        events: updatedEvents,
        categories: categories,
        selectedCategory: null,
        status: EventStatus.success,
        lastEvent: event,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        status: EventStatus.failure,
      ));
    }
  }
}
