import 'package:equatable/equatable.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/blocs/event/event_event.dart';
// import 'package:remind_me/utils/common/logger_utils.dart';

enum EventStatus { initial, loading, success, failure }

enum PinnedDisplayMode {
  single,    // 单个置顶
  carousel,  // 轮播展示
  multiple   // 多个堆叠
}

enum SortType {
  createTime,    // 创建时间
  dayCount, // 天数（包含倒数日和正数日）
  custom,        // 自定义（拖拽）排序
}

enum SortOrder {
  ascending,
  descending,
}

class EventState extends Equatable {
  final List<Event> events;
  final List<Category> categories;
  final Event? pinnedEvent;
  final EventStatus status;
  final String? error;
  final PinnedDisplayMode pinnedDisplayMode;
  final SortType sortType;
  final SortOrder sortOrder;
  final String? selectedCategory;
  final Event? pendingDeleteEvent;
  final DateTime? deleteStartTime;
  final EventEvent? lastEvent;

  const EventState({
    this.events = const [],
    this.categories = const [],
    this.pinnedEvent,
    this.status = EventStatus.initial,
    this.error,
    this.pinnedDisplayMode = PinnedDisplayMode.single,
    this.sortType = SortType.createTime,
    this.sortOrder = SortOrder.descending,
    this.selectedCategory,
    this.pendingDeleteEvent,
    this.deleteStartTime,
    this.lastEvent,
  });

  List<Event> get pinnedEvents {
    final filtered = events.where((e) => 
      e.isPinned && 
      (selectedCategory == null || e.category == selectedCategory)  // 添加分类过滤
    ).toList()
      ..sort((a, b) => (b.pinnedAt ?? b.createdAt)
          .compareTo(a.pinnedAt ?? a.createdAt));
    
    return filtered;
  }

  List<Event> get filteredEvents {
    if (selectedCategory == null) {
      return List<Event>.from(events);  // 返回可变副本而不是直接返回
    }
    return events.where((e) => e.category == selectedCategory).toList();  // where().toList() 已经创建了新列表
  }

  List<Event> get sortedEvents {
    // 先按分类过滤
    final filtered = selectedCategory != null 
        ? events.where((e) => e.category == selectedCategory).toList()
        : events.toList();
        
    // LoggerUtils.i('''【EventState】获取排序后事件:
    //   分类: ${selectedCategory ?? "全部"}
    //   排序类型: $sortType
    //   事件数量: ${filtered.length}
    // ''', 'EventState');

    // 然后排序
    switch (sortType) {
      case SortType.createTime:
        filtered.sort((a, b) => sortOrder == SortOrder.ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
      
      case SortType.dayCount:
        filtered.sort((a, b) {
          final comparison = a.absDays.compareTo(b.absDays);
          return sortOrder == SortOrder.ascending ? comparison : -comparison;
        });
      
      case SortType.custom:
        return filtered..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    }
    
    return filtered;
  }

  EventState copyWith({
    List<Event>? events,
    List<Category>? categories,
    Event? pinnedEvent,
    EventStatus? status,
    String? error,
    PinnedDisplayMode? pinnedDisplayMode,
    SortType? sortType,
    SortOrder? sortOrder,
    String? selectedCategory,
    Event? pendingDeleteEvent,
    DateTime? deleteStartTime,
    EventEvent? lastEvent,
  }) {
    return EventState(
      events: events ?? this.events,
      categories: categories ?? this.categories,
      pinnedEvent: pinnedEvent ?? this.pinnedEvent,
      status: status ?? this.status,
      error: error ?? this.error,
      pinnedDisplayMode: pinnedDisplayMode ?? this.pinnedDisplayMode,
      sortType: sortType ?? this.sortType,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedCategory: selectedCategory,
      pendingDeleteEvent: pendingDeleteEvent,
      deleteStartTime: deleteStartTime,
      lastEvent: lastEvent,
    );
  }

  @override
  List<Object?> get props => [
    events,
    categories,
    pinnedEvent,
    status,
    error,
    pinnedDisplayMode,
    sortType,
    sortOrder,
    selectedCategory,
    pendingDeleteEvent,
    deleteStartTime,
    lastEvent,
  ];
}
