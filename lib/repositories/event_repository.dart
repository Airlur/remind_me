import 'package:remind_me/models/event.dart';
import 'package:remind_me/services/storage_service.dart';
// import 'package:remind_me/utils/common/logger_utils.dart';

class EventRepository {
  final StorageService _storage;
  
  const EventRepository({
    required StorageService storage,
  }) : _storage = storage;

  // 基础 CRUD
  Future<List<Event>> getAllEvents() async {
    final events = await _storage.getAllEvents();
    // print('Repository getAllEvents: ${events.length}');
    // LoggerUtils.i('Repository getAllEvents: ${events.length}', 'EventRepository');
    
    // 打印所有值
    // LoggerUtils.i('Repository Events: ${events.toList()}', 'EventRepository');
    return events;
  }
  
  Future<void> saveEvent(Event event) async {
    // LoggerUtils.i('Repository saveEvent: ${event.title}', 'EventRepository');
    await _storage.saveEvent(event);
  }
  
  Future<void> updateEvent(Event event) => _storage.saveEvent(event);
  
  Future<void> deleteEvent(String id) => _storage.deleteEvent(id);
  
  // 置顶相关
  Future<void> pinEvent(String id) async {
    final events = await getAllEvents();
    final event = events.firstWhere((e) => e.id == id);
    final updatedEvent = Event(
      id: event.id,
      title: event.title,
      targetDate: event.targetDate,
      createdAt: event.createdAt,
      isPinned: true,
      pinnedAt: DateTime.now(),
      backgroundType: event.backgroundType,
      backgroundColorValue: event.backgroundColorValue,
      gradientColorValues: event.gradientColorValues,
      localImagePath: event.localImagePath,
      animationType: event.animationType,
      isLunar: event.isLunar,
    );
    await saveEvent(updatedEvent);
  }
  
  Future<void> unpinEvent(String id) async {
    final events = await getAllEvents();
    final event = events.firstWhere((e) => e.id == id);
    final updatedEvent = Event(
      id: event.id,
      title: event.title,
      targetDate: event.targetDate,
      createdAt: event.createdAt,
      isPinned: false,
      pinnedAt: null,
      backgroundType: event.backgroundType,
      backgroundColorValue: event.backgroundColorValue,
      gradientColorValues: event.gradientColorValues,
      localImagePath: event.localImagePath,
      animationType: event.animationType,
      isLunar: event.isLunar,
    );
    await saveEvent(updatedEvent);
  }
  
  // 排序相关
  Future<void> reorderEvents(int oldIndex, int newIndex) async {
    final events = await getAllEvents();
    final event = events.removeAt(oldIndex);
    events.insert(newIndex, event);
    await _storage.saveEvents(events);
  }

  // 添加批量更新方法
  Future<void> updateEvents(List<Event> events) async {
    // 一次性更新多个事件
    await Future.wait(
      events.map((e) => _storage.saveEvent(e))
    );
  }
} 