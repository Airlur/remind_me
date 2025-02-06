import 'package:equatable/equatable.dart';
import 'package:remind_me/models/event.dart';

enum EventStatus { initial, loading, success, failure }

class EventState extends Equatable {
  final List<Event> events;
  final Event? pinnedEvent;
  final EventStatus status;
  final String? error;

  const EventState({
    this.events = const [],
    this.pinnedEvent,
    this.status = EventStatus.initial,
    this.error,
  });

  EventState copyWith({
    List<Event>? events,
    Event? pinnedEvent,
    EventStatus? status,
    String? error,
  }) {
    return EventState(
      events: events ?? this.events,
      pinnedEvent: pinnedEvent ?? this.pinnedEvent,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [events, pinnedEvent, status, error];
}
