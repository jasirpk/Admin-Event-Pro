import 'package:flutter/material.dart';

class FromToTimePicker extends StatefulWidget {
  final TimeOfDay initialFromTime;
  final TimeOfDay initialToTime;
  final ValueChanged<TimeOfDay> onFromTimeChanged;
  final ValueChanged<TimeOfDay> onToTimeChanged;

  FromToTimePicker({
    required this.initialFromTime,
    required this.initialToTime,
    required this.onFromTimeChanged,
    required this.onToTimeChanged,
  });

  @override
  _FromToTimePickerState createState() => _FromToTimePickerState();
}

class _FromToTimePickerState extends State<FromToTimePicker> {
  late TimeOfDay _fromTime;
  late TimeOfDay _toTime;

  @override
  void initState() {
    super.initState();
    _fromTime = widget.initialFromTime;
    _toTime = widget.initialToTime;
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _fromTime,
    );
    if (picked != null && picked != _fromTime) {
      setState(() {
        _fromTime = picked;
      });
      widget.onFromTimeChanged(picked);
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _toTime,
    );
    if (picked != null && picked != _toTime) {
      setState(() {
        _toTime = picked;
      });
      widget.onToTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: screenWidth * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From:'),
                SizedBox(height: 10),
                InkWell(
                  onTap: () => _selectFromTime(context),
                  child: Container(
                    height: screenHeight * 0.06,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.alarm_add,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _fromTime.format(context),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: screenWidth * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To:'),
                SizedBox(height: 10),
                InkWell(
                  onTap: () => _selectToTime(context),
                  child: Container(
                    height: screenHeight * 0.06,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.alarm_add,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _toTime.format(context),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTimeLineWidget extends StatelessWidget {
  const CustomTimeLineWidget({
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FromToTimePicker(
          initialFromTime: TimeOfDay(hour: 0, minute: 0),
          initialToTime: TimeOfDay(hour: 0, minute: 0),
          onFromTimeChanged: (time) {
            print('From time: ${time.format(context)}');
          },
          onToTimeChanged: (time) {
            print('To time: ${time.format(context)}');
          },
        ),
      ],
    );
  }
}
