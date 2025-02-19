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
    final events = _eventBox.values.toList();
    print('Storage getAllEvents: ${events.length}');
    
    // // 按 order 排序后打印
    // final sortedEvents = List<Event>.from(events)
    //   ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    
    // print('【Storage getAllEvents】Sorted by order: ${sortedEvents.map((e) => 
    //   '${e.title}(order: ${e.order})'
    // ).toList()}');
    
    return events;
  }

  // 保存事件
  Future<void> saveEvent(Event event) async {
    // print('Storage saveEvent ID: ${event.id}');
    // print('【Storage saveEvent】Title: ${event.title} Order: ${event.order}');
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
