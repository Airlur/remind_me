import 'package:equatable/equatable.dart';
import 'package:remind_me/models/event.dart';

enum EventStatus { initial, loading, success, failure }

enum PinnedDisplayMode {
  single,    // 单个置顶
  carousel,  // 轮播展示
  multiple   // 多个堆叠
}

class EventState extends Equatable {
  final List<Event> events;
  final Event? pinnedEvent;
  final EventStatus status;
  final String? error;
  final PinnedDisplayMode pinnedDisplayMode;

  const EventState({
    this.events = const [],
    this.pinnedEvent,
    this.status = EventStatus.initial,
    this.error,
    this.pinnedDisplayMode = PinnedDisplayMode.single,
  });

  List<Event> get pinnedEvents => events
    .where((e) => e.isPinned)
    .toList()
    ..sort((a, b) => (b.pinnedAt ?? b.createdAt)
        .compareTo(a.pinnedAt ?? a.createdAt));

  EventState copyWith({
    List<Event>? events,
    Event? pinnedEvent,
    EventStatus? status,
    String? error,
    PinnedDisplayMode? pinnedDisplayMode,
  }) {
    return EventState(
      events: events ?? this.events,
      pinnedEvent: pinnedEvent ?? this.pinnedEvent,
      status: status ?? this.status,
      error: error ?? this.error,
      pinnedDisplayMode: pinnedDisplayMode ?? this.pinnedDisplayMode,
    );
  }

  @override
  List<Object?> get props => [events, pinnedEvent, status, error, pinnedDisplayMode];
}
