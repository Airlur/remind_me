import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/l10n/l10n.dart';
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
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    final rule = widget.initialRule;
    _interval = rule?.interval ?? 1;
    _unit = rule?.unit ?? RepeatUnit.day;

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
          context.l10n.custom,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
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
              context.l10n.confirm,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _buildIntervalCard(theme),
            const SizedBox(height: 12),
            _buildUnitCard(theme),
            const SizedBox(height: 12),
            _buildDynamicSection(theme),
            const SizedBox(height: 12),
            _buildEndDateCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalCard(ThemeData theme) {
    final initialIndex = 999 + (_interval - 1);

    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _interval = (index % 999) + 1;
                      });
                    },
                    itemBuilder: (context, index) {
                      final number = (index % 999) + 1;
                      return Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 22,
                          ),
                        ),
                      );
                    },
                    childCount: 10000,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _unitLabel(context, _unit),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              child: Container(
                height: 40,
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
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CupertinoSlidingSegmentedControl<RepeatUnit>(
          groupValue: _unit,
          onValueChanged: (value) {
            if (value == null) return;
            setState(() {
              _unit = value;
            });
          },
          children: {
            RepeatUnit.day: _segmentLabel(context.l10n.day),
            RepeatUnit.week: _segmentLabel(context.l10n.week),
            RepeatUnit.month: _segmentLabel(context.l10n.month),
            RepeatUnit.year: _segmentLabel(context.l10n.year),
          },
        ),
      ),
    );
  }

  Widget _segmentLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(text),
    );
  }

  Widget _buildDynamicSection(ThemeData theme) {
    switch (_unit) {
      case RepeatUnit.day:
        return _buildInfoCard(theme, context.l10n.repeatEveryDay);
      case RepeatUnit.week:
        return _buildWeekdaySelector(theme);
      case RepeatUnit.month:
        return _buildMonthDaySelector(theme);
      case RepeatUnit.year:
        return _buildInfoCard(theme, context.l10n.repeatEveryYear);
    }
  }

  Widget _buildInfoCard(ThemeData theme, String text) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector(ThemeData theme) {
    final weekdayNames = [
      context.l10n.monday,
      context.l10n.tuesday,
      context.l10n.wednesday,
      context.l10n.thursday,
      context.l10n.friday,
      context.l10n.saturday,
      context.l10n.sunday,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final weekday = index + 1;
            final isSelected = _weekdays.contains(weekday);

            return ChoiceChip(
              label: Text(weekdayNames[index]),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
              ),
              onSelected: (selected) {
                setState(() {
                  if (isSelected) {
                    if (_weekdays.length > 1) {
                      _weekdays.remove(weekday);
                    }
                  } else {
                    _weekdays.add(weekday);
                  }
                });
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthDaySelector(ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = _monthDays.contains(day);

            return ChoiceChip(
              label: Text('$day'),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
              ),
              onSelected: (selected) {
                setState(() {
                  if (isSelected) {
                    _monthDays.remove(day);
                  } else {
                    _monthDays.add(day);
                  }
                });
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEndDateCard(ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(
          context.l10n.validDate,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _endDate == null
                  ? context.l10n.always
                  : _formatEndDate(_endDate!),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: _showEndDatePicker,
      ),
    );
  }

  String _formatEndDate(DateTime date) {
    return '${date.year} ${context.l10n.year} ${date.month} ${context.l10n.month} ${date.day} ${context.l10n.day}';
  }

  String _unitLabel(BuildContext context, RepeatUnit unit) {
    switch (unit) {
      case RepeatUnit.day:
        return context.l10n.day;
      case RepeatUnit.week:
        return context.l10n.week;
      case RepeatUnit.month:
        return context.l10n.month;
      case RepeatUnit.year:
        return context.l10n.year;
    }
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
