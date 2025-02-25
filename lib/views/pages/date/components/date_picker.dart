import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lunar/lunar.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool initialIsLunar;
  final ValueChanged<bool>? onLunarChanged;

  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
    this.initialIsLunar = false,
    this.onLunarChanged,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  late bool isLunar;
  bool isLeapMonth = false;

  // 获取当前选择的日期（公历）
  DateTime get selectedDate {
    if (!isLunar) {
      return DateTime(selectedYear, selectedMonth, selectedDay);
    } else {
      // 农历转公历
      final lunar = Lunar.fromYmd(selectedYear, selectedMonth, selectedDay);
      final solar = lunar.getSolar();  // 使用 getSolar() 方法获取公历日期
      return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
    }
  }

  // 设置初始日期
  void _initializeDate() {
    if (!isLunar) {
      selectedYear = widget.initialDate.year;
      selectedMonth = widget.initialDate.month;
      selectedDay = widget.initialDate.day;
    } else {
      // 如果是农历日期，转换显示
      final lunar = Lunar.fromDate(widget.initialDate);
      selectedYear = lunar.getYear();
      selectedMonth = lunar.getMonth();
      selectedDay = lunar.getDay();
    }
  }

  // 确认按钮处理
  void _handleConfirm() {
    final date = selectedDate;
    widget.onDateChanged(date);
    if (widget.onLunarChanged != null) {
      widget.onLunarChanged!(isLunar);
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    isLunar = widget.initialIsLunar;
    _initializeDate();
  }

  String _getWeekDay(DateTime date) {
    final weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return weekDays[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDate = selectedDate;
    
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
                    _getWeekDay(currentDate),
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
            // 公历农历切换
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isLunar = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isLunar ? theme.colorScheme.surface : null,
                          borderRadius: BorderRadius.circular(8),
                          border: !isLunar ? Border.all(color: theme.colorScheme.primary) : null,
                        ),
                        child: Center(
                          child: Text(
                            '公历',
                            style: TextStyle(
                              color: !isLunar ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isLunar = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLunar ? theme.colorScheme.surface : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isLunar ? Border.all(color: theme.colorScheme.primary) : null,
                        ),
                        child: Center(
                          child: Text(
                            '农历',
                            style: TextStyle(
                              color: isLunar ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 日期选择器
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
                            width: 1,  // 统一边框粗细
                            color: theme.colorScheme.primary,  // 使用分割线颜色
                          ),
                          bottom: BorderSide(
                            width: 1,  // 统一边框粗细
                            color: theme.colorScheme.primary,  // 使用分割线颜色
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildPickerColumn(
                        items: List.generate(201, (index) => '${index + 1900}年'),
                        initialItem: selectedYear - 1900,
                        onSelectedItemChanged: onYearSelectedItemChanged,
                      ),
                      _buildPickerColumn(
                        items: List.generate(12, (index) => '${index + 1}月'),
                        initialItem: selectedMonth - 1,
                        onSelectedItemChanged: onMonthSelectedItemChanged,
                      ),
                      _buildPickerColumn(
                        items: List.generate(
                          _getDaysInMonth(selectedYear, selectedMonth),
                          (index) => '${index + 1}日',
                        ),
                        initialItem: selectedDay - 1,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedDay = index + 1;
                          });
                        },
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

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Widget _buildPickerColumn({
    required List<String> items,
    required int initialItem,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    // 根据是否农历生成不同的显示项
    final displayItems = isLunar ? _getLunarItems(items) : items;
    
    return Expanded(
      child: SizedBox(
        height: 200,
        child: CupertinoPicker(
          itemExtent: 40,
          diameterRatio: 4.0,
          squeeze: 1.0,
          useMagnifier: false,
          selectionOverlay: null,
          backgroundColor: Colors.transparent,
          scrollController: FixedExtentScrollController(
            initialItem: initialItem,
          ),
          onSelectedItemChanged: onSelectedItemChanged,
          children: displayItems.map((item) {
            return Center(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 转换农历显示
  List<String> _getLunarItems(List<String> items) {
    try {
      if (items.first.contains('年')) {
        // 年份转换 - 同时显示公历和农历年份
        return List.generate(201, (index) {
          final year = index + 1900;
          final lunar = Lunar.fromYmd(year, 1, 1);
          return '$year ${lunar.getYearInGanZhi()}年';
        });
      } else if (items.first.contains('月')) {
        // 月份转换 - 需要处理闰月
        final lunarYear = LunarYear.fromYear(selectedYear);
        final leapMonth = lunarYear.getLeapMonth();
        
        // 生成月份列表，包含闰月
        final monthList = <String>[];
        for (int i = 1; i <= 12; i++) {
          final lunar = Lunar.fromYmd(selectedYear, i, 1);
          monthList.add('${lunar.getMonthInChinese()}月');
          
          // 如果当前月是闰月，在当前月后添加闰月
          if (i == leapMonth) {
            monthList.add('闰${lunar.getMonthInChinese()}月');
          }
        }
        return monthList;
      } else {
        // 日期转换
        try {
          // 尝试获取30天，如果成功则当前日期有效
          Lunar.fromYmd(selectedYear, selectedMonth, 30);
          return List.generate(30, (index) {
            final lunar = Lunar.fromYmd(selectedYear, selectedMonth, index + 1);
            return lunar.getDayInChinese();
          });
        } catch (e) {
          // 如果30天无效，则尝试29天
          return List.generate(29, (index) {
            final lunar = Lunar.fromYmd(selectedYear, selectedMonth, index + 1);
            return lunar.getDayInChinese();
          });
        }
      }
    } catch (e) {
      LoggerUtils.e('Error in _getLunarItems: $e', 'DatePickerWidget');
      return items;
    }
  }

  // 在年份变化时检查并调整日期
  void onYearSelectedItemChanged(int index) {
    setState(() {
      final oldYear = selectedYear;
      final oldMonth = selectedMonth;
      final oldIsLeapMonth = isLeapMonth;
      selectedYear = index + 1900;
      
      if (isLunar) {
        // 只在农历模式下处理闰月逻辑
        final oldLunarYear = LunarYear.fromYear(oldYear);
        final newLunarYear = LunarYear.fromYear(selectedYear);
        final oldLeapMonth = oldLunarYear.getLeapMonth();
        final newLeapMonth = newLunarYear.getLeapMonth();
        
        if (newLeapMonth > 0) {
          // 切换到有闰月的年份
          if (oldLeapMonth == 0) {
            // 从无闰月年切换到有闰月年
            if (oldMonth > newLeapMonth) {
              selectedMonth = oldMonth;
            }
          } else {
            // 从有闰月年切换到有闰月年
            if (oldIsLeapMonth) {
              // 如果原来是闰月
              if (newLeapMonth == oldMonth) {
                // 如果新年份在同一个月有闰月，保持闰月
                isLeapMonth = true;
              } else {
                // 否则转为下一个月
                selectedMonth = oldMonth + 1;
                isLeapMonth = false;
              }
            }
          }
        } else {
          // 切换到无闰月的年份
          if (oldIsLeapMonth) {
            // 如果原来是闰月，转为下一个月
            selectedMonth = oldMonth + 1;
            isLeapMonth = false;
          } else if (oldLeapMonth > 0 && oldMonth > oldLeapMonth) {
            // 如果原来在闰月之后，需要减一
            selectedMonth = oldMonth - 1;
          }
        }
      }
      
      // 检查日期有效性
      _adjustDayIfNeeded();
    });
  }

  // 同样在月份变化时也要检查
  void onMonthSelectedItemChanged(int index) {
    setState(() {
      if (!isLunar) {
        // 公历月份直接使用index + 1
        selectedMonth = index + 1;
      } else {
        // 农历月份需要处理闰月
        final lunarYear = LunarYear.fromYear(selectedYear);
        final leapMonth = lunarYear.getLeapMonth();
        
        if (leapMonth > 0) {
          if (index <= leapMonth - 1) {
            // 在闰月之前
            selectedMonth = index + 1;
            isLeapMonth = false;
          } else if (index == leapMonth) {
            // 闰月
            selectedMonth = leapMonth;
            isLeapMonth = true;
          } else {
            // 闰月之后
            selectedMonth = index;
            isLeapMonth = false;
          }
        } else {
          // 无闰月年份
          selectedMonth = index + 1;
          isLeapMonth = false;
        }
      }
      
      // 检查日期有效性
      _adjustDayIfNeeded();
    });
  }

  // 添加一个辅助方法来调整日期
  void _adjustDayIfNeeded() {
    try {
      if (isLunar) {
        Lunar.fromYmd(selectedYear, selectedMonth, selectedDay);
      } else {
        DateTime(selectedYear, selectedMonth, selectedDay);
      }
    } catch (e) {
      // 如果日期无效，调整到该月的最后一天
      if (isLunar) {
        try {
          Lunar.fromYmd(selectedYear, selectedMonth, 29);
          selectedDay = 29;
        } catch (e) {
          selectedDay = 1;
        }
      } else {
        selectedDay = DateTime(selectedYear, selectedMonth + 1, 0).day;
      }
    }
  }
}