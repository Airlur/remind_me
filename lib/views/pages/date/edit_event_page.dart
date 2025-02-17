import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/models/event.dart';
import 'components/date_picker.dart';
import 'package:remind_me/l10n/l10n.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _titleController;
  late DateTime _targetDate;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _targetDate = widget.event.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enterTitle)),
      );
      return;
    }

    final updatedEvent = widget.event.copyWith(
      title: _titleController.text,
      targetDate: _targetDate,
    );

    context.read<EventBloc>().add(UpdateEvent(updatedEvent));
    Navigator.of(context).pop();
  }

  Future<void> _showDatePicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DatePickerWidget(
          initialDate: _targetDate,
          onDateChanged: (date) {
            setState(() {
              _targetDate = date;
            });
          },
        );
      },
    );
  }

  String get _previewText {
    if (_titleController.text.isEmpty) return context.l10n.preview;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(_targetDate.year, _targetDate.month, _targetDate.day);
    
    final isToday = today.isAtSameMomentAs(target);
    final isCountdown = target.isAfter(today);
    final absDays = target.difference(today).inDays.abs();
    
    final prefix = isToday ? '就是' : (isCountdown ? context.l10n.daysLeft : context.l10n.daysAgo);
    final daysText = isToday ? '今天' : '${absDays}天';
    
    return '${_titleController.text} $prefix $daysText';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.edit),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: Text(context.l10n.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.title),
                    title: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: context.l10n.enterTitle,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_calendar_rounded),
                    title: Text(context.l10n.targetDate),
                    trailing: Text(
                      _targetDate.toString().split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: _showDatePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: Text(context.l10n.backgroundSettings),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onTap: () {
                      // TODO: 实现背景设置
                    },
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(context.l10n.preview, style: const TextStyle(fontSize: 16)),
            ),
            Card(
              margin: const EdgeInsets.all(16),
              child: Container(
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  _previewText,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 