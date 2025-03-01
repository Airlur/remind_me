import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class ReminderTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final ValueChanged<DateTime> onTimeChanged;

  const ReminderTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _ReminderTimePickerState createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late DateTime selectedDate;
  late int selectedDateIndex;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    selectedDate = widget.initialTime;
    selectedDateIndex = _getSelectedDateIndex();
  }

  void _handleConfirm() {
    final selectedTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedHour, selectedMinute);
    widget.onTimeChanged(selectedTime);
    Navigator.pop(context);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  int _getSelectedDateIndex() {
    if (selectedDate.isAtSameMomentAs(DateTime.now())) return 1;
    if (selectedDate.isBefore(DateTime.now())) {
      final difference = DateTime.now().difference(selectedDate).inDays;
      if (difference == 1) return 2;
      return 0;
    }
    if (selectedDate.isAtSameMomentAs(DateTime.now().add(Duration(days: 1)))) return 3;
    if (selectedDate.isAtSameMomentAs(DateTime.now().add(Duration(days: 2)))) return 4;
    if (selectedDate.isAtSameMomentAs(DateTime.now().add(Duration(days: 7)))) return 5;
    return 1;
  }

  DateTime _calculateDate(int index) {
    switch (index) {
      case 0: return DateTime.now(); // 假设“无”表示当前时间
      case 1: return DateTime.now();
      case 2: return DateTime.now().subtract(Duration(days: 1));
      case 3: return DateTime.now().add(Duration(days: 1));
      case 4: return DateTime.now().add(Duration(days: 2));
      case 5: return DateTime.now().add(Duration(days: 7));
      default: return selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // 占据顶部以下一半的空间
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _handleCancel,
                child: Text('取消'),
              ),
              Text(
                '${DateFormat('yyyy年MM月dd日').format(selectedDate)} ${DateFormat('EEEE', 'zh_CN').format(selectedDate)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextButton(
                onPressed: _handleConfirm,
                child: Text('确认'),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: Row(
              children: [
                _buildPickerColumn(
                  items: ['无', '当天', '提前1天', '提前2天', '提前1周'],
                  selectedValue: selectedDateIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedDateIndex = value;
                      selectedDate = _calculateDate(value);
                    });
                  },
                ),
                _buildPickerColumn(
                  items: List.generate(24, (index) => '${index}时'),
                  selectedValue: selectedHour,
                  onChanged: (value) {
                    setState(() {
                      selectedHour = value;
                    });
                  },
                ),
                _buildPickerColumn(
                  items: List.generate(60, (index) => '${index}分'),
                  selectedValue: selectedMinute,
                  onChanged: (value) {
                    setState(() {
                      selectedMinute = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerColumn({
    required List<String> items,
    required int selectedValue,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(initialItem: selectedValue),
        onSelectedItemChanged: onChanged,
        children: items.map((item) {
          final isSelected = items.indexOf(item) == selectedValue;
          return Center(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}