import 'package:equatable/equatable.dart';
import 'package:remind_me/models/event.dart';

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
  final Event? pinnedEvent;
  final EventStatus status;
  final String? error;
  final PinnedDisplayMode pinnedDisplayMode;
  final SortType sortType;
  final SortOrder sortOrder;
  final String? selectedCategory;  // 分类筛选条件

  const EventState({
    this.events = const [],
    this.pinnedEvent,
    this.status = EventStatus.initial,
    this.error,
    this.pinnedDisplayMode = PinnedDisplayMode.single,
    this.sortType = SortType.createTime,
    this.sortOrder = SortOrder.descending,
    this.selectedCategory,
  });

  List<Event> get pinnedEvents => events
    .where((e) => e.isPinned)
    .toList()
    ..sort((a, b) => (b.pinnedAt ?? b.createdAt)
        .compareTo(a.pinnedAt ?? a.createdAt));

  List<Event> get filteredEvents {
    if (selectedCategory == null) {
      return List<Event>.from(events);  // 返回可变副本而不是直接返回
    }
    return events.where((e) => e.category == selectedCategory).toList();  // where().toList() 已经创建了新列表
  }

  List<Event> get sortedEvents {
    final filtered = filteredEvents;  // 已经是可变副本
    
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
        // 自定义排序模式下，保持当前列表顺序，不做额外排序
        return filtered;
    }
    
    return filtered;
  }

  EventState copyWith({
    List<Event>? events,
    Event? pinnedEvent,
    EventStatus? status,
    String? error,
    PinnedDisplayMode? pinnedDisplayMode,
    SortType? sortType,
    SortOrder? sortOrder,
    String? selectedCategory,
  }) {
    return EventState(
      events: events ?? this.events,
      pinnedEvent: pinnedEvent ?? this.pinnedEvent,
      status: status ?? this.status,
      error: error ?? this.error,
      pinnedDisplayMode: pinnedDisplayMode ?? this.pinnedDisplayMode,
      sortType: sortType ?? this.sortType,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
    events,
    pinnedEvent,
    status,
    error,
    pinnedDisplayMode,
    sortType,
    sortOrder,
    selectedCategory,
  ];
}
