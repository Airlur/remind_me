import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/models/event.dart';
import 'package:uuid/uuid.dart';
import 'components/date_picker.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _titleController = TextEditingController();
  DateTime _targetDate = DateTime.now();
  
  String get _previewText {
    if (_titleController.text.isEmpty) return '预览效果';
    
    final difference = _targetDate.difference(DateTime.now()).inDays;
    final isCountdown = _targetDate.isAfter(DateTime.now());
    final prefix = isCountdown ? '还有' : '已经';
    
    return '${_titleController.text} $prefix ${difference.abs()}天';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    final event = Event(
      id: const Uuid().v4(),
      title: _titleController.text,
      targetDate: _targetDate,
      createdAt: DateTime.now(),
    );

    context.read<EventBloc>().add(AddEvent(event));
    Navigator.of(context).pop();
  }

  Future<void> _showDatePicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加特殊日'),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text('保存'),
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
                      decoration: const InputDecoration(
                        // labelText: '标题',
                        hintText: '请输入标题',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,  // 移除内边距
                        isDense: true,  // 使输入框更紧凑
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_calendar_rounded),
                    title: const Text('目标日期'),
                    trailing: Text(
                      _targetDate.toString().split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: _showDatePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('背景设置'),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onTap: () {
                      // TODO: 展开背景设置
                    },
                  ),
                ],
              ),
            ),
            
            // 预览区域
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('预览效果', style: TextStyle(fontSize: 16)),
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