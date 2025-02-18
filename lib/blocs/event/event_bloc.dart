import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'dart:async';
import 'package:remind_me/repositories/event_repository.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repository;
  Timer? _midnightTimer;

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
    _scheduleMidnightUpdate();
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    try {
      emit(state.copyWith(status: EventStatus.loading));
      final events = await _repository.getAllEvents();
      print('Bloc LoadEvents: ${events.length}');
      emit(state.copyWith(
        status: EventStatus.success,
        events: events,
      ));
    } catch (e) {
      print('Bloc LoadEvents error: $e');
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

  Future<void> _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
    try {
      await _repository.updateEvent(event.event);
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
}
