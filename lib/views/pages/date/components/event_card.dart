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
    return Slidable(
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _togglePin(context),
            backgroundColor: Colors.blue,
            icon: event.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: event.isPinned ? '取消置顶' : '置顶',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editEvent(context),
            backgroundColor: Colors.orange,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            onPressed: (_) => _deleteEvent(context),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: _buildBackgroundDecoration(),
          child: InkWell(
            onDoubleTap: () => _toggleDisplayUnit(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${event.displayPrefix} ',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    event.getFormattedNumber(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  BoxDecoration _buildBackgroundDecoration() {
    switch (event.backgroundType) {
      case BackgroundType.color:
        return BoxDecoration(
          color: event.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
        );
      case BackgroundType.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: event.gradientColors ?? [Colors.white, Colors.white],
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
        // TODO: 实现动画背景
        return BoxDecoration(
          color: Colors.white,
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
    // TODO: 实现删除事件
  }
}
