import 'package:equatable/equatable.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_state.dart';

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

  const EventReordered(this.oldIndex, this.newIndex);

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

