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

class DatePage extends StatelessWidget {
  const DatePage({super.key});

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
                      Tab(text: context.l10n.all),
                      Tab(text: context.l10n.countdownDay),
                      Tab(text: context.l10n.countupDay),
                      Tab(text: context.l10n.calendar),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
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
        body: TabBarView(
          children: [
            const _EventList(filter: null),  // 全部
            _EventList(filter: (event) => event.isCountdown),  // 倒数日
            _EventList(filter: (event) => !event.isCountdown), // 正数日
            const CalendarPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            RouteUtils.buildPageRoute(page: const AddEventPage()),
          ),
          shape: const CircleBorder(),
          backgroundColor: theme.colorScheme.surface, // 设置背景色
          foregroundColor: theme.colorScheme.onSurface, // 设置图标色
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

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

class _EventListState extends State<_EventList> {
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _startAutoPlay();
    context.read<EventBloc>().add(LoadEvents());
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
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

        return Column(
          children: [
            if (pinnedEvents.isNotEmpty) ...[
              _buildPinnedArea(pinnedEvents, state.pinnedDisplayMode),
            ],
            
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: filteredEvents.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<EventBloc>().add(
                    EventReordered(oldIndex, newIndex)
                  );
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

  Widget _buildPinnedArea(List<Event> pinnedEvents, PinnedDisplayMode mode) {
    if (pinnedEvents.isEmpty) return const SizedBox();
    
    // 如果是单个置顶模式或只有一个置顶项，不使用 PageView
    if (mode == PinnedDisplayMode.single || pinnedEvents.length == 1) {
      return SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: EventCard(event: pinnedEvents.first),
        ),
      );
    }

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
}
