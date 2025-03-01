import 'package:flutter/material.dart';
import 'package:remind_me/models/event.dart';

// 为 Repeat 枚举添加中文描述
extension RepeatExtension on Repeat {
  String get chineseDescription {
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

  const RepeatRulePicker({
    Key? key,
    required this.initialRepeat,
    required this.onRepeatChanged,
  }) : super(key: key);

  @override
  _RepeatRulePickerState createState() => _RepeatRulePickerState();
}

class _RepeatRulePickerState extends State<RepeatRulePicker> {
  late Repeat selectedRepeat;
  bool _isScrolled = false; // 标记列表是否滑动
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedRepeat = widget.initialRepeat;
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset == 0 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('重复', style: TextStyle(fontSize: 18)),
          if (_isScrolled) const Divider(), // 只有在列表滑动时才显示分割线
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: Repeat.values.length,
              itemBuilder: (context, index) {
                final repeat = Repeat.values[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(repeat.chineseDescription), // 显示中文描述
                      trailing: selectedRepeat == repeat
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedRepeat = repeat;
                          widget.onRepeatChanged(selectedRepeat);
                          Navigator.pop(context);
                        });
                      },
                      tileColor: selectedRepeat == repeat
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : null,
                    ),
                    if (index < Repeat.values.length - 1) 
                    // 列表项之间的分割线不要有padding
                      const Divider(height: 0,),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}