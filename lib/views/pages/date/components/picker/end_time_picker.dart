import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/l10n/l10n.dart';

class EndTimePicker extends StatefulWidget {
  final DateTime? initialTime;
  final ValueChanged<DateTime?> onTimeChanged;

  const EndTimePicker({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<EndTimePicker> createState() => _EndTimePickerState();
}

class _EndTimePickerState extends State<EndTimePicker> {
  late bool hasEndTime;
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  @override
  void initState() {
    super.initState();
    
    // 强制设置为false，除非明确传入了初始时间
    hasEndTime = widget.initialTime != null;
    
    // 设置默认日期为当前日期
    final now = DateTime.now();
    selectedYear = widget.initialTime?.year ?? now.year;
    selectedMonth = widget.initialTime?.month ?? now.month;
    selectedDay = widget.initialTime?.day ?? now.day;
  }

  DateTime? _getSelectedDateTime() {
    if (!hasEndTime) return null;
    return DateTime(selectedYear, selectedMonth, selectedDay);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                  Text(
                    hasEndTime 
                        ? DateFormat('yyyy-MM-dd').format(DateTime(selectedYear, selectedMonth, selectedDay))
                        : '无结束时间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onTimeChanged(_getSelectedDateTime());
                      Navigator.pop(context);
                    },
                    child: Text(context.l10n.confirm),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // 开关选项
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '设置结束时间',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Switch(
                    value: hasEndTime,
                    onChanged: (value) {
                      setState(() {
                        hasEndTime = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // 日期选择器
            if (hasEndTime) Expanded(
              child: Row(
                children: [
                  // 年份选择器 - 从当前年份开始，显示10年
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      diameterRatio: 4.0,
                      squeeze: 1.0,
                      useMagnifier: false,
                      selectionOverlay: null,
                      backgroundColor: Colors.transparent,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedYear - DateTime.now().year,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedYear = DateTime.now().year + index;
                          _adjustDayIfNeeded();
                        });
                      },
                      children: List.generate(10, (index) {
                        final year = DateTime.now().year + index;
                        return Center(
                          child: Text(
                            '$year年',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  // 月份选择器
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      diameterRatio: 4.0,
                      squeeze: 1.0,
                      useMagnifier: false,
                      selectionOverlay: null,
                      backgroundColor: Colors.transparent,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedMonth - 1,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMonth = index + 1;
                          _adjustDayIfNeeded();
                        });
                      },
                      children: List.generate(12, (index) {
                        return Center(
                          child: Text(
                            '${index + 1}月',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  // 日期选择器
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      diameterRatio: 4.0,
                      squeeze: 1.0,
                      useMagnifier: false,
                      selectionOverlay: null,
                      backgroundColor: Colors.transparent,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedDay - 1,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDay = index + 1;
                        });
                      },
                      children: List.generate(
                        _getDaysInMonth(selectedYear, selectedMonth),
                        (index) {
                          return Center(
                            child: Text(
                              '${index + 1}日',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  void _adjustDayIfNeeded() {
    final daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
    if (selectedDay > daysInMonth) {
      selectedDay = daysInMonth;
    }
  }
} 