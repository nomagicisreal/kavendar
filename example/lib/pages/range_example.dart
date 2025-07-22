// ignore_for_file: unused_field

import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:kavendar/kavendar.dart';

class TableRangeExample extends StatefulWidget {
  const TableRangeExample({super.key});

  @override
  State<TableRangeExample> createState() => _TableRangeExampleState();
}

class _TableRangeExampleState extends State<TableRangeExample> {
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
  //     .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      appBar: AppBar(title: const Text('TableCalendar - Range')),
      body: Calendar(
        focusedDate: _focusedDay,
        // rangeSelectionMode: _rangeSelectionMode,
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _rangeStart = null; // Important to clean those
              _rangeEnd = null;
              // _rangeSelectionMode = RangeSelectionMode.toggledOff;
            });
            print('on date selected');
          }
        },
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _selectedDay = null;
            _focusedDay = focusedDay;
            _rangeStart = start;
            _rangeEnd = end;
            // _rangeSelectionMode = RangeSelectionMode.toggledOn;
          });
          print('on range selected');
        },
        onPageChanged: (index, focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
