import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_event.dart'; 
import 'dart:io';
import 'package:remind_me/theme/app_colors.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/views/pages/date/edit_event_page.dart';
import 'package:remind_me/utils/common/route_utils.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0), // 添加上下和左右间距
      child: Slidable(
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.6,
          children: [
            SlidableAction(
              flex: 1,
              onPressed: (_) {
                // TODO: 进入时间线记录
              },
              backgroundColor: AppColors.timelineAction,
              foregroundColor: AppColors.onActionColor,
              icon: Icons.timeline,
              label: context.l10n.timeline,
              spacing: 4, // 图标和文字间距
              padding: EdgeInsets.zero, // 移除默认内边距
              autoClose: true, // 点击后自动关闭
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => _togglePin(context),
              backgroundColor: AppColors.pinAction,
              foregroundColor: AppColors.onActionColor,
              icon: event.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: event.isPinned ? context.l10n.unpin : context.l10n.pin,
              spacing: 4, // 图标和文字间距
              padding: EdgeInsets.zero, // 移除默认内边距
              autoClose: true, // 点击后自动关闭
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5, // 控制滑出的宽度比例
          children: [
            SlidableAction(
              flex: 1,
              onPressed: (_) => _editEvent(context),
              backgroundColor: AppColors.editAction,
              foregroundColor: AppColors.onActionColor,
              icon: Icons.edit,
              label: context.l10n.edit,
              spacing: 4, // 图标和文字间距
              padding: EdgeInsets.zero, // 移除默认内边距
              autoClose: true, // 点击后自动关闭
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => _deleteEvent(context),
              backgroundColor: AppColors.deleteAction,
              foregroundColor: AppColors.onActionColor,
              icon: Icons.delete,
              label: context.l10n.delete,
              spacing: 4, // 图标和文字间距
              padding: EdgeInsets.zero, // 移除默认内边距
              autoClose: true, // 点击后自动关闭
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero, // 移除卡片默认边距
          // color: theme.brightness == Brightness.dark 
          //     ? theme.colorScheme.surfaceContainer
          //     : Colors.white,
          child: Container(
            decoration: _buildBackgroundDecoration(context),
            child: InkWell(
              onDoubleTap: () => _toggleDisplayUnit(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 调整内边距
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 确保内容垂直居中
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      width: 48, // 固定宽度，根据实际需求调整
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${event.displayPrefix}',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      event.getFormattedNumber(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _getDaysText(),
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDaysText() {
    // Implementation of _getDaysText method
    return ''; // Placeholder return, actual implementation needed
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = Theme.of(context).colorScheme.surface;  // 统一使用主题色

    switch (event.backgroundType) {
      case BackgroundType.color:
        return BoxDecoration(
          color: event.backgroundColor ?? defaultColor,
          borderRadius: BorderRadius.circular(8),
        );
      case BackgroundType.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: event.gradientColors ?? [defaultColor, defaultColor],
          ),
          borderRadius: BorderRadius.circular(8),
        );
      case BackgroundType.image:
        return BoxDecoration(
          image: event.localImagePath != null
              ? DecorationImage(
                  image: FileImage(File(event.localImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        );
      case BackgroundType.animation:
        return BoxDecoration(
          color: defaultColor,
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  void _togglePin(BuildContext context) {
    context.read<EventBloc>().add(
      UpdateEvent(event.copyWith(isPinned: !event.isPinned))
    );
  }

  void _toggleDisplayUnit(BuildContext context) {
    context.read<EventBloc>().add(
      UpdateEvent(event.toggleUnit())
    );
  }

  void _editEvent(BuildContext context) {
    Navigator.push(
      context,
      RouteUtils.buildPageRoute(page: EditEventPage(event: event)),
    );
  }

  void _deleteEvent(BuildContext context) {
    context.read<EventBloc>().add(DeleteEvent(event.id));
  }
}
