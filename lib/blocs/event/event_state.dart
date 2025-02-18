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
  remainingDays, // 剩余天数
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
      return events;  // 返回所有事件
    }
    return events.where((e) => e.category == selectedCategory).toList();
  }

  List<Event> get sortedEvents {
    final filtered = filteredEvents;  // 先筛选
    
    switch (sortType) {
      case SortType.createTime:
        filtered.sort((a, b) => sortOrder == SortOrder.ascending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
        break;
      
      case SortType.remainingDays:
        filtered.sort((a, b) {
          final comparison = a.absDays.compareTo(b.absDays);
          return sortOrder == SortOrder.ascending ? comparison : -comparison;
        });
        break;
      
      case SortType.custom:
        filtered.sort((a, b) {
          if (a.order == null && b.order == null) return 0;
          if (a.order == null) return 1;
          if (b.order == null) return -1;
          return a.order!.compareTo(b.order!);
        });
        break;
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
