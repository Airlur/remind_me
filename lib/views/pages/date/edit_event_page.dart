import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/models/event.dart';
import 'components/picker/date_picker.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'style_settings_page.dart';
import 'components/category/category_select_page.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/utils/common/lunar_utils.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _titleController;
  late DateTime _targetDate;
  late bool _isPinned;
  late bool _includeStartDay;
  late bool _isLunar;
  String? _category;
  String? _categoryIconName;
  late BackgroundType? _backgroundType;
  late int? _backgroundColorValue;
  late List<int>? _gradientColorValues;
  late String? _localImagePath;
  late String? _animationType;
  late String? _iconName;
  late String? _fontFamily;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _targetDate = widget.event.targetDate;
    _isPinned = widget.event.isPinned;
    _includeStartDay = widget.event.includeStartDay;
    _isLunar = widget.event.isLunar;
    _category = widget.event.category;
    final categories = context.read<EventBloc>().state.categories;
    _categoryIconName = categories
        .firstWhere(
          (c) => c.name == widget.event.category,
          orElse: () => Category(name: '', iconName: null),
        )
        .iconName;
    _backgroundType = widget.event.backgroundType;
    _backgroundColorValue = widget.event.backgroundColorValue;
    _gradientColorValues = widget.event.gradientColorValues;
    _localImagePath = widget.event.localImagePath;
    _animationType = widget.event.animationType;
    _iconName = widget.event.iconName;
    _fontFamily = widget.event.fontFamily;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
          initialIsLunar: _isLunar,
          onDateChanged: (date) {
            setState(() {
              _targetDate = date;
            });
          },
          onLunarChanged: (isLunar) {
            setState(() {
              _isLunar = isLunar;
            });
          },
        );
      },
    );
  }

  Future<void> _showCategoryPicker() async {
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectPage(
          selectedCategory: _category,
          selectedCategoryIcon: _categoryIconName,
        ),
      ),
    );
    
    setState(() {
      _category = result?.name;
      _categoryIconName = result?.iconName;
    });
  }

  void _saveEvent() {
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    final event = Event(
      id: widget.event.id,
      title: _titleController.text,
      targetDate: _targetDate,
      createdAt: widget.event.createdAt,
      displayUnit: widget.event.displayUnit,
      isPinned: _isPinned,
      pinnedAt: widget.event.pinnedAt,
      backgroundType: _backgroundType ?? BackgroundType.color,
      backgroundColorValue: _backgroundColorValue,
      gradientColorValues: _gradientColorValues,
      localImagePath: _localImagePath,
      animationType: _animationType,
      isLunar: _isLunar,
      category: _category,
      order: widget.event.order,
      fontFamily: _fontFamily,
      iconName: _iconName,
      reminderTime: widget.event.reminderTime,
      includeStartDay: _includeStartDay,
    );

    LoggerUtils.i('事件更新对象: background=${event.backgroundColorValue}, icon=${event.iconName}', 'EditEventPage');
    context.read<EventBloc>().add(UpdateEvent(event));
    Navigator.of(context).pop();
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
                      LunarUtils.formatDate(_targetDate, _isLunar),
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    onTap: _showDatePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(context.l10n.category),
                    trailing: BlocBuilder<EventBloc, EventState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           if (_categoryIconName != null) Icon(
                              CategoryIconMapping.getIcon(_categoryIconName!),
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            if (_category != null) const SizedBox(width: 4),
                            Text(
                              _category ?? context.l10n.all, 
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16
                              )
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        );
                      },
                    ),
                    onTap: _showCategoryPicker,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(context.l10n.reminderTime),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      // TODO: 实现提醒时间选择
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: Text(context.l10n.repeat),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      // TODO: 实现重复规则选择
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_busy),
                    title: Text(context.l10n.endTime),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      // TODO: 实现结束时间选择
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.push_pin),
                    title: Text(context.l10n.pin),
                    value: _isPinned,
                    onChanged: (value) => setState(() => _isPinned = value),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.plus_one),
                    title: Text(context.l10n.includeStartDate),
                    value: _includeStartDay,
                    onChanged: (value) => setState(() => _includeStartDay = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.palette),
                title: Text(context.l10n.styleSettings),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  // 创建预览用的 Event 对象
                  final previewEvent = Event(
                    id: '0',  // 预览用，ID 不重要
                    title: _titleController.text,
                    targetDate: _targetDate,
                    createdAt: DateTime.now(),
                    isLunar: _isLunar,
                    includeStartDay: _includeStartDay,
                    backgroundType: _backgroundType ?? BackgroundType.color,
                    backgroundColorValue: _backgroundColorValue,
                    gradientColorValues: _gradientColorValues,
                    localImagePath: _localImagePath,
                    animationType: _animationType,
                    iconName: _iconName,
                    fontFamily: _fontFamily,
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StyleSettingsPage(
                        title: _titleController.text,
                        // dateText: '${LunarUtils.formatDateWithYear(_targetDate, _isLunar, context)} ${LunarUtils.getWeekDay(_targetDate, context, useShort: true)}',
                        // prefix: _prefix,
                        // absDays: _displayDays,
                        targetDate: _targetDate,
                        isLunar: _isLunar,
                        previewEvent: previewEvent,  // 传入预览 Event
                        backgroundType: _backgroundType,
                        backgroundColorValue: _backgroundColorValue,
                        gradientColorValues: _gradientColorValues,
                        localImagePath: _localImagePath,
                        animationType: _animationType,
                        iconName: _iconName,
                        fontFamily: _fontFamily,
                        onBackgroundChanged: (type, colorValue, gradientValues, imagePath, animation) {
                          setState(() {
                            _backgroundType = type;
                            _backgroundColorValue = colorValue;
                            _gradientColorValues = gradientValues;
                            _localImagePath = imagePath;
                            _animationType = animation;
                          });
                        },
                        onIconChanged: (value) {
                          setState(() {
                            _iconName = value;
                          });
                        },
                        onFontFamilyChanged: (value) {
                          setState(() {
                            _fontFamily = value;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 