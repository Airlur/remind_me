import 'package:hive_flutter/hive_flutter.dart';
import 'package:remind_me/models/event.dart';

class StorageService {
  static const String eventBoxName = 'events';
  late Box<Event> _eventBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // 注册适配器
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(TimeUnitAdapter());
    Hive.registerAdapter(BackgroundTypeAdapter());
    
    // 打开盒子
    _eventBox = await Hive.openBox<Event>(eventBoxName);
  }

  // 获取存储路径
  String? get storagePath => _eventBox.path;

  // 获取所有事件
  Future<List<Event>> getAllEvents() async {
    print('Storage getAllEvents: ${_eventBox.values.length}'); // 添加日志
    return _eventBox.values.toList();
  }

  // 保存事件
  Future<void> saveEvent(Event event) async {
    print('Storage saveEvent: ${event.id}'); // 添加日志
    await _eventBox.put(event.id, event);
  }

  // 批量保存事件
  Future<void> saveEvents(List<Event> events) async {
    final Map<String, Event> eventMap = {
      for (var event in events) event.id: event
    };
    await _eventBox.putAll(eventMap);
  }

  // 删除事件
  Future<void> deleteEvent(String eventId) async {
    await _eventBox.delete(eventId);
  }

  // 清空所有事件
  Future<void> clearEvents() async {
    await _eventBox.clear();
  }
}
