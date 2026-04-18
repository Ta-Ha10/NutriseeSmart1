import 'package:flutter/material.dart';

class WheelTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const WheelTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<WheelTimePicker> createState() => _WheelTimePickerState();
}

class _WheelTimePickerState extends State<WheelTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _ampmController;

  late int selectedHour;
  late int selectedMinute;
  late int selectedAmpm; // 0 = AM, 1 = PM

  @override
  void initState() {
    super.initState();
    
    // Convert 24-hour format to 12-hour format
    int hour24 = widget.initialTime.hour;
    selectedAmpm = hour24 >= 12 ? 1 : 0; // 1 = PM, 0 = AM
    selectedHour = hour24 % 12;
    if (selectedHour == 0) selectedHour = 12;
    
    selectedMinute = widget.initialTime.minute;

    _hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    _ampmController = FixedExtentScrollController(initialItem: selectedAmpm);
  }

  void _updateTime() {
    int hour24 = selectedHour;
    if (selectedAmpm == 1) { // PM
      if (selectedHour != 12) {
        hour24 = selectedHour + 12;
      }
    } else { // AM
      if (selectedHour == 12) {
        hour24 = 0;
      }
    }
    
    TimeOfDay newTime = TimeOfDay(hour: hour24, minute: selectedMinute);
    widget.onTimeChanged(newTime);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hour Wheel
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  'Hour',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListWheelScrollView(
                    controller: _hourController,
                    itemExtent: 50,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHour = index + 1;
                      });
                      _updateTime();
                    },
                    perspective: 0.005,
                    children: List.generate(
                      12,
                      (index) => Center(
                        child: Text(
                          '${index + 1}'.padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: selectedHour == index + 1 ? 28 : 18,
                            fontWeight: selectedHour == index + 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedHour == index + 1
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Minute Wheel
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  'Minute',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListWheelScrollView(
                    controller: _minuteController,
                    itemExtent: 50,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMinute = index;
                      });
                      _updateTime();
                    },
                    perspective: 0.005,
                    children: List.generate(
                      60,
                      (index) => Center(
                        child: Text(
                          '${index}'.padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: selectedMinute == index ? 28 : 18,
                            fontWeight: selectedMinute == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedMinute == index
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // AM/PM Wheel
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  'Period',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListWheelScrollView(
                    controller: _ampmController,
                    itemExtent: 50,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedAmpm = index;
                      });
                      _updateTime();
                    },
                    perspective: 0.005,
                    children: List.generate(
                      2,
                      (index) => Center(
                        child: Text(
                          index == 0 ? 'AM' : 'PM',
                          style: TextStyle(
                            fontSize: selectedAmpm == index ? 28 : 18,
                            fontWeight: selectedAmpm == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedAmpm == index
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
