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
                const Expanded(
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: '全部'),
                      Tab(text: '倒数日'),
                      Tab(text: '正数日'),
                      Tab(text: '日历'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.blue,
                    dividerColor: Colors.transparent,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showOperationMenu(context),
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

  // 展示操作菜单
  void _showOperationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('按时间排序'),
              onTap: () {
                // TODO: 实现排序逻辑
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('切换视图'),
              onTap: () {
                // TODO: 实现视图切换逻辑
                Navigator.pop(context);
              },
            ),
            // 可以添加更多操作选项
          ],
        );
      },
    );
  }
}

// 事件列表
class _EventList extends StatelessWidget {
  final bool Function(Event)? filter;

  const _EventList({this.filter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state.status == EventStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = _filterEvents(state.events);
        
        return Column(
          children: [
            if (state.pinnedEvent != null)
              EventCard(event: state.pinnedEvent!),
              
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<EventBloc>().add(
                    EventReordered(oldIndex, newIndex)
                  );
                },
                itemBuilder: (context, index) {
                  return EventCard(
                    key: ValueKey(events[index].id),
                    event: events[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Event> _filterEvents(List<Event> events) {
    if (filter == null) return events;
    return events.where(filter!).toList();
  }
}
