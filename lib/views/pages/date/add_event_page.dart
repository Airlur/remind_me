import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/models/event.dart';
import 'package:uuid/uuid.dart';
import 'components/picker/date_picker.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'style_settings_page.dart';
import 'components/category/category_select_page.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/utils/common/lunar_utils.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/theme/app_colors.dart';
import 'components/picker/reminder_time_picker.dart';
import 'components/picker/repeat_rule_picker.dart';
import 'components/picker/end_time_picker.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _titleController = TextEditingController();
  DateTime _targetDate = DateTime.now();
  bool _isLunar = false;
  String? _category;
  String? _categoryIconName;
  bool _isPinned = false;
  bool _includeStartDay = false;
  BackgroundType? _backgroundType;
  int? _backgroundColorValue;
  List<int>? _gradientColorValues;
  String? _localImagePath;
  String? _animationType;
  String? _iconName;
  String? _fontFamily;
  DateTime? _reminderTime;
  Repeat? _repeat;
  DateTime? _endTime;

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
      isPinned: _isPinned,
      includeStartDay: _includeStartDay,
      isLunar: _isLunar,
      category: _category,
      backgroundType: _backgroundType ?? BackgroundType.color,
      backgroundColorValue: _backgroundColorValue,
      gradientColorValues: _gradientColorValues,
      localImagePath: _localImagePath,
      animationType: _animationType,
      iconName: _iconName,
      fontFamily: _fontFamily,
      repeat: _repeat,
      endTime: _endTime,
    );

    context.read<EventBloc>().add(AddEvent(event));
    Navigator.of(context).pop();
  }

  Future<void> _showDatePicker(T) async {
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
    // LoggerUtils.i('打开分类选择页: 当前category=$_category, icon=$_categoryIconName', 'EditEventPage');
  
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectPage(
          selectedCategory: _category,
          selectedCategoryIcon: _categoryIconName,
        ),
      ),
    );
    
    // LoggerUtils.i('分类选择返回: name=${result?.name}, icon=${result?.iconName}', 'EditEventPage');
  
    setState(() {
      LoggerUtils.i('更新状态前: category=$_category, icon=$_categoryIconName', 'EditEventPage');
      _category = result?.name;
      _categoryIconName = result?.iconName;
      LoggerUtils.i('更新状态后: category=$_category, icon=$_categoryIconName', 'EditEventPage');
    });
  }

  Future<void> _showReminderTimePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ReminderTimePicker(
          initialTime: _reminderTime ?? DateTime.now(),
          onTimeChanged: (newTime) {
            setState(() {
              _reminderTime = newTime;
            });
          },
        );
      },
    );
  }

  Future<void> _showRepeatRulePicker() async {
    // TODO: 实现重复规则选择
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return RepeatRulePicker(
          initialRepeat: _repeat ?? Repeat.none,
          onRepeatChanged: (newRepeat) {
            setState(() {
              _repeat = newRepeat;
            });
          },
        );
      },
    );
  }

  Future<void> _showEndTimePicker() async {
    // TODO: 实现结束时间选择
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EndTimePicker(
          initialTime: _endTime ?? DateTime.now(),
          onTimeChanged: (newTime) {
            setState(() {
              _endTime = newTime;
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
        title: Text(context.l10n.addSpecialDay),
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
            // 第一区域：基础信息
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
                    onTap: () => _showDatePicker(theme),
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(context.l10n.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_categoryIconName != null) Icon(
                          CategoryIconMapping.getIcon(_categoryIconName!),
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        if (_category != null) const SizedBox(width: 4),
                        Text(
                          _category ?? context.l10n.all, 
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 16
                          )
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    onTap: _showCategoryPicker,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),  // 减小区域间距

            // 第二区域：时间设置
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_alarm),
                    title: Text(context.l10n.reminderTime),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _reminderTime != null 
                            ? DateFormat('yyyy-MM-dd HH:mm').format(_reminderTime!) 
                            : '无',
                          style: TextStyle(
                            color: _reminderTime != null 
                              ? theme.colorScheme.primary 
                              : AppColors.iconGrayColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    onTap: _showReminderTimePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: Text(context.l10n.repeat),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _repeat != null 
                            ? _repeat.toString().split('.').last 
                            : '不重复',
                          style: TextStyle(
                            color: _repeat != null 
                              ? theme.colorScheme.primary 
                              : AppColors.iconGrayColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    onTap: _showRepeatRulePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_off),
                    title: Text(context.l10n.endTime),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _endTime != null 
                            ? DateFormat('yyyy-MM-dd HH:mm').format(_endTime!) 
                            : '无',
                          style: TextStyle(
                            color: _endTime != null 
                              ? theme.colorScheme.primary 
                              : AppColors.iconGrayColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    onTap: _showEndTimePicker,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 第三区域：其他设置
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

            // 第四区域：样式设置（简化为单个入口）
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