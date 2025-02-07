import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:remind_me/l10n/l10n.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
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
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final daysInSelectedMonth = _getDaysInMonth(selectedYear, selectedMonth);
                    if (selectedDay > daysInSelectedMonth) {
                      selectedDay = daysInSelectedMonth;
                    }
                    widget.onDateChanged(DateTime(selectedYear, selectedMonth, selectedDay));
                    Navigator.pop(context);
                  },
                  child: Text(
                    context.l10n.confirm,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  _buildPickerColumn(
                    items: List.generate(201, (index) => '${index + 1900} ${context.l10n.year}'),
                    initialItem: selectedYear - 1900,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedYear = index + 1900;
                      });
                    },
                  ),
                  _buildPickerColumn(
                    items: List.generate(12, (index) => '${index + 1} ${context.l10n.month}'),
                    initialItem: selectedMonth - 1,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMonth = index + 1;
                      });
                    },
                  ),
                  _buildPickerColumn(
                    items: List.generate(_getDaysInMonth(selectedYear, selectedMonth), 
                      (index) => '${index + 1} ${context.l10n.days}'),
                    initialItem: selectedDay - 1,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedDay = index + 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerColumn({
    required List<String> items,
    required int initialItem,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Stack(
        children: [
          Positioned(
            top: 95,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          CupertinoPicker(
            itemExtent: 32,
            diameterRatio: 2.0,
            squeeze: 1.2,
            selectionOverlay: null,
            offAxisFraction: 0.0,
            useMagnifier: false,
            scrollController: FixedExtentScrollController(
              initialItem: initialItem,
            ),
            onSelectedItemChanged: onSelectedItemChanged,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}