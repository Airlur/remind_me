import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class ReminderTimePicker extends StatefulWidget {
  final DateTime? initialTime;
  final DateTime targetDate; // ç®æ æ¥æåæ°
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

enum ReminderType {
  off,
  sameDay,
  oneDayBefore,
  twoDaysBefore,
  threeDaysBefore,
  oneWeekBefore,
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  static const List<ReminderType> _types = [
    ReminderType.off,
    ReminderType.sameDay,
    ReminderType.oneDayBefore,
    ReminderType.twoDaysBefore,
    ReminderType.threeDaysBefore,
    ReminderType.oneWeekBefore,
  ];

  late ReminderType selectedType;
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialTime == null) {
      selectedType = ReminderType.off;
      selectedHour = DateTime.now().hour;
      selectedMinute = DateTime.now().minute;
    } else {
      final targetDate = DateTime(
        widget.targetDate.year,
        widget.targetDate.month,
        widget.targetDate.day,
      );
      final reminderDate = DateTime(
        widget.initialTime!.year,
        widget.initialTime!.month,
        widget.initialTime!.day,
      );
      final diff = targetDate.difference(reminderDate).inDays;
      
      LoggerUtils.i('ãReminderTimePickerãåå§å - ç®æ æ¥æ: $targetDate, æéæ¶é´: ${widget.initialTime}, å·®å¼å¤©æ°: $diff', 'ReminderTimePicker');
      
      // ä¿®æ¹å¤æ­é»è¾ï¼å¤çè´æ°æå?
      if (diff == 0) {
        selectedType = ReminderType.sameDay;
      } else if (diff == 1) {
        selectedType = ReminderType.oneDayBefore;
      } else if (diff == 2) {
        selectedType = ReminderType.twoDaysBefore;
      } else if (diff == 3) {
        selectedType = ReminderType.threeDaysBefore;
      } else if (diff == 7) {
        selectedType = ReminderType.oneWeekBefore;
      } else {
        if (diff > 0 && diff < 7) {
          if (diff == 1) {
            selectedType = ReminderType.oneDayBefore;
          } else if (diff == 2) {
            selectedType = ReminderType.twoDaysBefore;
          } else if (diff == 3) {
            selectedType = ReminderType.threeDaysBefore;
          } else {
            selectedType = ReminderType.oneWeekBefore;
          }
        } else {
          selectedType = ReminderType.sameDay;
        }
      }
      
      selectedHour = widget.initialTime!.hour;
      selectedMinute = widget.initialTime!.minute;
      
      LoggerUtils.i('ãReminderTimePickerãéæ©çç±»å? $selectedType, å°æ¶: $selectedHour, åé: $selectedMinute', 'ReminderTimePicker');
    }
  }

  String _typeLabel(BuildContext context, ReminderType type) {
    final l10n = context.l10n;
    switch (type) {
      case ReminderType.off:
        return l10n.reminderOff;
      case ReminderType.sameDay:
        return l10n.reminderSameDay;
      case ReminderType.oneDayBefore:
        return l10n.reminder1DayBefore;
      case ReminderType.twoDaysBefore:
        return l10n.reminder2DayBefore;
      case ReminderType.threeDaysBefore:
        return l10n.reminder3DayBefore;
      case ReminderType.oneWeekBefore:
        return l10n.reminder1WeekBefore;
    }
  }

  DateTime? _getSelectedDateTime() {
    if (selectedType == ReminderType.off) return null;

    final baseDate = DateTime(
      widget.targetDate.year,
      widget.targetDate.month,
      widget.targetDate.day,
    );

    int offsetDays = 0;
    switch (selectedType) {
      case ReminderType.sameDay:
        offsetDays = 0;
        break;
      case ReminderType.oneDayBefore:
        offsetDays = -1;
        break;
      case ReminderType.twoDaysBefore:
        offsetDays = -2;
        break;
      case ReminderType.threeDaysBefore:
        offsetDays = -3;
        break;
      case ReminderType.oneWeekBefore:
        offsetDays = -7;
        break;
      case ReminderType.off:
        return null;
    }

    final date = baseDate.add(Duration(days: offsetDays));
    return DateTime(date.year, date.month, date.day, selectedHour, selectedMinute);
  }

  // è·åæ¾ç¤ºææ¬ - æ¾ç¤ºå®æ´æ¥æ
  String _getDisplayText() {
    final dateTime = _getSelectedDateTime();
    if (dateTime == null) return context.l10n.reminderOff;
    
    // æ¾ç¤ºå®æ´æ¥æåæ¶é?    
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
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                    style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: _handleConfirm,
                    child: Text(context.l10n.confirm),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // éæ©å¨ä¸»ä½?
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // éä¸­è¡èæ?
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
                      // æéç±»åéæ©å?
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
                            initialItem: _types.indexOf(selectedType),
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedType = _types[index];
                            });
                          },
                          children: _types
                              .map((type) => Center(
                                    child: Text(
                                      _typeLabel(context, type),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      
                      if (selectedType != ReminderType.off)
                        Expanded(
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
                                '$index${context.l10n.hour}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      
                      if (selectedType != ReminderType.off)
                        Expanded(
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
                                '$index${context.l10n.minute}',
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




