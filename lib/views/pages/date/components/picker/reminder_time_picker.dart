import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class ReminderTimePicker extends StatefulWidget {
  final DateTime? initialTime;
  final DateTime targetDate; // 目标日期参数
  final ValueChanged<DateTime?> onTimeChanged;

  const ReminderTimePicker({
    super.key,
    this.initialTime,
    required this.targetDate,
    required this.onTimeChanged,
  });

  @override
  State<ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  late int selectedTypeIndex;
  late int selectedHour;
  late int selectedMinute;
  
  // 提醒类型选项
  final List<String> _reminderTypes = [
    '不提醒',
    '当天',
    '提前1天',
    '提前2天',
    '提前3天',
    '提前1周',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.initialTime == null) {
      selectedTypeIndex = 0; // 不提醒
      // 当前时间
      selectedHour = DateTime.now().hour;
      selectedMinute = DateTime.now().minute;
    } else {
      // 根据初始时间判断类型
      final targetDate = widget.targetDate;
      // 计算天数差异（注意：可能为负数）
      final diff = targetDate.difference(widget.initialTime!).inDays;
      
      LoggerUtils.i('【ReminderTimePicker】初始化 - 目标日期: $targetDate, 提醒时间: ${widget.initialTime}, 差异天数: $diff', 'ReminderTimePicker');
      
      // 修改判断逻辑，处理负数情况
      if (diff == 0) {
        selectedTypeIndex = 1; // 当天
      } else if (diff == 1) {
        selectedTypeIndex = 2; // 提前1天
      } else if (diff == 2) {
        selectedTypeIndex = 3; // 提前2天
      } else if (diff == 3) {
        selectedTypeIndex = 4; // 提前3天
      } else if (diff == 7) {
        selectedTypeIndex = 5; // 提前1周
      } else {
        // 如果不匹配任何预设选项，但确实有提醒时间
        // 选择最接近的预设选项或使用自定义选项
        if (diff > 0 && diff < 7) {
          // 选择最接近的天数
          selectedTypeIndex = diff > 3 ? 5 : diff + 1;
        } else {
          // 如果差异为负数或大于7天，使用当天选项
          selectedTypeIndex = 1;
        }
      }
      
      selectedHour = widget.initialTime!.hour;
      selectedMinute = widget.initialTime!.minute;
      
      LoggerUtils.i('【ReminderTimePicker】选择的类型索引: $selectedTypeIndex, 小时: $selectedHour, 分钟: $selectedMinute', 'ReminderTimePicker');
    }
  }

  DateTime? _getSelectedDateTime() {
    if (selectedTypeIndex == 0) return null; // 不提醒
    
    // 获取当前日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (selectedTypeIndex) {
      case 1: // 当天
        return DateTime(
          today.year, 
          today.month, 
          today.day, 
          selectedHour, 
          selectedMinute
        );
      case 2: // 提前1天
        return DateTime(
          widget.targetDate.year, 
          widget.targetDate.month, 
          widget.targetDate.day - 1, 
          selectedHour, 
          selectedMinute
        );
      case 3: // 提前2天
        return DateTime(
          widget.targetDate.year, 
          widget.targetDate.month, 
          widget.targetDate.day - 2, 
          selectedHour, 
          selectedMinute
        );
      case 4: // 提前3天
        return DateTime(
          widget.targetDate.year, 
          widget.targetDate.month, 
          widget.targetDate.day - 3, 
          selectedHour, 
          selectedMinute
        );
      case 5: // 提前1周
        return DateTime(
          widget.targetDate.year, 
          widget.targetDate.month, 
          widget.targetDate.day - 7, 
          selectedHour, 
          selectedMinute
        );
      default:
        return null;
    }
  }

  // 获取显示文本 - 显示完整日期
  String _getDisplayText() {
    final dateTime = _getSelectedDateTime();
    if (dateTime == null) return '不提醒';
    
    // 显示完整日期和时间
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  void _handleConfirm() {
    widget.onTimeChanged(_getSelectedDateTime());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 340,
        padding: const EdgeInsets.only(top: 6.0),
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                  Text(
                    _getDisplayText(),
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleConfirm,
                    child: Text(context.l10n.confirm),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // 选择器主体
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 选中行背景
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: theme.colorScheme.primary,
                          ),
                          bottom: BorderSide(
                            width: 1,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // 提醒类型选择器
                      Expanded(
                        flex: 2,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          diameterRatio: 4.0,
                          squeeze: 1.0,
                          useMagnifier: false,
                          selectionOverlay: null,
                          backgroundColor: Colors.transparent,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedTypeIndex,
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedTypeIndex = index;
                            });
                          },
                          children: _reminderTypes.map((type) {
                            return Center(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // 小时选择器
                      if (selectedTypeIndex != 0) Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          diameterRatio: 4.0,
                          squeeze: 1.0,
                          useMagnifier: false,
                          selectionOverlay: null,
                          backgroundColor: Colors.transparent,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedHour,
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHour = index;
                            });
                          },
                          children: List.generate(24, (index) {
                            return Center(
                              child: Text(
                                '$index时',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      
                      // 分钟选择器
                      if (selectedTypeIndex != 0) Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          diameterRatio: 4.0,
                          squeeze: 1.0,
                          useMagnifier: false,
                          selectionOverlay: null,
                          backgroundColor: Colors.transparent,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMinute,
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMinute = index;
                            });
                          },
                          children: List.generate(60, (index) {
                            return Center(
                              child: Text(
                                '$index分',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}