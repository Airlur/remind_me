import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/views/pages/date/calendar_page.dart';
import 'package:remind_me/views/pages/date/components/event_card.dart';
import 'package:remind_me/utils/common/route_utils.dart';
import 'package:remind_me/views/pages/date/add_event_page.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'dart:async';
import 'package:remind_me/views/pages/date/components/custom_page_view.dart';
import 'package:remind_me/views/pages/date/components/sort_dialog.dart';
import 'package:remind_me/theme/app_colors.dart';
import 'package:remind_me/views/pages/date/components/empty_state.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';

class DatePage extends StatelessWidget {
  const DatePage({super.key});

  static bool countdownFilter(Event event) => event.isCountdown;
  static bool countupFilter(Event event) => !event.isCountdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: theme.brightness == Brightness.light 
          ? Colors.white
          : theme.colorScheme.surfaceContainer,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(
                        child: Text(
                          context.l10n.all,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Tab(
                        child: Text(
                          context.l10n.countdownDay,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Tab(
                        child: Text(
                          context.l10n.countupDay,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Tab(
                        child: Text(
                          context.l10n.calendar,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.blue,
                    dividerColor: Colors.transparent,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: theme.colorScheme.surface,
                  position: PopupMenuPosition.under,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.sort, size: 20),
                          SizedBox(width: 12),
                          // Text(context.l10n.sort),
                          Text('排序'),
                        ],
                      ),
                      onTap: () {
                        // 延迟执行，避免菜单关闭动画冲突
                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () => showDialog(
                            context: context,
                            builder: (context) => const SortDialog(),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.view_list, size: 20),
                          SizedBox(width: 12),
                          // Text(context.l10n.switchView),
                          Text('切换视图'),
                        ],
                      ),
                      onTap: () {
                        // TODO: 实现视图切换逻辑
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.push_pin, size: 20),
                          SizedBox(width: 12),
                          // Text(context.l10n.pinnedMode),
                          Text('置顶模式'),
                        ],
                      ),
                      onTap: () {
                        // 延迟执行，避免菜单关闭动画冲突
                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () => _showPinnedDisplayModeDialog(context),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _EventList(filter: null),  // 全部
            _EventList(filter: countdownFilter),  // 倒数日
            _EventList(filter: countupFilter),   // 正数日
            CalendarPage(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (state.pendingDeleteEvent != null)
                  Positioned(
                    left: 32,  // 调整左边距，和右边 FAB 保持对称
                    bottom: 0,  // 保持和右边 FAB 相同的底部边距
                    child: FloatingActionButton(
                      heroTag: 'undo',
                      onPressed: () => context.read<EventBloc>().add(
                        const CancelEventDelete()
                      ),
                      shape: const CircleBorder(),
                      backgroundColor: AppColors.deleteAction,
                      foregroundColor: AppColors.onActionColor,
                      child: const Icon(Icons.undo, size: 32),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: FloatingActionButton(
                    heroTag: 'add',
                    onPressed: () => Navigator.push(
                      context,
                      RouteUtils.buildPageRoute(page: const AddEventPage()),
                    ),
                    shape: const CircleBorder(),
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    child: const Icon(Icons.add, size: 32),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 置顶模式
  void _showPinnedDisplayModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: theme.colorScheme.surface,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.push_pin),
                  title: const Text('单个置顶'),
                  selected: state.pinnedDisplayMode == PinnedDisplayMode.single,
                  trailing: state.pinnedDisplayMode == PinnedDisplayMode.single 
                      ? const Icon(Icons.check, size: 20) 
                      : null,
                  onTap: () {
                    context.read<EventBloc>().add(
                      const UpdatePinnedDisplayMode(PinnedDisplayMode.single)
                    );
                    Navigator.pop(context);
                  },
                  minLeadingWidth: 0,
                  horizontalTitleGap: 12,
                ),
                ListTile(
                  leading: const Icon(Icons.view_carousel),
                  title: const Text('轮播展示'),
                  selected: state.pinnedDisplayMode == PinnedDisplayMode.carousel,
                  trailing: state.pinnedDisplayMode == PinnedDisplayMode.carousel 
                      ? const Icon(Icons.check, size: 20) 
                      : null,
                  onTap: () {
                    context.read<EventBloc>().add(
                      const UpdatePinnedDisplayMode(PinnedDisplayMode.carousel)
                    );
                    Navigator.pop(context);
                  },
                  minLeadingWidth: 0,
                  horizontalTitleGap: 12,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 事件列表
class _EventList extends StatefulWidget {
  final bool Function(Event)? filter;
  const _EventList({this.filter});

  @override
  State<_EventList> createState() => _EventListState();
}

// 事件列表状态
class _EventListState extends State<_EventList> with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  Timer? _timer;

  // 保持状态，避免切换tab重新加载
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _startAutoPlay();
    // 只在第一次加载时获取事件
    if (context.read<EventBloc>().state.status == EventStatus.initial) {
      context.read<EventBloc>().add(LoadEvents());
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  // 置顶项轮播图自动播放
  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final state = context.read<EventBloc>().state;
      if (state.pinnedDisplayMode == PinnedDisplayMode.carousel &&
          state.pinnedEvents.length > 1 &&
          _pageController.hasClients) {
        final nextPage = (_pageController.page?.round() ?? 0) + 1;
        _pageController.animateToPage(
          nextPage,  // 不需要取模，让它自然滑动到下一页
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  List<Event> _filterEvents(List<Event> events) {
    if (widget.filter == null) {
      return events;
    }
    return events.where(widget.filter!).toList();
  }

  // 获取空状态消息
  String _getEmptyMessage(EventState state) {
    if (state.selectedCategory != null) {
      return '【${state.selectedCategory}】分类下暂无${widget.filter == DatePage.countdownFilter ? '倒数日' : widget.filter == DatePage.countupFilter ? '正数日' : '事件'}';
    }
    return widget.filter == DatePage.countdownFilter 
        ? '暂无倒数日' 
        : widget.filter == DatePage.countupFilter 
            ? '暂无正数日' 
            : '开始添加你的第一个事件吧';
  }

  // 获取空状态图标
  IconData _getEmptyIcon(EventState state) {
    if (state.selectedCategory != null) {
      // 从分类列表中查找对应的分类
      try {
        final category = state.categories.firstWhere(
          (c) => c.name == state.selectedCategory
        );
        // 如果该分类有图标，则使用分类的图标
        if (category.iconName != null) {
          return EventIconMapping.getIcon(category.iconName!);
        }
      } catch (_) {}
      // 如果找不到分类或分类没有图标，使用默认图标
      return Icons.folder_outlined;
    }
    
    // 非分类情况的图标保持不变
    return widget.filter == DatePage.countdownFilter 
        ? Icons.timer 
        : widget.filter == DatePage.countupFilter 
            ? Icons.event_available 
            : Icons.add_circle_outline;
  }

  // 构建事件列表
  @override
  Widget build(BuildContext context) {
    super.build(context);  // 必须调用
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state.status == EventStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 根据当前分类筛选置顶事件
        final pinnedEvents = widget.filter == null 
            ? state.pinnedEvents
            : state.pinnedEvents.where(widget.filter!).toList();

        // 过滤未置顶的事件，使用 sortedEvents 排序
        final filteredEvents = _filterEvents(state.sortedEvents);

        if (filteredEvents.isEmpty) {
          return EmptyState(
            message: _getEmptyMessage(state),
            icon: _getEmptyIcon(state),
          );
        }

        // 构建事件列表
        return Column(
          children: [
            if (pinnedEvents.isNotEmpty) ...[
              _buildPinnedArea(pinnedEvents, state.pinnedDisplayMode),
              const SizedBox(height: 4),  // 固定间距
            ],
            
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: filteredEvents.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  context.read<EventBloc>().add(EventReordered(
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  ));
                },
                itemBuilder: (context, index) {
                  return EventCard(
                    key: ValueKey(filteredEvents[index].id),
                    event: filteredEvents[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建置顶区域
  Widget _buildPinnedArea(List<Event> pinnedEvents, PinnedDisplayMode mode) {
    if (pinnedEvents.isEmpty) return const SizedBox();
    
    // 如果是单个置顶模式或只有一个置顶项，不使用 PageView
    if (mode == PinnedDisplayMode.single || pinnedEvents.length == 1) {
      return SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: EventCard(
            event: pinnedEvents.first,
            iconSize: 28,  // 增加图标大小
            titleStyle: const TextStyle(
              fontSize: 20, // 增加文字大小
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            dateWeekStyle: const TextStyle(
              fontSize: 16, // 增加文字大小
              // fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            prefixStyle: const TextStyle(
              fontSize: 20, // 增加文字大小
              // fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            numberDayStyle: const TextStyle(
              fontSize: 24, // 增加文字大小
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // 轮播图
    return SizedBox(
      height: 100,
      child: CustomPageView(  // 使用自定义的 PageView
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (page) {
          final itemCount = pinnedEvents.length;
          if (page == itemCount * 3 - 1) {
            _pageController.jumpToPage(itemCount * 2 - 1);
          } else if (page == 0) {
            _pageController.jumpToPage(itemCount);
          }
        },
        children: List.generate(
          pinnedEvents.length * 3,
          (index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: EventCard(
              event: pinnedEvents[index % pinnedEvents.length],
            ),
          ),
        ),
      ),
    );
  }

  // 获取过滤名称
  String _getFilterName() {
    if (widget.filter == null) return '事件';
    return widget.filter == DatePage.countdownFilter ? '倒数日' : '正数日';
  }
}
