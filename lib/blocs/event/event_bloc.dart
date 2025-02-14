import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'dart:async';

class EventBloc extends HydratedBloc<EventEvent, EventState> {
  Timer? _midnightTimer;

  EventBloc() : super(const EventState()) {
    on<LoadEvents>(_onLoadEvents);
    on<AddEvent>(_onAddEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<PinEvent>(_onPinEvent);
    on<UnpinEvent>(_onUnpinEvent);
    on<EventReordered>(_onEventReordered);
    on<RefreshEvents>(_onRefreshEvents);
    _scheduleMidnightUpdate();
  }

  void _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(state.copyWith(status: EventStatus.loading));
    try {
      // 这里可以添加从本地存储或网络加载数据的逻辑
      emit(state.copyWith(status: EventStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onAddEvent(AddEvent event, Emitter<EventState> emit) {
    emit(state.copyWith(status: EventStatus.loading));
    try {
      final updatedEvents = List<Event>.from(state.events)..add(event.event);
      emit(state.copyWith(
        events: updatedEvents,
        status: EventStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) {
    final updatedEvents = state.events.map((e) {
      return e.id == event.event.id ? event.event : e;
    }).toList();
    
    // 如果更新的是置顶事件，也要更新pinnedEvent
    final updatedPinnedEvent = state.pinnedEvent?.id == event.event.id 
        ? event.event 
        : state.pinnedEvent;
        
    emit(state.copyWith(
      events: updatedEvents,
      pinnedEvent: updatedPinnedEvent,
    ));
  }

  void _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) {
    try {
      final updatedEvents = state.events.where((e) => e.id != event.eventId).toList();
      // 如果删除的是置顶事件，需要清除pinnedEvent
      final updatedPinnedEvent = state.pinnedEvent?.id == event.eventId 
          ? null 
          : state.pinnedEvent;
      
      emit(state.copyWith(
        events: updatedEvents,
        pinnedEvent: updatedPinnedEvent,
        status: EventStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onPinEvent(PinEvent event, Emitter<EventState> emit) {
    final eventToPin = state.events.firstWhere((e) => e.id == event.eventId);
    emit(state.copyWith(pinnedEvent: eventToPin));
  }

  void _onUnpinEvent(UnpinEvent event, Emitter<EventState> emit) {
    emit(state.copyWith(pinnedEvent: null));
  }

  void _onEventReordered(EventReordered event, Emitter<EventState> emit) {
    try {
      final updatedEvents = List<Event>.from(state.events);
      final newIndex = event.newIndex > event.oldIndex 
          ? event.newIndex - 1 
          : event.newIndex;
      final item = updatedEvents.removeAt(event.oldIndex);
      updatedEvents.insert(newIndex, item);
      
      emit(state.copyWith(
        events: updatedEvents,
        status: EventStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onRefreshEvents(RefreshEvents event, Emitter<EventState> emit) {
    // 触发状态更新，由于使用了 getter，会重新计算所有日期
    emit(state.copyWith(status: EventStatus.success));
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
  Map<String, dynamic>? toJson(EventState state) {
    return {
      'events': state.events.map((e) => {
        'id': e.id,
        'title': e.title,
        'targetDate': e.targetDate.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
        'displayUnit': e.displayUnit.index,
        'isPinned': e.isPinned,
        'backgroundType': e.backgroundType.index,
        'backgroundColorValue': e.backgroundColorValue,
        'gradientColorValues': e.gradientColorValues,
        'localImagePath': e.localImagePath,
        'animationType': e.animationType,
      }).toList(),
      'status': state.status.index,
    };
  }

  @override
  EventState? fromJson(Map<String, dynamic> json) {
    try {
      final events = (json['events'] as List).map((e) => Event(
        id: e['id'],
        title: e['title'],
        targetDate: DateTime.parse(e['targetDate']),
        createdAt: DateTime.parse(e['createdAt']),
        displayUnit: TimeUnit.values[e['displayUnit']],
        isPinned: e['isPinned'],
        backgroundType: BackgroundType.values[e['backgroundType']],
        backgroundColorValue: e['backgroundColorValue'],
        gradientColorValues: e['gradientColorValues']?.cast<int>(),
        localImagePath: e['localImagePath'],
        animationType: e['animationType'],
      )).toList();

      return EventState(
        events: events,
        status: EventStatus.values[json['status']],
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _midnightTimer?.cancel();
    return super.close();
  }
}
