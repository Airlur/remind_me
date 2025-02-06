import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_event.dart'; 
import 'dart:io';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Slidable(
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (_) {
              // TODO: 进入时间线记录
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.timeline,
            label: '时间线',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (_) => _togglePin(context),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: event.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: event.isPinned ? '取消置顶' : '置顶',
          ),
          SlidableAction(
            flex: 1,
            onPressed: (_) => _editEvent(context),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            flex: 1,
            onPressed: (_) => _deleteEvent(context),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        // color: theme.brightness == Brightness.dark 
        //     ? theme.colorScheme.surfaceContainer
        //     : Colors.white,
        child: Container(
          decoration: _buildBackgroundDecoration(context),
          child: InkWell(
            onDoubleTap: () => _toggleDisplayUnit(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                  Text(
                    '${event.displayPrefix} ',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
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
    );
  }

  String _getDaysText() {
    // Implementation of _getDaysText method
    return ''; // Placeholder return, actual implementation needed
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark 
        ? Theme.of(context).colorScheme.surfaceContainer
        : Colors.white;

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
    // TODO: 实现编辑事件
  }

  void _deleteEvent(BuildContext context) {
    context.read<EventBloc>().add(DeleteEvent(event.id));
  }
}
