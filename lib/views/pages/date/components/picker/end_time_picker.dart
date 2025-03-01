import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EndTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final ValueChanged<DateTime> onTimeChanged;

  const EndTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _EndTimePickerState createState() => _EndTimePickerState();
}

class _EndTimePickerState extends State<EndTimePicker> {
  late DateTime selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  void _handleConfirm() {
    widget.onTimeChanged(selectedTime);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('选择结束时间', style: Theme.of(context).textTheme.bodyLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('yyyy-MM-dd').format(selectedTime)),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, selectedTime.hour, selectedTime.minute);
                    });
                  }
                },
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _handleConfirm,
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 