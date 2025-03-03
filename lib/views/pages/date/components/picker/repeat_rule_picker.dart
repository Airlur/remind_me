import 'package:flutter/material.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/models/custom_repeat_rule.dart';
import 'custom_repeat_rule_picker.dart';

// 为 Repeat 枚举添加中文描述
extension RepeatExtension on Repeat {
  String get description {
    switch (this) {
      case Repeat.none:
        return '不重复';
      case Repeat.daily:
        return '每天';
      case Repeat.weekly:
        return '每周';
      case Repeat.monthly:
        return '每月';
      case Repeat.yearly:
        return '每年';
      case Repeat.custom:
        return '自定义';
    }
  }
}

class RepeatRulePicker extends StatefulWidget {
  final Repeat initialRepeat;
  final ValueChanged<Repeat> onRepeatChanged;
  final ValueChanged<CustomRepeatRule>? onCustomRuleChanged;

  const RepeatRulePicker({
    super.key,
    required this.initialRepeat,
    required this.onRepeatChanged,
    this.onCustomRuleChanged,
  });

  @override
  State<RepeatRulePicker> createState() => _RepeatRulePickerState();
}

class _RepeatRulePickerState extends State<RepeatRulePicker> {
  late Repeat selectedRepeat;
  CustomRepeatRule? customRule;

  @override
  void initState() {
    super.initState();
    selectedRepeat = widget.initialRepeat;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Text(
                    context.l10n.repeat,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 重复规则列表 - 使用约束高度的容器
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height * 0.4, // 限制最大高度为屏幕高度的40%
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: Repeat.values.length,
                itemBuilder: (context, index) {
                  final repeat = Repeat.values[index];
                  final isSelected = repeat == selectedRepeat;

                  return ListTile(
                    title: Text(
                      repeat.description,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      if (repeat == Repeat.custom) {
                        _showCustomRulePicker();
                      } else {
                        setState(() {
                          selectedRepeat = repeat;
                        });
                        widget.onRepeatChanged(repeat);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomRulePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomRepeatRulePicker(
          initialRule: customRule,
          onRuleChanged: (rule) {
            setState(() {
              customRule = rule;
              selectedRepeat = Repeat.custom;
            });
            widget.onRepeatChanged(Repeat.custom);
            if (widget.onCustomRuleChanged != null) {
              widget.onCustomRuleChanged!(rule);
            }
          },
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context);
    }
  }
}
