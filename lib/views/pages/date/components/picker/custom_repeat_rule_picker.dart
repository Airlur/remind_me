import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:remind_me/models/custom_repeat_rule.dart';

class CustomRepeatRulePicker extends StatefulWidget {
  final CustomRepeatRule? initialRule;
  final ValueChanged<CustomRepeatRule> onRuleChanged;

  const CustomRepeatRulePicker({
    super.key,
    this.initialRule,
    required this.onRuleChanged,
  });

  @override
  State<CustomRepeatRulePicker> createState() => _CustomRepeatRulePickerState();
}

class _CustomRepeatRulePickerState extends State<CustomRepeatRulePicker> {
  late int _interval;
  late RepeatUnit _unit;
  late List<int> _weekdays;
  late List<int> _monthDays;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    
    // 初始化值
    final rule = widget.initialRule;
    _interval = rule?.interval ?? 1;
    _unit = rule?.unit ?? RepeatUnit.day; // 默认选择"日"
    
    // 默认选中当前星期几
    final today = DateTime.now().weekday;
    _weekdays = List.from(rule?.weekdays ?? [today]); 
    
    _monthDays = List.from(rule?.monthDays ?? []);
    _endDate = rule?.endDate;
  }

  void _saveRule() {
    final rule = CustomRepeatRule(
      interval: _interval,
      unit: _unit,
      weekdays: _weekdays,
      monthDays: _monthDays,
      endDate: _endDate,
    );
    
    widget.onRuleChanged(rule);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          '自定义',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveRule,
            child: Text(
              '确定',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 双列选择器
          Container(
            height: 150,
            child: Row(
              children: [
                // 数字选择器 - 设置为循环滚动
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: 999, // 设置初始的“1”在中间位置
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _interval = (index % 999) + 1; // 确保值在1-999范围内
                      });
                    },
                    itemBuilder: (context, index) {
                      final number = (index % 999) + 1; // 循环显示1-999
                      return Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 20,
                          ),
                        ),
                      );
                    },
                    childCount: 10000, // 设置一个很大的数字以实现无限循环效果
                  ),
                ),
                
                // 单位选择器
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _unit.index,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _unit = RepeatUnit.values[index];
                      });
                    },
                    children: [
                      Center(child: Text('日', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20))),
                      Center(child: Text('周', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20))),
                      Center(child: Text('月', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20))),
                      Center(child: Text('年', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 动态内容区域
          Expanded(
            child: _buildDynamicContent(),
          ),
          
          // 有效日期
          ListTile(
            title: Text(
              '有效日期',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _endDate == null ? '一直' : '${_endDate!.year}年${_endDate!.month}月${_endDate!.day}日',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            onTap: _showEndDatePicker,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContent() {
    switch (_unit) {
      case RepeatUnit.day:
        return Center(
          child: Text(
            '每天重复',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        );
      
      case RepeatUnit.week:
        return _buildWeekdaySelector();
      
      case RepeatUnit.month:
        return _buildMonthDaySelector();
      
      case RepeatUnit.year:
        return Center(
          child: Text(
            '每年重复',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        );
    }
  }

  Widget _buildWeekdaySelector() {
    final theme = Theme.of(context);
    final weekdayNames = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 7,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: theme.dividerColor.withOpacity(0.3), // 更浅的下划线
      ),
      itemBuilder: (context, index) {
        final weekday = index + 1; // 1-7 表示周一到周日
        final isSelected = _weekdays.contains(weekday);
        
        return ListTile(
          title: Text(
            weekdayNames[index],
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check,
                  color: theme.colorScheme.primary,
                )
              : null,
          onTap: () {
            setState(() {
              if (isSelected) {
                if (_weekdays.length > 1) { // 确保至少选中一天
                  _weekdays.remove(weekday);
                }
              } else {
                _weekdays.add(weekday);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildMonthDaySelector() {
    final theme = Theme.of(context);
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        final day = index + 1;
        final isSelected = _monthDays.contains(day);
        
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _monthDays.remove(day);
              } else {
                _monthDays.add(day);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEndDatePicker() async {
    final initialDate = _endDate ?? DateTime.now().add(const Duration(days: 30));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }
} 