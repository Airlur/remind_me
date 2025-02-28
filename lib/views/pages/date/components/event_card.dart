import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_event.dart'; 
import 'package:remind_me/theme/app_colors.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/views/pages/date/edit_event_page.dart';
import 'package:remind_me/utils/common/route_utils.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';
import 'package:remind_me/utils/common/lunar_utils.dart';
import 'package:remind_me/utils/ui/background_utils.dart';
import 'package:remind_me/views/pages/date/event_detail_page.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final double? iconSize;
  final TextStyle? titleStyle;
  final TextStyle? dateWeekStyle;
  final TextStyle? prefixStyle;
  final TextStyle? numberDayStyle;

  const EventCard({
    required this.event,
    this.iconSize,
    this.titleStyle,
    this.dateWeekStyle,
    this.prefixStyle,
    this.numberDayStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Slidable(
      key: ValueKey(event.id),
      closeOnScroll: true,
      groupTag: 'eventGroup',
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.7,
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (_) {
              // TODO: 进入时间线记录
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('时间线记录功能正在开发中')),
              );
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
          SlidableAction(
            flex: 1,
            onPressed: (_) {
              // TODO: 显示详情
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('详情功能正在开发中')),
              );
            },
            backgroundColor: AppColors.infoAction, // 紫色表示详情
            foregroundColor: AppColors.onActionColor,
            icon: Icons.info_outline,
            // label: context.l10n.details,
            label: '详情',
            spacing: 4,
            padding: EdgeInsets.zero,
            autoClose: true,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.6,
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
          SlidableAction(
            flex: 1,
            onPressed: (_) {
              // TODO: 分享功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能正在开发中')),
              );
            },
            backgroundColor: AppColors.shareAction,
            foregroundColor: AppColors.onActionColor,
            icon: Icons.share,
            label: context.l10n.share,
            spacing: 4,
            padding: EdgeInsets.zero,
            autoClose: true,
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
          decoration: BackgroundUtils.getEventCardBackground(event, context),
          child: InkWell(
            onTap: () => _openDetailPage(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 调整内边距
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 确保内容垂直居中
                children: [
                  if (event.iconName != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        EventIconMapping.getIcon(event.iconName!),
                        size: iconSize ?? 20,  // 使用传入的图标大小
                        color: BackgroundUtils.getEventTextColor(event, context),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          style: titleStyle ?? TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BackgroundUtils.getEventTextColor(event, context),
                            fontFamily: event.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${LunarUtils.formatDateWithYear(event.targetDate, event.isLunar, context)} ${LunarUtils.getWeekDay(event.targetDate, context, useShort: true)}',
                          style: dateWeekStyle ?? TextStyle(
                            fontSize: 12,
                            color: BackgroundUtils.getEventTextColor(event, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    event.getDisplayPrefix(context),
                    style: prefixStyle ?? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BackgroundUtils.getEventTextColor(event, context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.getDisplayDays(context),
                    style: numberDayStyle ?? TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: BackgroundUtils.getEventTextColor(event, context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.getDisplayUnit(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BackgroundUtils.getEventTextColor(event, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _togglePin(BuildContext context) {
    if (event.isPinned) {
      context.read<EventBloc>().add(UnpinEvent(event.id));
    } else {
      context.read<EventBloc>().add(PinEvent(event.id));
    }
  }


  void _editEvent(BuildContext context) {
    Navigator.push(
      context,
      RouteUtils.buildPageRoute(page: EditEventPage(event: event)),
    );
  }

  void _deleteEvent(BuildContext context) {
    context.read<EventBloc>().add(InitiateEventDelete(event));
  }

  void _openDetailPage(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      Navigator.push(
        context,
        RouteUtils.buildPageRoute(page: EventDetailPage(event: event)),
      );
      return;
    }

    Navigator.of(context).push(
      RouteUtils.buildEventDetailRoute(context, event, box),
    );
  }
}
